#!/usr/bin/env ts-node

import fs from "node:fs/promises";
import path from "node:path";

type TestCase = "input.txt" | "example.txt";

type Location = Readonly<{ 
  row: number; col: number 
}>;
type Direction = 'N' | 'E' | 'W' | 'S';
type Tile = '.' | 'S' | Pipe;

type Pipe = '|' | '-' | '7' | 'J' | 'F' | 'L';

const directions: Direction[] = ['N', 'E', 'W', 'S'];
const pipes: Record<Pipe, [Direction, Direction]> = {
  '|': ['N', 'S'],
  '-': ['E', 'W'],
  'F': ['S', 'E'],
  '7': ['S', 'W'],
  'J': ['N', 'W'],
  'L': ['N', 'E'],
};

const opposite: Record<Direction, Direction> = {
  N: 'S',
  E: 'W',
  W: 'E',
  S: 'N',
};


async function parse(testCase: TestCase): Promise<[string[], Location]> {
  let map: string[] = [];
  let width = 0;
  let row = 0;
  let start = { row: -1, col: -1 };
  // stream line by line
  const file = await fs.open(path.join(__dirname, testCase));
  for await (const line of file.readLines()) {
    width = line.length;
    const match = line.match(/S/);
    // console.log(line);
    if (match?.index !== undefined) {
      start = { row, col: match.index };
    }

    map.push(line);
    row++;
  }
  file.close();
  return [map, start];
}


async function main(testCase: TestCase = "example.txt") {
  const [map, start] = await parse(testCase);

  function lookup(loc: Location): Tile | undefined {
    const row = map[loc.row];
    if (!row) return undefined;

    return row[loc.col] as Tile | undefined;
  }

  function checkPath(loc: Location, from: Direction): [Location, Direction] | boolean {
    // console.log({loc, from});
    const cell = lookup(loc);
    if (!cell) return false;
    else if (cell === ".") return false;
    else if (cell === "S") return true;

    const dirs = pipes[cell];
    const i = dirs.findIndex((dir) => dir === from);
    if (i === -1) return false;

    const nextDir = dirs[(i + 1) % 2];
    const c = opposite[nextDir];

    return [advance(loc, nextDir), c];
  }

  function advance(current: Location, dir: Direction): Location {
    if (dir === "N") return ({ row: current.row - 1, col: current.col });
    else if (dir === "S") return ({ row: current.row + 1, col: current.col });
    else if (dir === "E") return ({ row: current.row, col: current.col + 1 });
    else if (dir === "W") return ({ row: current.row, col: current.col - 1 });
    else {
      dir satisfies never;
      throw new Error();
    }
  }

  type PathState = {
    locations: Location[];
    from: Direction | false;
  };

  const paths: PathState[] = [];
  for (let d of directions) {
    paths.push({ 
      locations: [start, advance(start, d)], 
      from: opposite[d]
    });
  }

  for (let d = 1; ; d++) {
    for (let i = 0; i < paths.length; i++) {
      const { locations, from } = paths[i];
      const loc = locations[locations.length - 1];
      if (!from) continue;
      const next = checkPath(loc, from);
      if (next === true) {
        console.log("path length", d);
        console.log("furthest length", d / 2);
        return;
      }
      else if (next === false) {
        paths[i].from = false 
      }
      else {
        const [l,d] = next;
        paths[i].locations.push(l);
        paths[i].from = d;
      }
    }
  }
}

main("input.txt");
