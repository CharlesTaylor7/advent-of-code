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
  let index = 1;
  let left: Packet | null = null
  let right: Packet | null = null
  let tally = 0;
  while ((line = yield) !== undefined) {
    if (line === '') {
      left = null
      right = null
      index++;
      continue;
    }
    const p = parse(line);    
    if (left === null) left = p
    else if (right === null) {
      right = p
      tally += compare(left, right) === 'LT' ? index : 0
    }
  }
  console.log(tally)
}

type Packet = (number | Packet)[]
function parse(line: string): Packet {
  let current: Packet = []
  let crumbs: Packet[] = []
  let rawNum = ''
  function pushNum() {
    if (rawNum.length) {
      current.push(Number(rawNum))
      rawNum = ''
    }
  }
  for (let c of line) {
    if (isNum(c)) {
      rawNum += c
    }
    if (c === ',') {
      pushNum()
    }
    if (c === '[') {
      const child: Packet = []
      current.push(child)
      crumbs.push(current);
      current = child;
    }
    if (c === ']') {
      pushNum()
      current = crumbs.pop()!
    }
  }
  pushNum()
  return current
}

function compare(left: Packet, right: Packet): 'LT' | 'EQ' | 'GT' {
  for (let i = 0; i < Math.min(left.length, right.length); i++) {
    if (typeof left[i] === 'number' && typeof right[i] === 'number') {
      if (left[i] < right[i]) {
        return 'LT'
      }
      if (left[i] > right[i]) {
        return 'GT'
      }
    }

    else if (typeof left[i] === 'object' && typeof right[i] === 'object') {
      const cmp = compare(left[i] as Packet, right[i] as Packet);
      if (cmp != 'EQ') return cmp
    }
    else {
      const l = typeof left[i] === 'number' ? [left[i]] : left[i]
      const r = typeof right[i] === 'number' ? [right[i]] : right[i]

      const cmp = compare(l as Packet, r as Packet);
      if (cmp != 'EQ') return cmp
    }
  }
  if (left.length < right.length) return 'LT'
  if (left.length > right.length) return 'GT'
  return 'EQ'
}

function isNum(c: string) {
  return c >= '0' && c <= '9'
}

function* part2(): Gen {
  let line: string;
  let index = 1;
  let left: Packet | null = null
  let right: Packet | null = null
  let tally = 0;
  while ((line = yield) !== undefined) {
    if (line === '') {
      left = null
      right = null
      index++;
      continue;
    }
    const p = parse(line);    
    if (left === null) left = p
    else if (right === null) {
      right = p
      tally += compare(left, right) === 'LT' ? index : 0
    }
  }
  console.log(tally)
}

main(1, 'input.txt');
