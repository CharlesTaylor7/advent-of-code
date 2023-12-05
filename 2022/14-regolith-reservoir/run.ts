#!/usr/bin/env ts-node
import fs from 'node:fs/promises'
import path from 'node:path'

type TestCase = 'input.txt' | 'example.txt'

type Gen<TReturn = undefined, TYield = undefined, TIn = string> = Generator<TYield, TReturn, TIn>

async function main(part: 1 | 2 = 1, testCase: TestCase = 'example.txt') {
  const file = await fs.open(path.join(__dirname, testCase));

  let gen = parseGrid();
  gen.next();
  for await (const line of file.readLines()) {
    gen.next(line);
  }
  const cave: Cave = gen.next().value!;
  const func = part === 1 ? part1 : part2;
  func(cave);
}

type Tile = '.' | '#' | 'o'
// grid is translated in the x direction to keep the size of the array down
type Cave = {
  minX: number,
  maxX: number,
  maxY: number,
  grid: Record<string, Tile>,
}
type Grid = Record<string, Tile>
type Point = [number, number]

function* parseGrid(): Gen<Cave> {
  let line: string;
  let grid: Grid = {};
  let minX: number = Number.POSITIVE_INFINITY;
  let maxX: number = Number.NEGATIVE_INFINITY;
  let maxY: number = Number.NEGATIVE_INFINITY;

  while ((line = yield) !== undefined) {
    let prev: Point | null = null
    for (let pair of line.split("->")) {
      const current: Point = pair.split(",").map(Number) as Point;
      const [x, y] = current;
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;

      grid[`${current[0]},${current[1]}`] = '#'
      if (prev !== null) {
        const dx = current[0] - prev[0]
        const dy = current[1] - prev[1]
        if (dx !== 0) {
          for (let x = prev[0]; x !== current[0]; x += Math.sign(dx)) {
            grid[`${x},${current[1]}`] = '#'
          }
        }
        else if (dy !== 0) {
          for (let y = prev[1]; y !== current[1]; y += Math.sign(dy)) {
            grid[`${current[0]},${y}`] = '#'
          }
        }
      }
      prev = current
    }
  }
  return { grid, minX, maxX, maxY };
}

function show(cave: Cave) {
  const rows: string[] = []

  for (let y = 0; y <= cave.maxY; y++) {
    const row: Tile[] = []
    for (let x = cave.minX; x <= cave.maxX; x++) {
      row.push(cave.grid[`${x},${y}`] ?? '.')
    }
    rows.push(row.join(""))
  }
  
  console.log(rows.join("\n"))
}

function lookup(grid: Grid, point: Point): Tile {
  return grid[`${point[0]},${point[1]}`] ?? '.'
}

function lookup2(cave: Cave, point: Point): Tile {
  if (point[1] >= cave.maxY + 2) return '#';

  return cave.grid[`${point[0]},${point[1]}`] ?? '.'
}

function update(grid: Grid, point: Point, tile: Tile) {
  return grid[`${point[0]},${point[1]}`] = tile
}

function part1(cave: Cave) {
  let tally = 0;
  while (true) {
    let sand: Point = [500, 0]
    while (true) {
      if (sand[1] >= cave.maxY) {
        console.log(tally)
        return
      }
      sand[1]++
      if (lookup(cave.grid, sand) === '.') {
        continue
      }
      sand[0]--
      if (lookup(cave.grid, sand) === '.') {
        continue
      }
      sand[0] += 2
      if (lookup(cave.grid, sand) === '.') {
        continue
      }
      sand[0]--
      sand[1]--
      
      tally++
      update(cave.grid, sand, 'o')
      break
    }
  }
}

function part2(cave: Cave) {
  let tally = 0;
  while (true) {
    let sand: Point = [500, 0]
    while (true) {
      sand[1]++
      if (lookup2(cave, sand) === '.') {
        continue
      }
      sand[0]--
      if (lookup2(cave, sand) === '.') {
        continue
      }
      sand[0] += 2
      if (lookup2(cave, sand) === '.') {
        continue
      }
      sand[0]--
      sand[1]--
      
      tally++
      if (sand[0] === 500 && sand[1] === 0) {
        console.log(tally)
        return
      }
      update(cave.grid, sand, 'o')
      break
    }
  }
}
main(2, "input.txt");
