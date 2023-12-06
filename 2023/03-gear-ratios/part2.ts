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

type Point = { x: number, y: number };
async function part2(testCase: TestCase = 'example.txt') {
  const file = await fs.open(path.join(__dirname, testCase));

  const numbers: Record<string, Num> = {}
  const parts: { y: number, x: number }[] = []
  
  let y = 0;
  for await (const line of file.readLines()) {
    for (let match of line.matchAll(/\d+/g)) {
      for (let dx = 0; dx < match[0].length; dx++) {
        const x = match.index! + dx
        numbers[`${x},${y}`] = ({
          value: Number(match[0]),
          row: y,
          colStart: match.index!,
          colEnd: match.index! + match[0].length - 1
        })
      }
    }

    for (let match of line.matchAll(/\*/g)) {
      parts.push({ y, x: match.index!});
    }
    y++
  }

  let tally = 0;
  for (let part of parts) {
    const coords: Set<string> = new Set()
    for (let point of partPerimeter(part)) {
      const n = numbers[`${point.x},${point.y}`]
      if (n !== undefined) {
        coords.add(`${n.colStart},${n.row}`);
      }
    }
    if (coords.size === 2) {
      const [a, b] = Array.from(coords)
      tally += numbers[a]!.value * numbers[b]!.value
    }
  }
  console.log(tally)
}

function* partPerimeter(part: Point): Generator<Point> {
  const d = [-1,0,1]
  for (let dx of d) {
    for (let dy of d) {
      if (dx !== 0 || dy !== 0) {
        yield { x: part.x + dx, y: part.y + dy }
      }
    }
  } 
}

part2('input.txt');
