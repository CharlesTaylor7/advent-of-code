#!/usr/bin/env ts-node

import fs from "node:fs/promises";

async function main(part: 1 | 2) {
  const file = await fs.open("./10.txt");

  let gen = part === 1 ? part1() : part2();
  gen.next();
  for await (const line of file.readLines()) {
    gen.next(line);
  }
  console.log(gen.next().value);
}

function* part1(): Generator<unknown, number, string> {
  let X = 1;
  let queue = [0];
  let cycle = 0;
  let tally = 0;
  let line;

  while ((line = yield)) {
    const match = line.match(/^addx (.*)$/);
    if (match) {
      // console.log(line);
      queue.push(0, Number(match[1]));
    } else {
      queue.push(0);
    }
    runCycle(queue.shift() || 0);
  }
  for (let x of queue) {
    runCycle(x);
  }
  return tally;

  function runCycle(inc: number) {
    cycle++;
    X += inc;
    // console.log("cycle:", cycle, "X:", X);
    if ((cycle - 20) % 40 === 0) {
      const str = X * cycle;
      console.log("cycle:", cycle, "strength:", str);
      tally += str;
    }
  }
}

function* part2(): Generator<unknown, string, string> {
  let X = 1;
  let queue = [0];
  let cycle = 0;
  let line;
  let crt: string[] = [];
  while ((line = yield)) {
    const match = line.match(/^addx (.*)$/);
    if (match) {
      queue.push(0, Number(match[1]));
    } else {
      queue.push(0);
    }
    runCycle(queue.shift() || 0);
  }
  for (let x of queue) {
    runCycle(x);
  }

  return crt.join();

  function runCycle(inc: number) {
    if (cycle % 40 === 0) {
      crt.push("\n");
    }
    X += inc;
    crt.push(Math.abs(X - (cycle % 40)) <= 1 ? "#" : ".");
    cycle++;
  }
}

main(2);
