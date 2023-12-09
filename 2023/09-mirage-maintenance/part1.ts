#!/usr/bin/env ts-node

import fs from "node:fs/promises";
import path from "node:path";

type TestCase = "input.txt" | "example.txt";

async function main(testCase: TestCase = "example.txt") {
  const file = await fs.open(path.join(__dirname, testCase));

  let tally = 0;
  for await (let line of file.readLines()) {
    const row = Array.from(line.matchAll(/-?\d+/g), Number);
    const rows: number[][] = [];
    rows.push(row);

    let current = row;
    while (current.some((n) => n !== 0)) {
      const next = [];
      for (let i = 0; i < current.length - 1; i++) {
        next.push(current[i + 1] - current[i]);
      }
      rows.push(next);
      current = next;
    }

    // console.log(rows);

    for (let row of rows) {
      tally += row[row.length - 1] ?? 0;
    }
  }
  file.close();

  console.log(tally);
}

main("input.txt");
