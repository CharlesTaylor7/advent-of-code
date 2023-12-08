#!/usr/bin/env node -r ts-node/register --env-file=.env

import fs from "node:fs/promises";
import HtmlParser from "node-html-parser";

const cookie = `session=${process.env.COOKIE_SESSION_ID}`;

// examples
// check 2022

async function main() {
  const [year] = process.argv.slice(2);
  const url = `https://adventofcode.com/${year}`;
  const page = await fetch(url, {
    headers: { cookie },
  }).then((res) => res.text());
  const html = HtmlParser.parse(page);

  const calendar = html.querySelector("pre.calendar")!;

  //const labels: string[] = [];
  for (let node of HtmlParser.parse(calendar.rawText).querySelectorAll("a")) {
    node
      .querySelectorAll("[class^=calendar-mark-]")
      .forEach((span) => span.remove());
    const label = node.getAttribute("aria-label")!;
    let row = node.text;
    const match = label.match(/one|two/);
    if (!match) {
      // 0
    } else if (match[0] === "one") {
      row += "*";
    } else if (match[0] === "two") {
      row += "**";
    }
    console.log(row);
  }
  console.log("\n" + url);
  // console.log(html.rawText);
}

main();
