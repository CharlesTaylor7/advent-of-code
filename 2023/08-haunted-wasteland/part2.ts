#!/usr/bin/env ts-node

import fs from "node:fs/promises";
import path from "node:path";

type TestCase = "input.txt" | "example.txt";

async function main(testCase: TestCase = "example.txt") {
  const contents = await fs.readFile(path.join(__dirname, testCase), "utf-8");

  const lines = contents.trimEnd().split("\n");
  const commands = lines[0];
  const network: Network = {};
  let current: string[] = [];
  for (let i = 2; i < lines.length; i++) {
    const [, name, left, right] = lines[i].match(/^(\w+) = \((\w+), (\w+)\)$/)!;
    network[name] = { L: left, R: right };
    if (name.endsWith("A")) {
      current.push(name);
    }
  }

  let j = 0;
  const frequencies: number[][] = Array.from(current, () => []);
  while (frequencies.some((f) => f.length < 1)) {
    for (let i = 0; i < current.length; i++) {
      if (current[i].endsWith("Z")) {
        frequencies[i].push(j);
      }

      const node = network[current[i]];
      const c = commands[j % commands.length] as "L" | "R";
      current[i] = node[c];
    }
    j++;
  }
  console.log(frequencies);
  const leastCommonMultiple = frequencies.reduce((acc, f) => lcm(acc, f[0]), 1);
  console.log(leastCommonMultiple);
}

function lcm(a: number, b: number) {
  return (a * b) / gcd(a, b);
}

function gcd(a: number, b: number) {
  if (a === 0) {
    return b;
  }
  if (b === 0) {
    return a;
  }
  if (a > b) {
    return gcd(a % b, b);
  } else {
    return gcd(a, b % a);
  }
}

type Network = Record<string, NetworkNode>;
type NetworkNode = {
  L: string;
  R: string;
};

main("input.txt");
