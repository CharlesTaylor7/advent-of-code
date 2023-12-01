#!/usr/bin/env ts-node

import fs from 'node:fs/promises'

async function part1() {
  const file = await fs.open('./05-supply-stacks.txt')

  let total = 0
  let group: Array<string> = []
  for await (const line of file.readLines()) {
    const [a1,b1, a2,b2] = line.split(/[,-]/).map(Number);
    // console.log({line, a1, b1,a2,b2});
    // range 1 contains range 2
    const range1 = a1 <= a2 && b1 >= b2
    const range2 = a2 <= a1 && b2 >= b1 
    if (range1) {
      console.log(line, 'first');
      total++
    }
    else if (range2) {
      console.log(line, 'second');
      total++
    }
    else {
      console.log(line, 'none');
    }
  }
  console.log(total);
}

async function main_part2() {

  const file = await fs.open('./04-camp-cleanup.txt')

  let total = 0
  let group: Array<string> = []
  for await (const line of file.readLines()) {
    const [a1,b1, a2,b2] = line.split(/[,-]/).map(Number);
    // console.log({line, a1, b1,a2,b2});
    // range 1 contains range 2
    if (a1 >= a2 && a1 <= b2) {
      //console.log(line, 'first');
      total++
    }
    else if (b1 >= a2 && b1 <= b2) {
      //console.log(line, 'second');
      total++
    }
    else if (a2 >= a1 && a2 <= b1) {
      total++
    }
    else if (b2 >= a1 && b2 <= b1) {
      total++
    }
    else {
      console.log(line, 'none');
    }
  }
  console.log(total);
}

m
