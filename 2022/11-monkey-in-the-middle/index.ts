#!/usr/bin/env ts-node

import fs from 'node:fs/promises'
import path from 'node:path'

async function main(part: 1 | 2) {
  const file = await fs.open(path.join(__dirname, 'input.txt'))

  let gen = parse();
  gen.next();
  for await (const line of file.readLines()) {
    gen.next(line);
  }
  const iter = gen.next();
  if (iter.done) {
    const monkeys = iter.value;
    const func = (part === 1) ? part1 : part2;
    console.log(monkeys.map(m => ({ id: m.id, m: m.testModulus, items: JSON.stringify(m.items.flatMap(i => i))})));

    func(monkeys);
    monkeyBusiness(monkeys);
  }
}

function monkeyBusiness(monkeys: Monkey[]) {
  const mostActivity: number[] = [];

  for (let monkey of monkeys) {
    mostActivity.push(monkey.inspections)
    mostActivity.sort((a, b) => b - a)
    mostActivity.splice(2)
  }
  console.log(mostActivity);
  console.log( mostActivity[0] * mostActivity[1]);
}


type Monkey = {
  id: number,
  inspections: number,
  items: Item[],
  operation: (worry: number) => number,
  testModulus: number,
  ifTrueMonkeyId: number,
  ifFalseMonkeyId: number,
}

// worry level for each monkey modulo the test value
type Item = {
  part1: number,
  // active counts modulo each monkey's test divisor
  part2: number[],
}

type Op = (a: number, b: number) => number

function* parse(): Generator<unknown, Monkey[], string> {
  const monkeys: Monkey[] = []
  let currentMonkey: Partial<Monkey> = { inspections: 0 }

  let line: string;
  let match: RegExpMatchArray | null

  while ((line = yield) !== undefined) {
    if (match = line.match(/^Monkey (\d+):$/)) {
      if (currentMonkey.operation !== undefined) {
        monkeys.push(currentMonkey as Monkey); 
      }
      currentMonkey = { id: Number(match[1]), inspections: 0 };

    } else if (match = line.match(/Starting items: (.*)$/)) {
      currentMonkey.items = match[1]
        .split(', ')
        .map(worry => ({ part1: Number(worry), part2: []}));

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

  for (let monkey of monkeys) {
    for (let item of monkey.items) {
      item.part2 = monkeys.map(m => item.part1 % m.testModulus);
    }
  }
  return monkeys;
}

function part1(monkeys: Monkey[]) {
  for (let round = 1; round <= 20; round++) {
    for (let monkeyId = 0; monkeyId < monkeys.length; monkeyId++) {
      const monkey = monkeys[monkeyId];
      for (let item of monkey.items) {
        const afterOp = monkey.operation(item.part1);
        const worry = Math.floor(afterOp / 3)

        const id = worry % monkey.testModulus === 0
          ? monkey.ifTrueMonkeyId
          : monkey.ifFalseMonkeyId

          monkeys[id].items.push({ part1: worry, part2: []});
      }
      monkey.inspections += monkey.items.length;
      monkey.items = []
    }
  }
}

function part2(monkeys: Monkey[]) {
  for (let round = 1; round <= 10_000; round++) {
    for (let monkeyId = 0; monkeyId < monkeys.length; monkeyId++) {
      const monkey = monkeys[monkeyId];
      for (let item of monkey.items) {

        for (let i = 0; i < item.part2.length; i++) {
          const value = item.part2[i];
          item.part2[i] = monkey.operation(value) % monkeys[i].testModulus
        }

        const id = item.part2[monkeyId] == 0
          ? monkey.ifTrueMonkeyId
          : monkey.ifFalseMonkeyId

          monkeys[id].items.push(item);
      }
      monkey.inspections += monkey.items.length;
      monkey.items = []
    }
  }
}

main(2);
