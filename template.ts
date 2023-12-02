#!/usr/bin/env ts-node

import fs from 'node:fs/promises'

async function main(part: 1 | 2) {
  const file = await fs.open('./10.txt')

  let gen = part === 1 ? part1() : part2();
  gen.next();
  for await (const line of file.readLines()) {
    gen.next(line);
  }
}

function* part1(): Generator {
   
}
function* part2(): Generator {
}

main(1);
