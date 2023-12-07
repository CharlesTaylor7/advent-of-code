#!/usr/bin/env ts-node

import fs from "node:fs/promises";
import path from "node:path";

type TestCase = "input.txt" | "example.txt";

async function main(testCase: TestCase = "example.txt") {
  const contents = await fs.readFile(path.join(__dirname, testCase), "utf-8");

  console.log(contents);
}

main();
line;
