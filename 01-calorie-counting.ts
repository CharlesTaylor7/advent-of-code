#!/usr/bin/env ts-node

function groupAnagrams(strs: string[]): string[][] {
  const groups: Map<string, Array<string>> = new Map()
  for (let word of strs) {
    const key = letterCountString(word)
    let group = groups.get(key);
    if (!group) {
      group = []
      groups.set(key, group)
    }
    group.push(word)
  }

  return Array.from(groups.values())
};

const offset = 'a'.charCodeAt(0);
function letterCountString(word: string): string {
  const array = Array.from({length: 26}, () => 0);

  for (let w of word) {
    const index = w.charCodeAt(0) - offset
    array[index] += 1
  }
  return array.join(',')
}

console.log(groupAnagrams(["bdddddddddd","bbbbbbbbbbc"]))

