#!/usr/bin/env ts-node

import fs from 'node:fs/promises'
import path from 'node:path'

type TestCase = 'input.txt' | 'example.txt'

type Num = {
  value: number,
  row: number,
  colStart: number,
  colEnd: number,
}

async function part1(testCase: TestCase = 'example.txt') {
  const file = await fs.open(path.join(__dirname, testCase));

  const numbers: Num[] = []
  const parts: Record<string, string> = {};
  
  let row = 0;
  let width = 0;

  for await (const line of file.readLines()) {
    width = line.length;
    for (let match of line.matchAll(/\d+/g)) {
      numbers.push({
        value: Number(match[0]),
        row,
        colStart: match.index!,
        colEnd: match.index! + match[0].length - 1
      })
    }
    for (let match of line.matchAll(/[^\d\.]/g)) {
      parts[`${row},${match.index!}`] = match[0]
    }
    row++
  }

  let tally = 0;
  loop: for (let num of numbers) {
    for (let loc of numPerimeter(num)) {
      if (parts[`${loc.row},${loc.col}`]) {
        tally += num.value;
        continue loop
      }
    }
  }
  console.log(tally)
}

function* numPerimeter(n: Num): Generator<{ row: number, col: number }> {
  for (let col = n.colStart - 1; col <= n.colEnd + 1; col++) {
    yield { row: n.row - 1, col }
    yield { row: n.row + 1, col }
  }
  yield { row: n.row, col: n.colStart - 1 }
  yield { row: n.row, col: n.colEnd + 1 }
}


async function part2(testCase: TestCase = 'example.txt') {
  const file = await fs.open(path.join(__dirname, testCase));

  const numbers: Record<string, number> = {}
  const parts: { row: number, col: number }[] = []
  
  let row = 0;
  for await (const line of file.readLines()) {
    for (let match of line.matchAll(/\d+/g)) {
      for (let dx = 0; dx < match[0].length; dx++) {
        const col = match.index! + dx
        numbers[`${row},${col}`] = Number(match[0])
      }
    }
    for (let match of line.matchAll(/\*/g)) {
      parts.push({ row, col: match.index!});
    }
    row++
  }
  console.log(JSON.stringify(parts, (_,e) => e, 2));
  console.log(JSON.stringify(numbers, (_,e) => e, 2))

  let tally = 0;
  for (let part of parts) {
    const nums: Set<number> = new Set()
    for (let loc of partPerimeter(part)) {
      const n = numbers[`${loc.row},${loc.col}`]
      if (n !== undefined) nums.add(n)
    }
    if (nums.size === 2) tally += Array.from(nums).reduce((a, b) => a * b, 1)
  }
  console.log(tally)
}

function* partPerimeter(part: {row:number, col: number}): Generator<{ row: number, col: number }> {

  const d = [-1,0,1]
  for (let dx of d) {
    for (let dy of d) {
      if (dx !== 0 || dy !== 0) {
        yield { row: part.row + dx, col: part.col + dy }
      }
    }
  } 
}



part2('input.txt');
