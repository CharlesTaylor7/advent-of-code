#!/usr/bin/env ts-node

import fs from "node:fs/promises";

async function main() {
  const file = await fs.open("./08.txt");

  const grid: number[][] = [];
  for await (const line of file.readLines()) {
    grid.push(line.split("").map(Number));
  }
  part2(grid);
}

function part1(grid: number[][]) {
  //console.log(grid)
  const height = grid.length;
  const width = grid[0].length;

  let set: Set<number> = new Set();
  const include = (i: number, j: number) => set.add(j * width + i);

  let max = -1;
  // row by row
  for (let j = 0; j < height; j++) {
    // left to right
    max = -1;
    for (let i = 0; i < width; i++) {
      if (grid[j][i] > max) {
        max = grid[j][i];
        console.log("ltr", { i, j }, grid[j][i]);
        include(i, j);
      }
    }

    // right to left
    max = -1;
    for (let i = width - 1; i > 0; i--) {
      if (grid[j][i] > max) {
        max = grid[j][i];
        console.log("rtl", { i, j }, grid[j][i]);
        include(i, j);
      }
    }
  }

  // column by column
  for (let i = 1; i < width; i++) {
    // top to bottom
    max = -1;
    for (let j = 0; j < height; j++) {
      if (grid[j][i] > max) {
        max = grid[j][i];
        console.log("ttb", { i, j }, grid[j][i]);
        include(i, j);
      }
    }

    // bottom to top
    max = -1;
    for (let j = height - 1; j > 0; j--) {
      if (grid[j][i] > max) {
        max = grid[j][i];
        console.log("btt", { i, j }, grid[j][i]);
        include(i, j);
      }
    }
  }

  console.log(set.size);
}

function part2(grid: number[][]) {
  console.log(grid);
  const height = grid.length;
  const width = grid[0].length;

  let maxScore = 0;

  for (let j = 1; j < height - 1; j++) {
    for (let i = 1; i < width - 1; i++) {
      // to the left
      let d1 = 0;
      for (let k = i - 1; k >= 0; k--) {
        if (grid[j][i] > grid[j][k]) {
          d1++;
        } else {
          d1++;
          break;
        }
      }

      // to the right
      let d2 = 0;
      for (let k = i + 1; k < width; k++) {
        if (grid[j][i] > grid[j][k]) {
          d2++;
        } else {
          d2++;
          break;
        }
      }

      // downward
      let d3 = 0;
      for (let k = j + 1; k < height; k++) {
        if (grid[j][i] > grid[k][i]) {
          d3++;
        } else {
          d3++;
          break;
        }
      }

      // upward
      let d4 = 0;
      for (let k = j - 1; k >= 0; k--) {
        if (grid[j][i] > grid[k][i]) {
          d4++;
        } else {
          d4++;
          break;
        }
      }

      const score = d1 * d2 * d3 * d4;
      console.log({ i, j, score, d1, d2, d3, d4 });
      if (score > maxScore) {
        maxScore = score;
      }
    }
  }

  console.log(maxScore);
}

main();
