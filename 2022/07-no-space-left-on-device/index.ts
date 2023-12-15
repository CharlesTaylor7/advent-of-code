#!/usr/bin/env ts-node

import fs from "node:fs/promises";
import path from "node:path";

function toDirName(pathSegments: string[]) {
  return `/${pathSegments.join("/")}`;
}

const patterns = {
  cd: /^\$ cd (.*)$/,
  ls: /^\$ ls$/,
  fileSize: /^(\d+) (.*)$/,
  dirName: /^dir (.*)$/,
} as const;

type State = {
  pathSegments: string[];
  // absolute path of dir or file -> size
  sizes: Record<string, number>;
  // absolute path -> just the name
  children: Record<string, string[]>;
};

async function main() {
  const file = await fs.open("./07-input.txt");
  const state: State = {
    pathSegments: [],
    sizes: {},
    children: {},
  };
  for await (const line of file.readLines()) {
    const dirMatch = line.match(patterns.dirName);
    if (dirMatch) {
      console.log("dir", dirMatch[1]);
      const dir = dirMatch[1];
      state.children[toDirName(state.pathSegments)].push(dir);
    }

    const fileMatch = line.match(patterns.fileSize);
    if (fileMatch) {
      const size = Number(fileMatch[1]);
      const name = fileMatch[2];
      console.log("file", name, size);
      state.sizes[toDirName([...state.pathSegments, name])] = size;
      state.children[toDirName(state.pathSegments)].push(name);
    }

    const cdMatch = line.match(patterns.cd);
    if (cdMatch) {
      console.log("cd", cdMatch[1]);
      const dir = cdMatch[1];

      if (dir === "/") {
        state.pathSegments = [];
      } else if (dir === "..") {
        state.pathSegments.pop();
      } else {
        state.pathSegments.push(dir);
      }
    }

    const lsMatch = line.match(patterns.ls);
    if (lsMatch) {
      console.log("ls");
      state.children[toDirName(state.pathSegments)] = [];
    }
  }
  part2(state);
}

// I need a list of dirs
// I need to exclude dirs if they get too large
function part1(state: State) {
  console.log(state);
  const sizeCap = 100_000;

  let tally = 0;
  for (let dir of Object.keys(state.children)) {
    const size = getSize(dir);
    console.log(dir, size);
    tally += size > sizeCap ? 0 : size;
  }

  console.log(tally);

  function getSize(name: string): number {
    let size = state.sizes[name];

    if (size === undefined) {
      size = state.sizes[name] = state.children[name].reduce(
        (a, b) => a + getSize(path.join(name, b)),
        0,
      );
    }

    return size;
  }
}

function part2(state: State) {
  console.log(state);
  const target = getSize("/") - 40_000_000;

  let min = 70_000_000;
  let name: string = "";
  for (let dir of Object.keys(state.children)) {
    const size = getSize(dir);
    if (size > target && size < min) {
      min = size;
      name = dir;
    }
  }

  console.log(name, min);

  function getSize(name: string): number {
    let size = state.sizes[name];

    if (size === undefined) {
      size = state.sizes[name] = state.children[name].reduce(
        (a, b) => a + getSize(path.join(name, b)),
        0,
      );
    }

    return size;
  }
}

main();
