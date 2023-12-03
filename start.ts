#!/usr/bin/env node -r ts-node/register --env-file=.env

import fs from 'node:fs/promises'
import HtmlParser from 'node-html-parser'

const cookie = `session=${process.env.COOKIE_SESSION_ID}`
// examples
// download day 12 year 2022
// ./index.ts start 2022 12
// answer part 1 
// ./index.ts answer 2022 12 1 <ans>

async function main() {
  const [year, day] = process.argv.slice(2); 
  const baseUrl = `https://adventofcode.com/${year}/day/${day}`;

  const intro = await fetch(
    `${baseUrl}`,
    { headers: { cookie } },
  ).then(res => res.text())
  const main = HtmlParser.parse(intro).querySelector('main')!;

  // replace <pre><code> tags with just <code> tags
  for (let node of main.querySelectorAll("pre")) {
    node.replaceWith(HtmlParser.parse(node.rawText))
  }

  const [, rawTitle, rawBody] = main.text.match(/^.*--- Day \d+: (.*) ---(.*)/s)!

  const title = rawTitle.split(' ').map(w => w.toLowerCase()).join("-");
  const content = `\nDay ${day}: ${rawTitle}\n\n${rawBody}`;
  console.log(content)

  const dir = `${year}/${day.padStart(2, '0')}-${title}`;
  await fs.mkdir(dir, {recursive: true})
  await fs.writeFile(`${dir}/description.txt`, content)

  const input = await fetch(
    `${baseUrl}/input`,
    { headers: { cookie } }
  ).then(res => res.text())
  await fs.writeFile(`${dir}/input.txt`, input)

  const example = main.querySelector("code");
  if (example) {
    await fs.writeFile(`${dir}/example.txt`, example.text);
  }

  await fs.copyFile('template.ts', `${dir}/run.ts`, fs.constants.COPYFILE_EXCL)
}

main();
