#!/usr/bin/env ts-node

import fs from "node:fs/promises";
import path from "node:path";

type TestCase = "input.txt" | "example.txt";

async function main(testCase: TestCase = "example.txt") {
  const contents = await fs.readFile(path.join(__dirname, testCase), "utf-8");

  const regex =
    /Blueprint (?<id>\d+):\s+Each ore robot costs (?<oreCost>\d+) ore.\s+Each clay robot costs (?<clayCost>\d+) ore.\s+Each obsidian robot costs (?<obsidianCost1>\d+) ore and (?<obsidianCost2>\d+) clay.\s+Each geode robot costs (?<geodeCost1>\d+) ore and (?<geodeCost2>\d+) obsidian./gm;
  for (let match of contents.matchAll(regex)) {
    console.log(match.groups);
  }
}

type ResourceType = "ore" | "clay" | "obsidian" | "geode";
type State = {
  resources: Record<ResourceType, number>;
  robots: Record<ResourceType, number>;
};

type Blueprint = Record<ResourceType, [number, ResourceType]>;

main("input.txt");
