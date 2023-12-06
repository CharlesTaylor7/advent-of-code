#!/usr/bin/env ts-node

import fs from 'node:fs/promises'
import path from 'node:path'

type TestCase = 'input.txt' | 'example.txt'

type Rule = {
  src: number,
  dest: number,
  count: number,
}

type Range = {
  start: number,
  count: number,
}

async function main(testCase: TestCase = 'example.txt') {
  const file = await fs.open(path.join(__dirname, testCase));

  let ranges: Range[] = []
  let row = 0;
  let currentRules: Rule[] = []
  let currentMapping: string | undefined;

  function applyRules() {
      // console.log(values)
      // console.log(currentMapping)
      currentRules.sort((a,b) => a.src - b.src);
      ranges = ranges.flatMap(range => {
        const mappedRanges: Range[] = []
        
        for (let rule of currentRules) {
          if (range.start >= rule.src && range.start < rule.src + rule.count) {
            const start = rule.dest + (range.start - rule.src);
            mappedRanges.push({
              start,
              count: Math.min(rule.count, range.count),
            })
          }
        }
        return mappedRanges;
        // const rule = currentRules.find(rule => v >= rule.src && v < rule.src +rule.count)
        // return rule ? rule.dest + (v - rule.src) : v
      })
  }

  for await (const line of file.readLines()) {
    row++
    if (row === 1) {
      const [,seeds] = line.match(/seeds:\s+(.*)/)!
      const seedCounts = seeds.split(/\s+/).map(Number)
      for (let i = 0; i < seedCounts.length; i += 2) {
        ranges.push({ start: seedCounts[i], count: seedCounts[i + 1]});
      }
    }
    if (line.match(/map:$/)) {
      currentMapping = line
      currentRules = []
    }
    else if (!line && currentRules.length) {
      applyRules()
    }
    else {
      const [dest, src, count] = line.split(/\s+/).map(Number)
      currentRules.push({src, dest, count})
    }
  }
  applyRules()
  // console.log(values)

  console.log(ranges)
  ranges.sort((a,b) => a.start - b.start);
  console.log(ranges[0].start)
}

main('example.txt');
