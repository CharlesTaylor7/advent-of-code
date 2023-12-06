#!/usr/bin/env ts-node

import fs from 'node:fs/promises'
import path from 'node:path'

type TestCase = 'input.txt' | 'example.txt'
// max speed after n seconds

async function main(testCase: TestCase = 'example.txt') {
  const file = await fs.open(path.join(__dirname, testCase));


  const nums: number[][] = []
  for await (const line of file.readLines()) {
    nums.push(Array.from(line.matchAll(/\d+/g)!, Number))
  }

  let times = nums[0]
  let distances = nums[1]
  let product = 1;
  for (let i = 0; i < times.length; i++) {
    product *= countWaysToWin(times[i], distances[i]);
  }
  console.log(product)
}

// const cache = []
function countWaysToWin(time: number, distance: number): number {
  let tally = 0;
  for (let i = 1; i < time - 1; i++) {
    if (distanceTraveled(time, i) > distance) {
      tally++
    }
  }
  return tally;
} 

function distanceTraveled(time: number, held: number): number {
  return (time - held) * held
}

main('input.txt');
