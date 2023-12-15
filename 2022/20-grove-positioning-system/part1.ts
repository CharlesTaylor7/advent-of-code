#!/usr/bin/env ts-node

import fs from "node:fs/promises";
import path from "node:path";

type TestCase = "input.txt" | "example.txt";

async function main(testCase: TestCase = "example.txt") {
  // stream line by line
  const file = await fs.open(path.join(__dirname, testCase));

  let initial: number[] = [];

  for await (const line of file.readLines()) {
    const n = Number(line);
    initial.push(n);
  }
  file.close();

  let shuffled: Shuffled = Array.from(initial, (value, id) => ({ value, id }));
  for (let id = 0; id < shuffled.length; id++) {
    //const value = initial[id];
    const index = shuffled.findIndex((s) => s.id === id);
    const value = shuffled[index].value;

    //for (let j =
    // console.log(value);
  }
}

type Shuffled = {
  id: number;
  value: number;
}[];

main("input.txt");
