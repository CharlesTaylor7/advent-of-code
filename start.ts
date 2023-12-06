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
  const page = HtmlParser.parse(intro);

  // replace <pre><code> tags with just <code> tags
  let example: string | undefined;
  for (let node of page.querySelectorAll("pre")) {
    const codeBlock = HtmlParser.parse(node.rawText)
    node.replaceWith(codeBlock)
    example ||= codeBlock.text
  }

  const sections = page.querySelectorAll("article.day-desc")

  const part1 = sections[0]
  const part2 = sections[1]

  const header = part1.querySelector("h2")!.remove();
  const rawTitle = 
    header
    .rawText
    .match(/--- Day \d+: (.*?) ---/)![1]

  const title = rawTitle 
    .split(' ')
    .map(w => w.toLowerCase())
    .join("-");

  let content = `\nDay ${day}: ${rawTitle}\n\n${part1.text}`;
  if (part2) {
    part2.querySelector("h2")!.remove();
    content += `\n\nPart 2\n\n${part2.text}`
  }
   
  console.log(content)

  const dir = `${year}/${day.padStart(2, '0')}-${title}`;
  await fs.mkdir(dir, {recursive: true})
  await fs.writeFile(`${dir}/description.txt`, content)

  const input = await fetch(
    `${baseUrl}/input`,
    { headers: { cookie } }
  ).then(res => res.text())
  await fs.writeFile(`${dir}/input.txt`, input)

  if (example) {
    await fs.writeFile(`${dir}/example.txt`, example);
  }

  await fs.copyFile('template.ts', `${dir}/part1.ts`, fs.constants.COPYFILE_EXCL)
}

main();
