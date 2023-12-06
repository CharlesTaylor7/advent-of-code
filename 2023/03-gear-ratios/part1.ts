#!/usr/bin/env ts-node

import fs from 'node:fs/promises'
import path from 'node:path'

type TestCase = 
  | 'input.txt' 
  | 'example.txt'
  | 'example2.txt'


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


part1('input.txt');
