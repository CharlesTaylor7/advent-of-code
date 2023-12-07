#!/usr/bin/env ts-node

import fs from "node:fs/promises";
import path from "node:path";

type TestCase = "input.txt" | "example.txt";

type Point = [number, number, number];
async function main(testCase: TestCase = "example.txt") {
  const points: Point[] = [];
  const set = new Set<string>();

  const file = await fs.open(path.join(__dirname, testCase));
  for await (const line of file.readLines()) {
    const point = line.split(",").map(Number) as Point;
    points.push(point);
    set.add(line);
  }
  file.close();

  let tally = 0;
  let d = [-1, 1];
  for (let point of points) {
    for (let dx of d) {
      const copy: Point = [...point];
      copy[0] += dx;
      if (!set.has(copy.join(","))) tally++;
    }
    for (let dy of d) {
      const copy: Point = [...point];
      copy[1] += dy;
      if (!set.has(copy.join(","))) tally++;
    }
    for (let dz of d) {
      const copy: Point = [...point];
      copy[2] += dz;
      if (!set.has(copy.join(","))) tally++;
    }
  }
  console.log(tally);
}

main("input.txt");
