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
  ).then(res => res.text())
  const main = HtmlParser.parse(intro).querySelector('main')!;

  const title = main.querySelector("h2")!.text.match(/^--- Day \d+: (.*) ---$/)![1].split(' ').map(w => w.toLowerCase()).join("-");
  const content = main.text
  console.log(content)

  const dir = `${year}/${day}-${title}`;
  await fs.mkdir(dir, {recursive: true})
  await fs.writeFile(`${dir}/intro.txt`, content)

  const input = await fetch(
    `${baseUrl}/input`,
    { headers: { cookie } }
  ).then(res => res.text())
  await fs.writeFile(`${dir}/input.txt`, input)

  const preformattedBlock = main.querySelector("pre");
  if (preformattedBlock) {
    const content = HtmlParser.parse(preformattedBlock.rawText).querySelector('code')!.rawText;
    await fs.writeFile(`${dir}/example.txt`, content);
  }

  await fs.copyFile('template.ts', `${dir}/index.ts`, fs.constants.COPYFILE_EXCL)
}

main();
