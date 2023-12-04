#!/usr/bin/env ts-node

import fs from 'node:fs/promises'
import path from 'node:path'

type TestCase = 'input.txt' | 'example.txt'
type Color = 'red' | 'green' | 'blue'
async function part1(testCase: TestCase = 'example.txt') {
  const file = await fs.open(path.join(__dirname, testCase));

  const allowed = {
    red: 12,
    green: 13,
    blue: 14
  }
  let tally = 0;
  loop: for await (const line of file.readLines()) {
    const { id, round } = line.match(
      /^Game (?<id>\d+): (?<round>.*)$/
    )!.groups as Record<string, string>
    for (let set of round.split("; ")) {
      for (let amount of set.split(", ")) {
        const [num, color] = amount.split(" ")
        if (Number(num) > allowed[color as Color]) {
          continue loop 
        }
      }
    }
    tally += Number(id);
  }
  console.log(tally)
}

async function part2(testCase: TestCase = 'example.txt') {
  const file = await fs.open(path.join(__dirname, testCase));

  let tally = 0;
  for await (const line of file.readLines()) {
    const { round } = line.match(
      /^Game \d+: (?<round>.*)$/
    )!.groups as Record<string, string>

    const cubes = {red: 0, green: 0, blue: 0 }
    for (let set of round.split("; ")) {
      for (let amount of set.split(", ")) {
        const [num, color] = amount.split(" ")
        cubes[color as Color] = Math.max(cubes[color as Color], Number(num));
      }
    }
    tally += Object.values(cubes).reduce((a, b) => a * b, 1);
  }
  console.log(tally)
}



part2('input.txt');
