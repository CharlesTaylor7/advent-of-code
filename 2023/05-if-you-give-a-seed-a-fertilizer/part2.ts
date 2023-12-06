#!/usr/bin/env ts-node

import { verify } from 'node:crypto'
import fs from 'node:fs/promises'
import path from 'node:path'

type TestCase = 'input.txt' | 'example.txt'

type Rule = {
  src: number,
  dest: number,
  count: number,
}

// half open range. start is inclusive,end is exclusive.
// size of range equals end - start
type Range = {
  start: number,
  end: number,
}

function splitRange(range: Range, sortedRules: Rule[]): Range[] {
  const mappedRanges: Range[] = []
  
  const copy = {...range};
  for (let rule of sortedRules) {
    if (range.start === range.end) break;
    if (range.start >= rule.src + rule.count) continue;
    else if (range.start >= rule.src) {
      // console.log(`splitting range`, range);
      // console.log(`on rule`, rule)
      const delta = range.start - rule.src;
      const start = rule.dest + delta
      const mapped = {
        ...range,
        start,
        end: 
          Math.min(start + range.end - range.start, rule.dest + rule.count)
      }
      // console.log(`mapped`, mapped)
      mappedRanges.push(mapped)
      range.start += mapped.end - mapped.start
      // console.log(`new start`, range.start)
    }
    else if (range.end > rule.src) {
      mappedRanges.push({
        ...range,
        start: range.start,
        end: rule.src
      })
      range.start = rule.src
    }
    else {
      break;
    }
  }
  if (range.start < range.end) {
    mappedRanges.push(range)
  }
  if ((range as any)[''] !== undefined) {
    console.log("rules", sortedRules)
    console.log("before", copy)
    console.log("mapped", mappedRanges)
  }

  // check invariants
  let tally = 0;
  for (let range of mappedRanges) {
    if (range.start >= range.end) {
      throw new Error("invalid range")
    }
    tally += range.end - range.start
  }
  if (tally !== copy.end - copy.start) {
    throw new Error("split ranges do not sum to original size")
  }

  return mappedRanges;
}

async function main(testCase: TestCase = 'example.txt') {
  const file = await fs.open(path.join(__dirname, testCase));

  let ranges: Range[] = []
  let row = 0;
  let currentRules: Rule[] = []
  let currentMapping: string | undefined;

  function applyRules() {
    console.log(currentMapping)
    currentRules.sort((a,b) => a.src - b.src);
    ranges = ranges.flatMap(range => splitRange(range, currentRules))
  }

  for await (const line of file.readLines()) {
    row++
    if (row === 1) {
      const [,seeds] = line.match(/seeds:\s+(.*)/)!
      const seedCounts = seeds.split(/\s+/).map(Number)
      for (let i = 0; i < seedCounts.length; i += 2) {
        ranges.push({ 
          start: seedCounts[i], 
          end: seedCounts[i] + seedCounts[i + 1],
          // @ts-ignore
          ['']: seedCounts[i] === 79 ? '' : undefined,
        });
      
      }
    }
    else if (line.match(/map:$/)) {
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
  console.log(ranges[0]?.start)
  console.log("fe\nfi\nfo\nfum\n\n")
}

main('input.txt');
