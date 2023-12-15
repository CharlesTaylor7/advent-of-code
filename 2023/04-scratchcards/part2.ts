#!/usr/bin/env ts-node

import fs from "node:fs/promises";
import path from "node:path";

type TestCase = "input.txt" | "example.txt";

async function main(testCase: TestCase = "example.txt") {
  const file = await fs.open(path.join(__dirname, testCase));

  let row = 0;
  let counts = [0];
  for await (const line of file.readLines()) {
    row++;
    counts[row] ||= 1;
    const {
      card,
      winning: rawWin,
      mine: rawMine,
    } = line.match(/Card\s+(?<card>\d+):\s+(?<winning>.*)\s+\|\s+(?<mine>.*)/)!
      .groups as Record<string, string>;

    if (Number(card) !== row) {
      throw new Error();
    }

    const winning = new Set(rawWin.split(/\s+/));
    let score = 0;
    for (let num of rawMine.split(/\s+/)) {
      if (winning.has(num)) {
        score++;
      }
    }
    for (let i = 0; i < score; i++) {
      counts[row + i + 1] = (counts[row + i + 1] ?? 1) + counts[row];
    }
  }
  console.log(counts.reduce((a, b) => a + b, 0));
}

main("input.txt");
