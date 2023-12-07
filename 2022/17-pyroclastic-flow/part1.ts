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
const OFFSET = 3 * WIDTH + 2

async function main(testCase: TestCase = 'example.txt') {
  const file = await fs.open(path.join(__dirname, testCase));

  const jetStream = (await file.readFile('utf8')).trimEnd();
  file.close();
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

    function show() {
      if (chamber.height > 20) return
      let view: string[][] = []
      for (let row = 0; row < chamber.height + 6; row++) {
        view.push([])
        for (let col = 0; col < WIDTH; col++) {
          const cell = (chamber.bedrock.has(row * WIDTH + col)) ? '#' : '.'
          view[row].push(cell)
        }
      }

      for (let r of rock) {
        const row = Math.floor(r / 7)
        const col = r % 7
        view[row] && (view[row][col] = '@')
      }
      view.reverse()

      console.log(view.map(row => '|' + row.join("") + '|').join("\n"))
      console.log('+-------+\n')
    }

    show()
    while (true) {
      const jet = jetStream[j % jetStream.length];
      j++
      if (jet === '>') {
        const canMove = rock.every(r => (r + 1) % 7 !== 0 && !chamber.bedrock.has(r + 1))
        if (canMove) {
          for (let i = 0; i < rock.length; i++) {
            rock[i] += 1;
          }
        }
      }
      else if (jet === '<') {
        const canMove = rock.every(r => (r + 6) % 7 !== 6 && !chamber.bedrock.has(r - 1))
        if (canMove) {
          for (let i = 0; i < rock.length; i++) {
            rock[i] -= 1;
          }
        }
      }
      else {
        throw new Error();
      }
      console.log(jet)
      show()

      const canMove = rock.every(r => r > WIDTH && !chamber.bedrock.has(r - WIDTH))
      if (canMove) {
        for (let i = 0; i < rock.length; i++) {
          rock[i] -= WIDTH;
        }

        console.log('v')
        show()
      }
      else {
        for (let r of rock) {
          chamber.bedrock.add(r);
        }
        chamber.height = 1 + Math.floor(rock[rock.length - 1] / 7)
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
  file.close()
  buildRock()
  return rocks
}
main();
