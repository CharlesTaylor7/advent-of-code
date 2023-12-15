#!/usr/bin/env ts-node

import fs from "node:fs/promises";
import path from "node:path";

type TestCase = "input.txt" | "example.txt";

async function part1(testCase: TestCase = "example.txt") {
  const file = await fs.open(path.join(__dirname, testCase));

  let tally = 0;
  for await (const line of file.readLines()) {
    const { winning: rawWin, mine: rawMine } = line.match(
      /Card\s+\d+:\s+(?<winning>.*)\s+\|\s+(?<mine>.*)/,
    )!.groups as Record<string, string>;

    const winning = new Set(rawWin.split(/\s+/));
    //console.log(winning)
    let score = 0.5;
    for (let num of rawMine.split(/\s+/)) {
      //console.log(num)
      if (winning.has(num)) {
        score *= 2;
      }
    }
    //console.log({ score, winning, rawMine })
    tally += Math.floor(score);
  }
  console.log(tally);
}

//part1('example.txt');
part1("input.txt");
