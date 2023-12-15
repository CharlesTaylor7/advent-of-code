#!/usr/bin/env ts-node

import fs from "node:fs/promises";
import path from "node:path";

async function part1() {
  const file = await fs.open(path.join(__dirname, "input.txt"));
  const row = 2_000_000;

  const set = new Set();
  for await (const line of file.readLines()) {
    const [, sx, sy, bx, by] = line
      .match(
        /^Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)$/,
      )!
      .map(Number);
    if (sy === row) set.add(sx);
    const manhattanDistance = Math.abs(sx - bx) + Math.abs(sy - by);
    if (row > sy + manhattanDistance) {
      continue;
    }

    const dy = Math.abs(row - sy);
    const dx = manhattanDistance - dy;
    for (let x = sx - dx; x <= sx + dx; x++) {
      if (by === row && x === bx) continue;
      set.add(x);
    }
  }
  console.log(set.size);
}
async function part2() {
  const testCase: string = "input.txt";
  const file = await fs.open(path.join(__dirname, testCase));

  const sensors: Sensor[] = [];
  const grid: Record<string, string> = {};
  for await (const line of file.readLines()) {
    const [, sx, sy, bx, by] = line
      .match(
        /^Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)$/,
      )!
      .map(Number);
    const d = Math.abs(sx - bx) + Math.abs(sy - by);
    sensors.push({
      x: sx,
      y: sy,
      d,
    });
    if (testCase === "example.txt") {
      grid[`${sx},${sy}`] = "S";
      grid[`${bx},${by}`] = "B";
      for (let dx = 0; dx <= d; dx++) {
        for (let dy = 0; dy <= d - dx; dy++) {
          const points = [
            { x: sx + dx, y: sy + dy },
            { x: sx - dx, y: sy + dy },
            { x: sx + dx, y: sy - dy },
            { x: sx - dx, y: sy - dy },
          ];
          for (let p of points) {
            const c = `${p.x},${p.y}`;
            grid[c] ||= "#";
          }
        }
      }
    }
  }
  if (testCase === "example.txt") {
    for (let y = 0; y <= 20; y++) {
      const row: string[] = [];
      for (let x = 0; x <= 20; x++) {
        row.push(grid[`${x},${y}`] ?? ".");
      }
      console.log(row.join(""));
    }
  }

  const bound = testCase === "example.txt" ? 20 : 4e6;
  for (let s of sensors) {
    for (let p of perimeter(s)) {
      if (p.x < 0 || p.x > bound || p.y < 0 || p.y > bound) continue;
      if (
        sensors.every((s) => Math.abs(s.x - p.x) + Math.abs(s.y - p.y) > s.d)
      ) {
        console.log(p);
        console.log(p.x * 4e6 + p.y);
        return;
      }
    }
  }
}

type Sensor = {
  x: number;
  y: number;
  d: number;
};
type Point = {
  x: number;
  y: number;
};

function* perimeter(sensor: Sensor): Generator<Point> {
  const radius = sensor.d + 1;
  console.log("sensor", sensor, "radius", radius);
  for (let dy = 0; dy <= radius; dy++) {
    const dx = radius - dy;
    yield { x: sensor.x + dx, y: sensor.y + dy };
    yield { x: sensor.x - dx, y: sensor.y + dy };
    yield { x: sensor.x + dx, y: sensor.y - dy };
    yield { x: sensor.x - dx, y: sensor.y - dy };
  }
}

part2();
