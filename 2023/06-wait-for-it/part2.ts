#!/usr/bin/env ts-node

import fs from "node:fs/promises";
import path from "node:path";

type TestCase = "input.txt" | "example.txt";

async function main(testCase: TestCase = "example.txt") {
  const file = await fs.open(path.join(__dirname, testCase));

  const nums: number[] = [];
  for await (const line of file.readLines()) {
    nums.push(Number(Array.from(line.matchAll(/\d+/g)).join("")));
  }

  let time = nums[0];
  let distance = nums[1];
  console.log(countWaysToWin(time, distance));
}

// const cache = []
function countWaysToWin(time: number, distance: number): number {
  let tally = 0;
  for (let i = 1; i < time - 1; i++) {
    if (distanceTraveled(time, i) > distance) {
      tally++;
    }
  }
  return tally;
}

function distanceTraveled(time: number, held: number): number {
  return (time - held) * held;
}

main("input.txt");
