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
      ore: { ore: oreCost },
      clay: { ore: clayCost },
      obsidian: { ore: obsidianCost1, clay: obsidianCost2 },
      geode: { ore: geodeCost1, obsidian: geodeCost2 },
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
  console.log(tally);
}

// greedy approach first, if it doesn't work than we'l pivot to dynamic programming
function maxGeodes(blueprint: Blueprint, state: State): number {
  for (let i = 0; i < state.minutes; i++) {
    // can the factory build more than 1 robot per minute?
    
    // greedy, try to build geode collecting robots and work backwards from there. 
    const newRobots: ResourceType[] = [];
    if (tryToBuild(blueprint, state, 'geode')) {
      newRobots.push('geode');
    }

    if (tryToBuild(blueprint, state, 'obsidian')) {
      newRobots.push('obsidian');
    }

    if (tryToBuild(blueprint, state, 'clay')) {
      newRobots.push('clay');
    }

    if (tryToBuild(blueprint, state, 'ore')) {
      newRobots.push('ore');
    }

    for (let [res, amount] of Object.entries(state.robots)) {
      state.resources[res as ResourceType] += amount;
    }

    for (let robot of newRobots) {
      state.robots[robot]++;
    }
  }

  return state.resources.geode;
}

function tryToBuild(blueprint: Blueprint, state: State, resource: ResourceType): boolean {

  for (let [res, amount] of Object.entries(blueprint[resource])) {
    if (state.resources[res as ResourceType] < amount) return false
  }

  for (let [res, amount] of Object.entries(blueprint[resource])) {
    state.resources[res as ResourceType] -= amount;
  }

  return true
}

type ResourceType = "ore" | "clay" | "obsidian" | "geode";
type State = {
  minutes: number,
  resources: Record<ResourceType, number>;
  robots: Record<ResourceType, number>;
};

type Blueprint = Record<ResourceType, Partial<Record<ResourceType, number>>>;

main("input.txt");
