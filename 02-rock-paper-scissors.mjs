#!/usr/bin/env node

import fs from 'node:fs/promises'

const shapes = ['A', 'B', 'C'] 

const shapeScore = {
  'A': 1,
  'B': 2,
  'C': 3,
}

const outcomeScores = {
  'Z': 6, // win
  'Y': 3, // draw
  'X': 0, // lose
}

function shape(k, outcome){
  const i = (k.charCodeAt(0) - 'A'.charCodeAt(0));
  const them = shapes[i];
  if (outcome === 'Y') return them;

  const dir = outcome === 'Z' ? 1 : -1;

  return shapes[((i + dir) + 3) % 3];
}

async function main() {
  const file = await fs.open('./assets/02-rock-paper-scissors.txt')

  let total = 0;
  for await (const line of file.readLines()) {
    let [them , outcome ] = line.split(" ");
    
    const me = shape(them, outcome);
    const s = shapeScore[me]
    const o = outcomeScores[outcome];
    total += s + o
  }
  console.log(total);
}
main();
