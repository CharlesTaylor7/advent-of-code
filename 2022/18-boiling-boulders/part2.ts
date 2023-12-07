#!/usr/bin/env ts-node

import fs from "node:fs/promises";
import path from "node:path";

type TestCase = "input.txt" | "example.txt";

type Point = [number, number, number];

async function main(testCase: TestCase = "example.txt") {
  const set = new Set<string>();
  let bounds = {
    minX: Number.POSITIVE_INFINITY,
    minY: Number.POSITIVE_INFINITY,
    minZ: Number.POSITIVE_INFINITY,
    maxX: Number.NEGATIVE_INFINITY,
    maxY: Number.NEGATIVE_INFINITY,
    maxZ: Number.NEGATIVE_INFINITY,
  };
  for (const line of (await fs.readFile("utf8")).split("\n")) {
    const [x, y, z] = line.split(",").map(Number);
    set.add(line);
    bounds.minX = Math.min(x, bounds.minX);
    bounds.maxX = Math.max(x, bounds.maxX);
    bounds.minY = Math.min(y, bounds.minY);
    bounds.maxY = Math.max(y, bounds.maxY);
    bounds.minZ = Math.min(z, bounds.minZ);
    bounds.maxZ = Math.max(z, bounds.maxZ);
  }

  console.log(bounds);

  let tally = 0;
  console.log(tally);
}

main("example.txt");
