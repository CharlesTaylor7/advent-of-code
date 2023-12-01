#!/usr/bin/env ts-node

import fs from 'node:fs/promises'

async function part1() {
  const file = await fs.open('./05-supply-stacks.txt')

  let total = 0
  for await (const line of file.readLines()) {
    console.log(line)
  }
  console.log(total);
}
part1();
