#!/usr/bin/env ts-node

import { countReset } from "node:console";
import fs from "node:fs/promises";
import path from "node:path";

type TestCase = "input.txt" | "example.txt";

type Point = [number, number, number];

async function main(testCase: TestCase = "example.txt") {
  const contents = await fs.readFile(path.join(__dirname, testCase), "utf-8");
  const lava = new Set<string>();
  let bounds = {
    minX: Number.POSITIVE_INFINITY,
    minY: Number.POSITIVE_INFINITY,
    minZ: Number.POSITIVE_INFINITY,
    maxX: Number.NEGATIVE_INFINITY,
    maxY: Number.NEGATIVE_INFINITY,
    maxZ: Number.NEGATIVE_INFINITY,
  };
  for (const line of contents.trimEnd().split("\n")) {
    const [x, y, z] = line.split(",").map(Number);
    lava.add(line);
    bounds.minX = Math.min(x, bounds.minX);
    bounds.maxX = Math.max(x, bounds.maxX);
    bounds.minY = Math.min(y, bounds.minY);
    bounds.maxY = Math.max(y, bounds.maxY);
    bounds.minZ = Math.min(z, bounds.minZ);
    bounds.maxZ = Math.max(z, bounds.maxZ);
  }
  bounds.minX--;
  bounds.maxX++;
  bounds.minY--;
  bounds.maxY++;
  bounds.minZ--;
  bounds.maxZ++;

  let tally = 0;
  const air = new Set<string>();
  const backlog = [[bounds.minX, bounds.minY, bounds.minZ]];
  while (backlog.length) {
    //console.log(backlog);
    const point = backlog.pop()!;
    const [x, y, z] = point;
    if (
      x < bounds.minX ||
      x > bounds.maxX ||
      y < bounds.minY ||
      y > bounds.maxY ||
      z < bounds.minZ ||
      z > bounds.maxZ
    ) {
      continue;
    }
    const coordinates = point.join(",");
    if (air.has(coordinates)) continue;
    air.add(coordinates);

    // left
    if (lava.has([x - 1, y, z].join(","))) {
      tally++;
    } else {
      backlog.push([x - 1, y, z]);
    }

    // right
    if (lava.has([x + 1, y, z].join(","))) {
      tally++;
    } else {
      backlog.push([x + 1, y, z]);
    }

    // backwards
    if (lava.has([x, y - 1, z].join(","))) {
      tally++;
    } else {
      backlog.push([x, y - 1, z]);
    }

    // forwards
    if (lava.has([x, y + 1, z].join(","))) {
      tally++;
    } else {
      backlog.push([x, y + 1, z]);
    }

    // bottom
    if (lava.has([x, y, z - 1].join(","))) {
      tally++;
    } else {
      backlog.push([x, y, z - 1]);
    }

    // top
    if (lava.has([x, y, z + 1].join(","))) {
      tally++;
    } else {
      backlog.push([x, y, z + 1]);
    }
  }

  console.log(tally);
  //console.log(bounds);
}

main("input.txt");
