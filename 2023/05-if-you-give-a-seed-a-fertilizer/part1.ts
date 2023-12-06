#!/usr/bin/env ts-node

import fs from 'node:fs/promises'
import path from 'node:path'

type TestCase = 'input.txt' | 'example.txt'

type Rule = {
  src: number,
  dest: number,
  count: number,
}

async function main(testCase: TestCase = 'example.txt') {
  const file = await fs.open(path.join(__dirname, testCase));

  let values: number[] = []
  let row = 0;
  let currentRules: Rule[] = []
  let currentMapping: string | undefined;
  for await (const line of file.readLines()) {
    row++
    if (row === 1) {
      const [,seeds] = line.match(/seeds:\s+(.*)/)!
      values = seeds.split(/\s+/).map(Number)
    }
    else if (line.match(/map:$/)) {
      currentMapping = line
      currentRules = []
    }
    else if (!line) {
      // apply rules
      values = values.map(v => {
        const rule = currentRules.find(rule => v >= rule.src && v < rule.src +rule.count)
        return rule ? rule.dest + (v - rule.src) : v
      })
    }
    else {
      const [dest, src, count] = line.split(/\s+/).map(Number)
      currentRules.push({src, dest, count})
    }
  }

  values.sort((a,b) => a - b);
  console.log(values);
}

main('example.txt');
