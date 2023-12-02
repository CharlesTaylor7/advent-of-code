#!/usr/bin/env node -r ts-node/register --env-file=.env

import HtmlParser from 'node-html-parser'

const cookie = `session=${process.env.COOKIE_SESSION_ID}`

// examples
// answer part 1 
// ./answer.ts 2022 12 1 <ans>

async function main() {
  const [year, day, level, answer] = process.argv.slice(2); 
  const body = new URLSearchParams([
    ['level', level],
    ['answer', answer],
  ]).toString();
  
  const page = await fetch(
    `https://adventofcode.com/${year}/day/${day}/answer`,
    { 
      method: 'POST',
      body,
      headers: 
        { 
          'Sec-Fetch-Site': 'cross-site',
          'Cookie': cookie,
          'Content-Type': 'application/x-www-form-urlencoded',
        } 
    }
  ).then(res => res.text())

  let main = HtmlParser.parse(page).querySelector('main')!;
  console.log(main.text)



  const intro = await fetch(
    `https://adventofcode.com/${year}/day/${day}`,
    { headers: { cookie } },
  ).then(res => res.text())
  main = HtmlParser.parse(intro).querySelector('main')!;

  console.log(main.text)
}

main();
