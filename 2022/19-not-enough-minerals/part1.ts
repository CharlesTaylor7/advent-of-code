#!/usr/bin/env ts-node

import fs from "node:fs/promises";
import path from "node:path";

type TestCase = "input.txt" | "example.txt";

async function main(testCase: TestCase = "example.txt") {
  const contents = await fs.readFile(path.join(__dirname, testCase), "utf-8");

  let tally = 0;
  const regex =
    /Blueprint (?<id>\d+):\s+Each ore robot costs (?<oreCost>\d+) or.\s+Each clay robot costs (?<clayCost>\d+) ore.\s+Each obsidian robot costs (?<obsidianCost1>\d+) ore and (?<obsidianCost2>\d+) clay.\s+Each geode robot costs (?<geodeCost1>\d+) ore and (?<geodeCost2>\d+) obsidian./gm;
  for (let match of contents.matchAll(regex)) {
    const {
      id,
      oreCost,
      clayCost,
      obsidianCost1,
      obsidianCost2,
      geodeCost1,
      geodeCost2,
    } = Object.fromEntries(
      Object
      .entries(match.groups as Record<string, string>)
      .map(([key, value]) => [key, Number(value)] as [string, number])
    );

    const blueprint: Blueprint  = {
      ore: [[oreCost, "ore"]],
      clay: [[clayCost, "ore"]],
      obsidian: [[obsidianCost1, "ore"], [obsidianCost2, "clay"]],
      geode: [[geodeCost1, "ore"], [geodeCost2, "obsidian"]],
    };

    const state: State = {
      minutes: 24,
      resources: {
        ore: 0,
        clay: 0,
        obsidian: 0,
        geode: 0,
      },
      robots: {
        ore: 1,
        clay: 0,
        obsidian: 0,
        geode: 0,
      }
    }
    tally += id * maxGeodes(blueprint, state);
  }
}

    // greedy approach first, if it doesn't work than we'l pivot to dynamic programming
function maxGeodes(blueprint: Blueprint, state: State): number {
  return 2;
}

type ResourceType = "ore" | "clay" | "obsidian" | "geode";
type State = {
  minutes: number,
  resources: Record<ResourceType, number>;
  robots: Record<ResourceType, number>;
};

type Blueprint = Record<ResourceType, [number, ResourceType][]>;

main("input.txt");
