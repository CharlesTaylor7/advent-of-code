#!/usr/bin/env ts-node

import fs from 'node:fs/promises'
import path from 'node:path'

async function main(part: 1 | 2) {
  const file = await fs.open(path.join(__dirname, 'input.txt'))

  let gen = part === 1 ? part1() : part2();
  gen.next();
  for await (const line of file.readLines()) {
    gen.next(line);
  }
  console.log(gen.next().value);
}

type Monkey = {
  inspections: number,
  items: number[],
  operation: (worry: number) => number,
  testModulus: number,
  ifTrueMonkeyId: number,
  ifFalseMonkeyId: number,
}

type Op = (a: number, b: number) => number

function* part1(): Generator<unknown, unknown, string> {
  const monkeys: Monkey[] = []
  let currentMonkey: Partial<Monkey> = { inspections: 0 }

  let line: string;
  let match: RegExpMatchArray | null

  while ((line = yield) !== undefined) {
    if (line.match(/^Monkey/)) {
      if (currentMonkey.operation !== undefined) {
        monkeys.push(currentMonkey as Monkey); 
      }
      currentMonkey = { inspections: 0 };

    } else if (match = line.match(/Starting items: (.*)$/)) {
      currentMonkey.items = match[1].split(', ').map(Number)
    } else if (match = line.match(/Operation: new = (.*)$/)) {
      const [x,op,y] = match[1].split(' ');
      const operation: Op = op === '+' ? (a, b) => a + b : (a, b) => a * b;

      currentMonkey.operation = 
        (old) => operation(
          x === 'old' ? old : Number(x), 
          y === 'old' ? old : Number(y), 
        )

    } else if (match = line.match(/Test: divisible by (\d+)$/)) {
      currentMonkey.testModulus = Number(match[1])

    } else if (match = line.match(/If true: throw to monkey (\d+)$/)) {
      currentMonkey.ifTrueMonkeyId = Number(match[1])

    } else if (match = line.match(/If false: throw to monkey (\d+)$/)) {
      currentMonkey.ifFalseMonkeyId = Number(match[1])
    }
  }

  monkeys.push(currentMonkey as Monkey);
  return simulate(monkeys);
}
function debug(round: number, s: string) {
  if (round == 1) {
    console.log(s)
  }
}

function simulate(monkeys: Monkey[]) {
  for (let round = 1; round <= 20; round++) {
    for (let monkeyId = 0; monkeyId < monkeys.length; monkeyId++) {
      let indent = ''
      debug(round, `Monkey ${monkeyId}: `)
      indent = '  ' 

      const monkey = monkeys[monkeyId];
      for (let item of monkey.items) {
        debug(round, `${indent}Monkey inspects an item with a worry level of ${item}`)
        indent = '    '
        const afterOp = monkey.operation(item);
        debug(round, `${indent}Worry level is increased to ${afterOp}`);
        const worry = Math.floor(afterOp/ 3)
        debug(round, `${indent}Monkey gets bored with item. Worry level is divided by 3 to ${worry}`);

        if (worry % monkey.testModulus === 0) {
          
          debug(round, `${indent}Current worry level is divisible by ${monkey.testModulus}.`) 
          debug(round, `${indent}Item with worry level ${worry} is thrown to monkey ${monkey.ifTrueMonkeyId}.`) 
          monkeys[monkey.ifTrueMonkeyId].items.push(worry);
        }
        else {
          debug(round, `${indent}Current worry level is not divisible by ${monkey.testModulus}.`) 
          debug(round, `${indent}Item with worry level ${worry} is thrown to monkey ${monkey.ifFalseMonkeyId}.`) 
          monkeys[monkey.ifFalseMonkeyId].items.push(worry);
        }
      }
      monkey.inspections += monkey.items.length;
      monkey.items = []
    }
    console.log(`After round ${round}`)
    console.log(monkeys)
  }

  const mostActivity: number[] = [];

  for (let monkey of monkeys) {
    mostActivity.push(monkey.inspections)
    mostActivity.sort()
    mostActivity.splice(2)
  }
  return mostActivity[0] * mostActivity[1];
}

function* part2(): Generator {

}

main(1);
