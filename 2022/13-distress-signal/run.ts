#!/usr/bin/env ts-node

import fs from 'node:fs/promises'
import path from 'node:path'

type TestCase = 'input.txt' | 'example.txt'
async function main(part: 1 | 2 = 1, testCase: TestCase = 'example.txt') {
  const file = await fs.open(path.join(__dirname, testCase));

  let gen = part === 1 ? part1() : part2();
  gen.next();
  for await (const line of file.readLines()) {
    gen.next(line);
  }
  gen.next();
}

type Gen<TReturn = undefined, TYield = undefined, TIn = string> = Generator<TYield, TReturn, TIn>

function* part1(): Gen {
  let line: string;
  while ((line = yield) !== undefined) {
    console.log(line)
  }
  return
}

function* part2(): Gen {

}

main(1);
