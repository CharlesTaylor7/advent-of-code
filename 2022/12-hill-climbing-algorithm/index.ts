#!/usr/bin/env ts-node

import fs from 'node:fs/promises'
import path from 'node:path'

async function main(part: 1 | 2 = 1, testCase: string = 'example.txt') {
  const file = await fs.open(path.join(__dirname, testCase));

  let gen = part === 1 ? part1() : part2();
  gen.next();
  for await (const line of file.readLines()) {
    gen.next(line);
  }
  gen.next();
}

function* part1(): Generator<unknown, unknown, string> {
  let line: string;
  while (line = yield) {
    console.log(line)
  }
  return
}

function* part2(): Generator {

}

main();
