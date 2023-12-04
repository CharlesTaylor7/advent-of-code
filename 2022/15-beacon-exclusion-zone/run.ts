#!/usr/bin/env ts-node

import fs from 'node:fs/promises'
import path from 'node:path'

async function part1() {
  const file = await fs.open(path.join(__dirname, 'input.txt'));
  const row = 2_000_000

  const set = new Set()
  for await (const line of file.readLines()) {
    console.log(line)
    const [,sx,sy,bx,by] = line.match(/^Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)$/)!.map(Number)
    console.log({sx,sy,bx,by})
    if (sy === row) set.add(sx)
    //grid[`${sx},${sy}`] = 'S'
    //grid[`${bx},${by}`] = 'B'
    const manhattanDistance = Math.abs(sx - bx) + Math.abs(sy - by);
    if (row > sy + manhattanDistance) {
      continue
    }

    const dy = Math.abs(row - sy)
    const dx = manhattanDistance - dy
    for (let x = sx - dx; x <= sx + dx; x++) {
      if (by === row && x === bx) continue
      set.add(x)
    }
  }
  console.log(set.size)
}

type Sensor = {
  x: number,
  y: number,
  d: number,
}

async function part2() {
  const file = await fs.open(path.join(__dirname, 'input.txt'));

  const sensors: Sensor[] = []
  for await (const line of file.readLines()) {
    console.log(line)
    const [,sx,sy,bx,by] = line.match(/^Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)$/)!.map(Number)
    sensors.push({
      x: sx,
      y: sy,
      d: Math.abs(sx - bx) + Math.abs(sy - by),
    })
  }

  for (let sensor of s = 0; i < 16e12; i++) {b
    const x = i % 4e6; 
    const y = (i - x) / 4e6;

    if (sensors.every(s => Math.abs(s.x - x) + Math.abs(s.y - y) > s.d)) {
      console.log(i)
      return
    }
  }
}
part2()

