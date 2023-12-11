#!/usr/bin/env ts-node

import { dir } from "node:console";
import fs from "node:fs/promises";
import path from "node:path";

type TestCase = "input.txt" | "example.txt";

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
    if (match?.index !== undefined) {
      start = { row, col: match.index };
    }

    map.push(line as string[]);
    row++;
  }
  file.close();

  function lookup(loc: Location): Tile {
    return map[loc.row][loc.col] as Tile
  }
  function checkPath(current: Location, direction: Direction): boolean {
    const cell = map[current.row][current.col];
    if (cell === '.') return false;
    if (cell === 'S') return true; 

    if (cell === '-') {
      if (direction == 'R') {
        return checkPath({
            row: current.row, 
            col: current.col + 1 
          }, 
          'R'
        )
      }
      if (direction == 'L') {
        return checkPath({
            row: current.row, 
            col: current.col - 1 
          }, 
          'L'
        )
      }
      return false;
    }
  }

  const toVisit = [start];

}

type Location = { row: number, col: number };
type Direction = 'L' | 'R'| 'U' |'D'
type Tile = 
  | '.' 
  | '|'  
  | '-'
  | '7'
  | 'J'
  | 'F'
  | 'L'
  | 'S'

main();
