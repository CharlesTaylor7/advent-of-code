#!/usr/bin/env node -r ts-node/register --env-file=.env

import HtmlParser from "node-html-parser";

const cookie = `session=${process.env.COOKIE_SESSION_ID}`;

// examples
// answer part 1
// ./answer.ts 2022 12 1 <ans>

async function main() {
  const [year, day, level, answer] = process.argv.slice(2);
  const body = new URLSearchParams([
    ["level", level],
    ["answer", answer],
  ]).toString();

  const answerPage = await fetch(
    `https://adventofcode.com/${year}/day/${day}/answer`,
    {
      method: "POST",
      body,
      headers: {
        "Sec-Fetch-Site": "cross-site",
        Cookie: cookie,
        "Content-Type": "application/x-www-form-urlencoded",
      },
    },
  ).then((res) => res.text());

  let main = HtmlParser.parse(answerPage).querySelector("main")!;
  console.log(main.text);

  if (level === "2") return;
  // fetch part 2
  let html = await fetch(`https://adventofcode.com/${year}/day/${day}`, {
    headers: { cookie },
  }).then((res) => res.text());
  let page = HtmlParser.parse(html);

  const [, part2] = page.querySelectorAll("article.day-desc");

  console.log(part2?.text);
}

main();
