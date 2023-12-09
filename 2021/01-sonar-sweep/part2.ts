#!/usr/bin/env ts-node

import fs from "node:fs/promises";
import path from "node:path";

type TestCase = "input.txt" | "example.txt";

async function main(testCase: TestCase = "example.txt") {
  const contents = await fs.readFile(path.join(__dirname, testCase), "utf-8");
  const nums = contents.trimEnd().split("\n").map(Number);

  let sum = nums[0] + nums[1];
  // + nums[2];
  let tally = 0;
  let previous = Number.POSITIVE_INFINITY;
  for (let i = 2; i < nums.length; i++) {
    sum += nums[i];
    tally += sum > previous ? 1 : 0;
    previous = sum;
    sum -= nums[i - 2];
  }

  console.log(tally);
}

main("input.txt");
