#!/usr/bin/env ts-node

import fs from 'node:fs/promises'

async function part1() {
  const file = await fs.open('./05.txt')

  for await (const line of file.readLines()) {
    console.log(line)
  }
}

part1();
