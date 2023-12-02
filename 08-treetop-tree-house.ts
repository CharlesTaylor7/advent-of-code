#!/usr/bin/env ts-node

import fs from 'node:fs/promises'

async function part1() {
  const file = await fs.open('./08-example.txt')

  const grid: number[][] = []
  for await (const line of file.readLines()) {
    grid.push(line.split("").map(Number));
  }
  console.log(grid)
  countVisible(grid)
}

function countVisible(grid: number[][]) {
  console.log(grid.join("\n"))
  const height = grid.length;
  const width = grid[0].length;

  let borderCount = 2 * height + 2 * width - 4;
  let set: Set<number> = new Set();

  const include = (i: number, j: number)  => set.add(j * width + i);

  let max = -1;
  // row by row
  for (let j = 0; j < height; j++) {
    // left to right
    max = -1;
    for (let i = 0; i < width; i++) {
      if (grid[j][i] > max) {
        console.log("ltr", {i, j}, grid[j][i])
        include(i, j);
      }
    }

    // right to left
    max = -1;
    for (let i = width - 1; i > 0; i--) {
      if (grid[j][i] > grid[j][i + 1]) {
        console.log("rtl", {i, j}, grid[j][i])
        include(i, j);
      }
    }
  }

  // column by column
  for (let i = 1; i < width; i++) {
    // top to bottom
    max = -1;
    for (let j = 1; j < height; j++) {
      if (grid[j][i] > grid[j-1][i]) {
        console.log("ttb", {i, j}, grid[j][i])
        include(i, j);
      }
    }

    // bottom to top
    max = -1;
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
