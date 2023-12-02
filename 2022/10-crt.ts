#!/usr/bin/env ts-node

import fs from 'node:fs/promises'

async function main(part: 1 | 2) {
  const file = await fs.open('./10.txt')

  let gen = part === 1 ? part1() : part2();
  console.log("main", gen.next());
  for await (const line of file.readLines()) {
    console.log("main", gen.next(line));
  }
}

function* part1(): Generator<number> {
  console.log("gen", yield 1 )
  console.log("gen", yield 2)
}
function* part2(): Generator<number> {
  console.log("gen", yield 1 )
  console.log("gen", yield 2)
}

main(1);
