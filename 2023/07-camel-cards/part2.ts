#!/usr/bin/env ts-node

import fs from "node:fs/promises";
import path from "node:path";

type TestCase = "input.txt" | "example.txt";

const hands = [
  "five-of-a-kind",
  "four-of-a-kind",
  "full-house",
  "three-of-a-kind",
  "two-pair",
  "one-pair",
  "nothing",
] as const;

type Hands = typeof hands;
type HandType = Hands[keyof Hands];
"nothing" satisfies HandType;

type Row = {
  // normalized with A, K, Q, J, T converted to 14 to 10
  hand: number[];
  raw: string;
  type: HandType;
  bid: number;
};

const cardToNum = {
  A: 14,
  K: 13,
  Q: 12,
  T: 10,
  J: 1,
};

type HandSymbol = keyof typeof cardToNum;

async function main(testCase: TestCase = "example.txt") {
  const contents = await fs.readFile(path.join(__dirname, testCase), "utf-8");

  const rows: Row[] = contents
    .trimEnd()
    .split("\n")
    .map((line) => {
      const [rawHand, rawBid] = line.split(" ");
      const bid = Number(rawBid);
      const grouped: Map<number, number> = new Map();
      const hand: number[] = [];
      let jokers = 0;
      for (let h of rawHand) {
        const n = cardToNum[h as HandSymbol] ?? Number(h);
        hand.push(n);
        if (h === "J") jokers++;
        else {
          grouped.set(n, (grouped.get(n) ?? 0) + 1);
        }
      }
      return {
        type: handType(grouped, jokers),
        raw: rawHand,
        bid,
        hand,
      };
    });
  rows.sort((a, b) => {
    // @ts-ignore
    const handDiff = hands.indexOf(b.type) - hands.indexOf(a.type);
    if (handDiff !== 0) return handDiff;
    for (let i = 0; i < 5; i++) {
      const diff = a.hand[i] - b.hand[i];
      if (diff !== 0) return diff;
    }
    return 0;
  });

  let tally = 0;
  for (let i = 0; i < rows.length; i++) {
    tally += (i + 1) * rows[i].bid;
  }
  console.log(tally);
}

function handType(grouped: Map<number, number>, jokers: number): HandType {
  const counts = Array.from(grouped.values());
  counts.sort((a, b) => b - a);
  const a = (counts[0] ?? 0) + jokers;
  const b = counts[1] ?? 0;
  if (a === 5) return "five-of-a-kind";
  if (a === 4) return "four-of-a-kind";
  if (a === 3 && b === 2) return "full-house";
  if (a === 3) return "three-of-a-kind";
  if (a === 2 && b === 2) return "two-pair";
  if (a === 2) return "one-pair";
  return "nothing";
}

main("input.txt");
