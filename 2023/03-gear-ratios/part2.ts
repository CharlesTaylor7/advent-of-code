#!/usr/bin/env ts-node

import fs from 'node:fs/promises'
import path from 'node:path'

type TestCase = 
  | 'input.txt' 
  | 'example.txt'
  | 'example2.txt'


async function part2(testCase: TestCase = 'example.txt') {
  const file = await fs.open(path.join(__dirname, testCase));

  const numbers: Record<string, number> = {}
  const parts: { y: number, x: number }[] = []
  
  let y = 0;
  for await (const line of file.readLines()) {
    for (let match of line.matchAll(/\d+/g)) {
      for (let dx = 0; dx < match[0].length; dx++) {
        const x = match.index! + dx
        numbers[`${x},${y}`] = Number(match[0])
      }
    }
    for (let match of line.matchAll(/[^\d\.]/g)) {
      parts.push({ y, x: match.index!});
    }
    y++
  }
  //console.log(JSON.stringify(parts, (_,e) => e, 2));
  //console.log(JSON.stringify(numbers, (_,e) => e, 2))

  let tally = 0;
  for (let part of parts) {
    const nums: Set<number> = new Set()
    for (let point of partPerimeter(part)) {
      const n = numbers[`${point.x},${point.y}`]
      if (n !== undefined) nums.add(n)
    }
    if (nums.size === 2) {
      console.log(nums)
      const arr = Array.from(nums)
      tally += arr[0] * arr[1];
    }
  }
  console.log(tally)
  console.log(tally + '\nfe\nfi\nfo\nfum\n')
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

type Point = { x: number, y: number };


part2('input.txt');
