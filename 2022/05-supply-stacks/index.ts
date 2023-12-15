#!/usr/bin/env ts-node

import fs from "node:fs/promises";

type State = "layout" | "operating";

async function part1() {
  const file = await fs.open("./05-supply-stacks.txt");

  const rawCrateRows: string[] = [];

  let state: State = "layout";
  const stacks: string[][] = [];

  for await (const line of file.readLines()) {
    if (state === "layout") {
      if (line.startsWith(" 1")) {
        const r = /(\d+)\s*$/;
        const numStacks = Number(r.exec(line)![1]);
        for (let i = 0; i < numStacks; i++) {
          stacks.push([]);
        }

        const height = rawCrateRows.length;
        for (let j = 0; j < height; j++) {
          // iterate in reverse
          const row = rawCrateRows[height - j - 1];
          let i = 0;
          let rawIndex = 1;
          while (i < numStacks && rawIndex < row.length) {
            if (row[rawIndex] !== " ") {
              stacks[i].push(row[rawIndex]);
            }
            i++;
            rawIndex += 4;
          }
        }
        console.log("initial");
        console.log(stacks, "\n");
        state = "operating";
      } else {
        rawCrateRows.push(line);
      }
    } else {
      const [c, src, trgt] = Array.from(line.matchAll(/\d+/g));
      if (c === undefined) continue;

      const count = Number(c[0]);
      const source = stacks[Number(src[0]) - 1];
      const target = stacks[Number(trgt[0]) - 1];
      const elements = source.splice(source.length - count, count);
      elements.reverse();
      target.push(...elements);
      console.log("after", line);
      console.log(stacks, "\n");
    }
  }
  console.log(stacks.map((s) => s.pop()).join(""));
}

async function part2() {
  const file = await fs.open("./05-supply-stacks.txt");

  const rawCrateRows: string[] = [];

  let state: State = "layout";
  const stacks: string[][] = [];

  for await (const line of file.readLines()) {
    if (state === "layout") {
      if (line.startsWith(" 1")) {
        const r = /(\d+)\s*$/;
        const numStacks = Number(r.exec(line)![1]);
        for (let i = 0; i < numStacks; i++) {
          stacks.push([]);
        }

        const height = rawCrateRows.length;
        for (let j = 0; j < height; j++) {
          // iterate in reverse
          const row = rawCrateRows[height - j - 1];
          let i = 0;
          let rawIndex = 1;
          while (i < numStacks && rawIndex < row.length) {
            if (row[rawIndex] !== " ") {
              stacks[i].push(row[rawIndex]);
            }
            i++;
            rawIndex += 4;
          }
        }
        console.log("initial");
        console.log(stacks, "\n");
        state = "operating";
      } else {
        rawCrateRows.push(line);
      }
    } else {
      const [c, src, trgt] = Array.from(line.matchAll(/\d+/g));
      if (c === undefined) continue;

      const count = Number(c[0]);
      const source = stacks[Number(src[0]) - 1];
      const target = stacks[Number(trgt[0]) - 1];
      const elements = source.splice(source.length - count, count);
      target.push(...elements);
      console.log("after", line);
      console.log(stacks, "\n");
    }
  }
  console.log(stacks.map((s) => s.pop()).join(""));
}
part2();
