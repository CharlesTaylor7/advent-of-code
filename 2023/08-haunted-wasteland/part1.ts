#!/usr/bin/env ts-node

import fs from "node:fs/promises";
import path from "node:path";

type TestCase = "input.txt" | "example.txt";

async function main(testCase: TestCase = "example.txt") {
  const contents = await fs.readFile(path.join(__dirname, testCase), "utf-8");

  const lines = contents.trimEnd().split("\n");
  const commands = lines[0];
  const network: Network = {};
  for (let i = 2; i < lines.length; i++) {
    const [, name, left, right] = lines[i].match(/^(\w+) = \((\w+), (\w+)\)$/)!;
    network[name] = { L: left, R: right };
  }

  let current = "AAA";
  let steps = 0;
  while (current !== "ZZZ") {
    const node = network[current];
    const c = commands[steps % commands.length] as "L" | "R";
    current = node[c];

    steps++;
  }
  console.log(steps);
}

type Network = Record<string, NetworkNode>;
type NetworkNode = {
  L: string;
  R: string;
};

main("input.txt");
