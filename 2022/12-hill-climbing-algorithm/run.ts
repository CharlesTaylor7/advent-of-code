#!/usr/bin/env ts-node

import fs from "node:fs/promises";
import path from "node:path";

type State = {
  start: number;
  end: number;
  width: number;
  grid: number[];
};

async function main(part: 1 | 2 = 1, testCase: string = "example.txt") {
  const file = await fs.open(path.join(__dirname, testCase));

  let func = part === 1 ? part1 : part2;
  const state: Partial<State> = { grid: [] };
  const offset = "a".charCodeAt(0);
  let j = 0;
  for await (const line of file.readLines()) {
    console.log(line);
    state.width = line.length;
    for (let i = 0; i < line.length; i++) {
      let k = line[i];
      if (k === "S") {
        state.start = j * state.width + i;
        k = "a";
      } else if (k === "E") {
        state.end = j * state.width + i;
        k = "z";
      }
      state.grid!.push(k.charCodeAt(0) - offset);
    }
    j++;
  }

  func(state as State);
}

function part1(state: State) {
  const distances = Array.from(
    { length: state.grid.length },
    () => Number.POSITIVE_INFINITY,
  );
  distances[state.start] = 0;

  // lazy queue for now
  const queue = [[state.start, 0]];
  while (true) {
    const pair = queue.pop();
    if (pair === undefined) break;
    const [node] = pair;
    const neighbors = [
      node - state.width,
      node + state.width,
      node - 1,
      node + 1,
    ];
    for (let n of neighbors) {
      if (
        state.grid[n] !== undefined &&
        state.grid[n] - state.grid[node] <= 1
      ) {
        const prev = distances[n];
        const d = Math.min(prev, distances[node] + 1);
        if (prev === Number.POSITIVE_INFINITY) {
          queue.push([n, d]);
        }
        distances[n] = d;
      }
    }

    queue.sort((a, b) => b[1] - a[1]);
    //console.log(queue)
  }

  console.log(distances[state.end]);
}

function part2(state: State) {
  const distances = Array.from(
    { length: state.grid.length },
    () => Number.POSITIVE_INFINITY,
  );
  distances[state.start] = 0;

  const queue: [number, number][] = [];
  for (let i = 0; i < state.grid.length; i++) {
    if (state.grid[i] === 0) {
      distances[i] = 0;
      queue.push([i, 0]);
    }
  }

  // lazy queue for now
  while (true) {
    const pair = queue.pop();
    if (pair === undefined) break;
    const [node] = pair;
    const neighbors = [
      node - state.width,
      node + state.width,
      node - 1,
      node + 1,
    ];
    for (let n of neighbors) {
      if (
        state.grid[n] !== undefined &&
        state.grid[n] - state.grid[node] <= 1
      ) {
        const prev = distances[n];
        const d = Math.min(prev, distances[node] + 1);
        if (prev === Number.POSITIVE_INFINITY) {
          queue.push([n, d]);
        }
        distances[n] = d;
      }
    }

    queue.sort((a, b) => b[1] - a[1]);
  }

  console.log(distances[state.end]);
}

main(2, "example.txt");
