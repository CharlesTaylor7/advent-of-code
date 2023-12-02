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
  
  const answerPage = await fetch(
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

  let main = HtmlParser.parse(answerPage).querySelector('main')!;
  console.log(main.text)


  let puzzlePage = await fetch(
    `https://adventofcode.com/${year}/day/${day}`,
    { headers: { cookie } },
  ).then(res => res.text())
  main = HtmlParser.parse(puzzlePage).querySelector('main')!;
  const [,part2] = main.text.split('--- Part Two ---')
  
  console.log(part2);
}

main();
