#!/usr/bin/env ts-node

import fs from "node:fs/promises";
import path from "node:path";

type TestCase = "input.txt" | "example.txt";

function match(line: string, regex: RegExp): Record<string, string> {
  const match = line.match(regex);
  if (!match) {
    console.log("no match", line, regex);
  }

  return match!.groups as Record<string, string>;
}
async function part1(testCase: TestCase = "example.txt") {
  const file = await fs.open(path.join(__dirname, testCase));

  const valveMap: ValveMap = {};

  let valveCount = 0;
  for await (const line of file.readLines()) {
    const {
      valve,
      rate: rawRate,
      tunnels: rawTunnels,
    } = match(
      line,
      /^Valve (?<valve>[A-Z]+) has flow rate=(?<rate>\d+); tunnels? leads? to valves? (?<tunnels>.*)$/,
    );

    const rate = Number(rawRate);
    const tunnels = rawTunnels.split(", ");
    valveMap[valve] = {
      rate,
      edges: tunnels.map((t) => ({ minutes: 1, valve: t })),
    };
    valveCount++;
  }

  // dijkstra from each valve to the first non nonzero valve that is reachable
  for (let [valveName, valve] of Object.entries(valveMap)) {
    if (valve.rate === 0) continue;
    const edges = valve.edges;
    valve.edges = [];
    const seen = new Set();
    seen.add(valveName);
    let edge: Edge | undefined;
    while ((edge = edges.pop())) {
      if (seen.has(edge.valve)) continue;

      const v = valveMap[edge.valve];
      let mins = edge.minutes;
      if (v.rate === 0) {
        seen.add(edge.valve);
        edges.push(
          ...v.edges.map((e) => ({ valve: e.valve, minutes: mins + 1 })),
        );
        edges.sort((a, b) => b.minutes - a.minutes);
      } else {
        valve.edges.push(edge);
      }
    }
  }
  console.log(optimalPressure(new Set(), "AA", 30));

  // todo bitmap of the valves currently on
  function optimalPressure(
    opened: Set<string>,
    current: string,
    minutes: number,
  ): number {
    console.log(current, minutes);

    // out of time
    if (minutes <= 1) return 0;

    // all valves open, just sit and wait
    if (opened.size === valveCount) return 0;

    // current valve has released
    const valve = valveMap[current];
    if (opened.has(current)) {
      return Math.max(
        ...valve.edges.map((e) =>
          optimalPressure(opened, e.valve, minutes - e.minutes),
        ),
      );
    }

    const copy = new Set(opened);
    copy.add(current);

    const released = (minutes - 1) * valve.rate;

    // handle combinations of opening valve or not with each possible edge.
    return Math.max(
      ...valve.edges.flatMap((e) => [
        optimalPressure(opened, e.valve, minutes - e.minutes),
        released + optimalPressure(copy, e.valve, minutes - 1 - e.minutes),
      ]),
    );
  }
}

type Edge = { valve: string; minutes: number };

type ValveMap = Record<string, Valve>;
type Valve = {
  edges: Array<Edge>;
  rate: number;
};

part1("example.txt");
