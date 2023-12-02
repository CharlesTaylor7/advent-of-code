#!/usr/bin/env ts-node

import fs from 'node:fs/promises'

async function part1() {
  const file = await fs.open('./08-example.txt')

  const grid: string[] = []
  for await (const line of file.readLines()) {
    grid.push(line);
  }
  countVisible(grid)
}

function countVisible(grid: string[]) {
  console.log(grid.join("\n"))
  const height = grid.length;
  const width = grid[0].length;

  let borderCount = 2 * height + 2 * width - 4;
  let set: Set<number> = new Set();

  const include = (i: number, j: number)  => set.add(j * width + i);

  let max = 0;
  // row by row
  for (let j = 1; j < height - 1; j++) {
    // left to right
    for (let i = 1; i < width - 1; i++) {
      if (grid[j][i] > grid[j][i-1]) {
        console.log("ltr", {i, j}, grid[j][i])
        include(i, j);
      }
    }

    // right to left
    for (let i = width - 2; i > 0; i--) {
      if (grid[j][i] > grid[j][i + 1]) {
        console.log("rtl", {i, j}, grid[j][i])
        include(i, j);
      }
    }
  }

  // column by column
  for (let i = 1; i < width - 1; i++) {
    // top to bottom
    for (let j = 1; j < height - 1; j++) {
      if (grid[j][i] > grid[j-1][i]) {
        console.log("ttb", {i, j}, grid[j][i])
        include(i, j);
      }
    }

    // bottom to top
    for (let j = height - 2; j > 0; j--) {
      if (grid[j][i] > grid[j + 1][i]) {
        console.log("btt", {i, j}, grid[j][i])
        include(i, j);
      }
    }
  }

  console.log(borderCount , set.size);
}

part1();
