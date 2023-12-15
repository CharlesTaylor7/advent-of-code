#!/usr/bin/env ts-node

import fs from "node:fs/promises";
import path from "node:path";

type TestCase = "input.txt" | "example.txt";

type Location = { row: number, col: number };
type Direction = 'N' | 'E'| 'W' |'S'
type Tile = 
  | '.' 
  | 'S'
  | Pipe

type Pipe = 
  | '|'  
  | '-'
  | '7'
  | 'J'
  | 'F'
  | 'L'

const pipes: Record<Pipe, [Direction, Direction]> = {
  '|': ['N', 'S'],
  '-': ['E', 'W'],
  'F': ['S', 'E'],
  '7': ['S', 'W'],
  'J': ['N', 'W'],
  'L': ['N', 'E'],
}

const opposite: Record<Direction, Direction> = {
  'N': 'S',
  'E': 'W',
  'W': 'E',
  'S': 'N',
}


async function main(testCase: TestCase = "example.txt") {

  let map: string[] = []
  let width = 0;
  let row = 0;
  let start = { row: -1, col: -1 };
  // stream line by line
  const file = await fs.open(path.join(__dirname, testCase));
  for await (const line of file.readLines()) {
    width = line.length;
    const match = line.match(/S/)
    console.log(line);
    if (match?.index !== undefined) {
      start = { row, col: match.index };
    }

    map.push(line);
    row++;
  }
  file.close();

  function lookup(loc: Location): Tile | undefined{
    const row = map[loc.row];
    if (!row) return undefined

    return row[loc.col] as Tile | undefined;
  }

  function checkPath(loc: Location, from: Direction, distance: number): number | null {
    console.log({loc, from, distance});
    const cell = lookup(loc);
    if (!cell) return null;
    else if (cell === '.') return null;
    else if (cell === 'S') return distance; 

    const dirs = pipes[cell];
    const i = dirs.findIndex(dir => dir === from)
    if (i === -1) return null;

    const nextDir = dirs[(i + 1) % 2];
    const c =  opposite[nextDir];
    
    advance(loc, nextDir);
    return checkPath(loc, c, distance+1)
  }

  function advance(current: Location, dir: Direction) {
    if (dir === 'N') current.row--
    else if (dir === 'S') current.row++
    else if (dir === 'E') current.col++
    else if (dir === 'W') current.col--
    else {
      dir satisfies never
    }
  }
  
  console.log("start", start);
  for (let d of ['N', 'E', 'W', 'S'] as Direction[]) {
    const copy = {...start};
    advance(copy, d);
    console.log("checking", d);
    const length = checkPath(copy, opposite[d], 1);
    if (length) {
      console.log(d, length);
    }
  }
}

main('input.txt');
