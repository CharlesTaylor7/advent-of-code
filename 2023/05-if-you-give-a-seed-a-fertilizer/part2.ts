#!/usr/bin/env ts-node

import { verify } from "node:crypto";
import fs from "node:fs/promises";
import path from "node:path";

type TestCase = "input.txt" | "example.txt";

type Rule = {
  src: number;
  dest: number;
  count: number;
};

// half open range. start is inclusive,end is exclusive.
// size of range equals end - start
type Range = {
  start: number;
  end: number;
};

function splitRange(range: Range, sortedRules: Rule[]): Range[] {
  const mappedRanges: Range[] = [];

  for (let rule of sortedRules) {
    if (range.start === range.end) break;
    if (range.start >= rule.src + rule.count) continue;
    else if (range.start >= rule.src) {
      const delta = range.start - rule.src;
      const start = rule.dest + delta;
      const mapped = {
        start,
        end: Math.min(start + range.end - range.start, rule.dest + rule.count),
      };
      mappedRanges.push(mapped);
      range.start += mapped.end - mapped.start;
    } else if (range.end > rule.src) {
      mappedRanges.push({
        start: range.start,
        end: rule.src,
      });
      range.start = rule.src;
    } else {
      break;
    }
  }
  if (range.start < range.end) {
    mappedRanges.push(range);
  }
  return mappedRanges;
}

async function main(testCase: TestCase = "example.txt") {
  const file = await fs.open(path.join(__dirname, testCase));

  let row = 0;
  let ranges: Range[] = [];
  let rules: Rule[] = [];

  function applyRules() {
    rules.sort((a, b) => a.src - b.src);
    ranges = ranges.flatMap((range) => splitRange(range, rules));
  }

  for await (const line of file.readLines()) {
    row++;
    if (row === 1) {
      const [, seeds] = line.match(/seeds:\s+(.*)/)!;
      const seedCounts = seeds.split(/\s+/).map(Number);
      for (let i = 0; i < seedCounts.length; i += 2) {
        ranges.push({
          start: seedCounts[i],
          end: seedCounts[i] + seedCounts[i + 1],
        });
      }
    } else if (line.match(/map:$/)) {
      rules = [];
    } else if (!line && rules.length) {
      applyRules();
    } else {
      const [dest, src, count] = line.split(/\s+/).map(Number);
      rules.push({ src, dest, count });
    }
  }
  applyRules();

  console.log(ranges.length);
  ranges.sort((a, b) => a.start - b.start);
  console.log(ranges[0]?.start);
}

main("input.txt");
