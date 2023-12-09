#!/usr/bin/env ts-node

import fs from "node:fs/promises";
import path from "node:path";

type TestCase = "input.txt" | "example.txt";

async function main(testCase: TestCase = "example.txt") {
  // stream line by line
  const file = await fs.open(path.join(__dirname, testCase));

  for await (const line of file.readLines()) {
    console.log(line);
  }
  file.close();

  // or go all at once
  const contents = await fs.readFile(path.join(__dirname, testCase), "utf-8");

  console.log(contents);
}

main();
