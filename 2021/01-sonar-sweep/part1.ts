#!/usr/bin/env ts-node

import fs from "node:fs/promises";
import path from "node:path";

type TestCase = "input.txt" | "example.txt";

async function main(testCase: TestCase = "example.txt") {
  // stream line by line
  const file = await fs.open(path.join(__dirname, testCase));

  let tally = 0;
  let previous = Number.POSITIVE_INFINITY;
  for await (const line of file.readLines()) {
    const current = Number(line);
    tally += current > previous ? 1 : 0;

    previous = current;
  }
  file.close();

  console.log(tally);
}

main("input.txt");
