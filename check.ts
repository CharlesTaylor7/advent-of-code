#!/usr/bin/env node -r ts-node/register --env-file=.env

import fs from "node:fs/promises";
import HtmlParser from "node-html-parser";

const cookie = `session=${process.env.COOKIE_SESSION_ID}`;

// examples
// check 2022

async function main() {
  const [year] = process.argv.slice(2);

  const page = await fetch(`https://adventofcode.com/${year}`, {
    headers: { cookie },
  }).then((res) => res.text());
  const html = HtmlParser.parse(page);

  const calendar = html.querySelector("pre.calendar")!;

  for (let node of HtmlParser.parse(calendar.rawText).querySelectorAll("a")) {
    console.log(node.getAttribute("aria-label"));
  }

  // console.log(html.rawText);
}

main();
