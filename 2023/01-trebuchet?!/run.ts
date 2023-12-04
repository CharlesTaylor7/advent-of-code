#!/usr/bin/env ts-node

import fs from 'node:fs/promises'
import path from 'node:path'

type TestCase = 'input.txt' | 'example.txt' | 'example2.txt'

async function part1(testCase: TestCase = 'example.txt') {
  const file = await fs.open(path.join(__dirname, testCase));

  let tally = 0;
  for await (const line of file.readLines()) {
    let first: string | undefined
    let last: string | undefined
    for (let c of line) {
      if (c >= '0' && c <= '9') {
        first ||= c 
        last = c
      }
    }
    tally += Number(first) * 10 + Number(last);
  }
  console.log(tally)
}

async function part2(testCase: TestCase = 'example.txt') {
  const file = await fs.open(path.join(__dirname, testCase));

  let tally = 0;
  const r = /\d|one|two|three|four|five|six|seven|eight|nine/g
  const nameToNum = {
    'one': 1,
    'two': 2,
    'three': 3,
    'four': 4,
    'five': 5,
    'six': 6,
    'seven': 7,
    'eight': 8,
    'nine': 9,
  } as Record<string, number>
  for await (const line of file.readLines()) {
    let first: string | undefined
    let last: string | undefined
    let match: RegExpExecArray | null;
    while (match = r.exec(line)) {
      first ||= match[0] 
      last = match[0]
    }
    let tens = nameToNum[first!] ?? Number(first)
    let ones = nameToNum[last!] ?? Number(last)
    console.log({line, first, last, tens, ones})
    tally += tens * 10 + ones
  }
  console.log(tally)
}

part2('example2.txt');
