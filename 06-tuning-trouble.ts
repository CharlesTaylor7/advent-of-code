#!/usr/bin/env ts-node

import fs from 'node:fs/promises'

async function part1() {
  const file = await fs.open('./06.txt')

  let packet = '';
  for await (const line of file.readLines()) {
    packet = line
  }


  for (let i = 3; i < packet.length; i++) {
    if (new Set(packet.slice(i - 3, i + 1)).size == 4) {
      console.log(i+1)
      return 
    }
  }
}

async function part2() {
  const file = await fs.open('./06.txt')

  let packet = '';
  for await (const line of file.readLines()) {
    packet = line
  }

  for (let i = 13; i < packet.length; i++) {
    if (new Set(packet.slice(i - 13, i + 1)).size == 14) {
      console.log(i+1)
      return 
    }
  }
}

part2();
