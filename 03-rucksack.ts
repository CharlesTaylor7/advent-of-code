#!/usr/bin/env ts-node

import fs from 'node:fs/promises'

function commonRucksackItem(line: string): string {
  const n = line.length;
  const secondHalf = new Set(line.slice(n / 2))
  for (let i = 0; i < n / 2; i++) {
    if (secondHalf.has(line[i])) {
      return line[i];
    }
  }
  throw new Error();
}
function priority(x: string): number {
  const lowercase = x.charCodeAt(0) - 'a'.charCodeAt(0);
  const uppercase = x.charCodeAt(0) - 'A'.charCodeAt(0);
  return lowercase >= 0 ? lowercase + 1 : uppercase + 27
}
function intersect(set: Set<string>, items: Iterable<string>): Set<string> {
    const intersection: Set<string> = new Set();
    for (let x of items){
      if (set.has(x) ) {
        intersection.add(x);
      }
    }
    return intersection;
}

async function main() {
  const file = await fs.open('./03-rucksack.txt')

  let total = 0
  let group: Array<string> = []
  for await (const line of file.readLines()) {
    group.push(line);
    if (group.length !== 3) continue

    const intersection = intersect(intersect(new Set(group[0]), group[1]),group[2]);

    const common =intersection.values().next().value;
    const p = priority(common)
    total += p ;
    group = []
  }
  console.log(total);
}
main();
