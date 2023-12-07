#!/usr/bin/env ts-node

import fs from 'node:fs/promises'
import path from 'node:path'

type TestCase = 'input.txt' | 'example.txt'

type Chamber = {
  bedrock: Set<number>,
  height: number,
}

// rocks are encoded as numbers representing the
// positions it occupies when in the bottom left corner of the chamber
type Rock = number[]


const WIDTH = 7;

// new rock falling offset
const OFFSET = 4 * WIDTH + 3

async function main(testCase: TestCase = 'example.txt') {
  const file = await fs.open(path.join(__dirname, testCase));

  const jetStream = (await file.readFile('utf8')).trimEnd();
  const rocks = await getRocks();
  console.log("jet", jetStream)
  console.log("rocks", rocks)

  let j = 0;
  const chamber: Chamber = { bedrock: new Set(), height: 0 };
  for (let i = 0; i < 2022; i++) {
    let rock = Array.from(
      rocks[i % rocks.length], 
      k => k + OFFSET + chamber.height * WIDTH
    );

    while (true) {
      const jet = jetStream[j % jetStream.length];
      j++
      if (jet === '>') {
        const canMove = rock.every(r => (r + 1) % 7 !== 0)
        if (canMove) {
          for (let i = 0; i < rock.length; i++) {
            rock[i] += 1;
          }
        }
      }
      else if (jet === '<') {
        const canMove = rock.every(r => (r + 6) % 7 !== 6)
        if (canMove) {
          for (let i = 0; i < rock.length; i++) {
            rock[i] -= 1;
          }
        }
      }
      else {
        console.log(jet)
        throw new Error();
      }
      const canMove = rock.every(r => r > WIDTH && !chamber.bedrock.has(r - WIDTH))
      if (canMove) {
        for (let i = 0; i < rock.length; i++) {
          rock[i] -= WIDTH;
        }
      }
      else {
        for (let r of rock) {
          chamber.bedrock.add(r);
        }
        chamber.height = Math.floor(rock[rock.length - 1] / 7)
        break;
      }
    }
  }
  console.log(chamber.height);
}
async function getRocks(): Promise<Rock[]> {
  const file = await fs.open(path.join(__dirname, 'rocks.txt'));
  let rawLines: string[] = []
  const rocks: Rock[] = []

  function buildRock() {
    const rock: Rock = []
    for (let j = 0; j < rawLines.length; j++) {
      const row = rawLines[rawLines.length - j - 1]
      for (let i = 0; i < row.length; i++) {
        if (row[i] === '#') {
          rock.push(j * WIDTH + i)
        }
      }
    }
    rocks.push(rock)
    rawLines = []
  }

  for await (const line of file.readLines()) {
    if (line) {
      rawLines.push(line)
    }
    else {
      buildRock();
    }
  }
  buildRock()
  return rocks
}
main();
