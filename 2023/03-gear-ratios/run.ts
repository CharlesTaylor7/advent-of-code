#!/usr/bin/env ts-node

import fs from 'node:fs/promises'
import path from 'node:path'

type TestCase = 
  'input.txt' 
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

function* partPerimeter(part: {row:number, col: number}): Generator<Point> {

  const d = [-1,0,1]
  for (let dx of d) {
    for (let dy of d) {
      if (dx !== 0 || dy !== 0) {
        yield { x: part.row + dx, y: part.col + dy }
      }
    }
  } 
}

// sparse grid rep
type Grid = {
  minX: number,
  maxX: number,
  minY: number,
  maxY: number,
  defaultTile: Tile,
  data: Record<string, Tile>
}
type Tile = '.' | '*' 
type Point = { x: number, y: number };

function show(grid: Grid) {
  const rows: string[] = []

  for (let y = grid.minY; y <= grid.maxY; y++) {
    const row: Tile[] = []
    for (let x = grid.minX; x <= grid.maxX; x++) {
      row.push(grid.data[`${x},${y}`] ?? '.')
    }
    rows.push(row.join(""))
  }
  
  console.log(rows.join("\n"))
}

function lookup(grid: Grid, point: Point): Tile {
  return grid.data[`${point.x},${point.y}`] ?? grid.defaultTile;
}

function update<T>(grid: Record<string, T>, point: Point, tile: T) {
  return grid[`${point.x},${point.y}`] = tile
}


part2('example2.txt');
