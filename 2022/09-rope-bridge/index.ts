#!/usr/bin/env ts-node

import fs from 'node:fs/promises'

type Knot = {i:number, j: number}

function move(head: Knot, tail: Knot) {
  const dx = head.i - tail.i
  const dy = head.j - tail.j
  if (Math.abs(dx) <= 1 && Math.abs(dy) <= 1) {
    return
  } 

  tail.i += Math.sign(dx)
  tail.j += Math.sign(dy)
}


async function main() {
  const visited: Set<string> = new Set();
  visited.add('0_0')

  const segments: Knot[] = Array.from({length: 10} , () => ({i:0,j:0}));
  const head = segments[0]

  const file = await fs.open('./09.txt')
  for await (const line of file.readLines()) {
    const [dir, c] = line.split(" ");
    const count = Number(c)
    for (let i = 0; i < count; i++) {
      if (dir === 'U') {
        head.j--
      }
      else if (dir === 'D') {
        head.j++
      }
      else if (dir === 'L') {
        head.i--
      }
      else if (dir === 'R') {
        head.i++
      }
      for (let k = 1; k < segments.length; k++) {
        move(segments[k-1], segments[k]);
      }
      visited.add(`${segments[9].i}_${segments[9].j}`);
    }
  }
  console.log(visited.size);
}

function show(segments: Knot[]) {
  const grid = Array.from(
    { length: 20}, 
    () => Array.from(
      { length: 20 },
      () => '.' 
    )
  );

  for (let k = 0; k < segments.length; k++) {
    const s = segments[k]
    grid[s.j + 10][s.i + 10] = String(k)
  }
  grid[segments[0].j + 10][segments[0].i + 10] = 'H'
  grid.reverse();
  console.log(grid.map(row => row.join("")).join("\n"))
}

main();
