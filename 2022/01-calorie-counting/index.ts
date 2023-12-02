#!/usr/bin/env ts-node

import fs from 'node:fs/promises'

async function main() {
  const file = await fs.open('./assets/01-calorie-counting.txt')

  let tally = 0
  let counts = [0, 0, 0];
  function checkTally() {
    if (tally > counts[2]) {
        counts[3] = tally;
        counts.sort();
        counts.reverse();
        delete counts[3];
    }
  }

  for await (const line of file.readLines()) {
    if (line === '') {
      checkTally();
      tally = 0
    }
    else {
      tally += parseInt(line)
    }
  }
  checkTally();

  console.log("result", counts[0] + counts[1] + counts[2]);
}
main();
