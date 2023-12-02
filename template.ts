#!/usr/bin/env ts-node

import fs from 'node:fs/promises'
import path from 'node:path'

async function main(part: 1 | 2) {
  const file = await fs.open(path.join(__dirname, 'input.txt'))

  let gen = part === 1 ? part1() : part2();
  gen.next();
  for await (const line of file.readLines()) {
    console.log(line)
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

main(1);
