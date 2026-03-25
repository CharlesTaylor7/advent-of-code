import { FibHeap } from "./queue.ts"

interface Input {
  rules: RuleSet,
  medicine: string
}

type RuleSet = Map<string, string[]>

function parse() {
  const input = Deno.readTextFileSync("./input.txt")
  let medicine = "";
  const rules = new Map<string, string[]>();

  const regex =  /^(\w+) \=\> (\w+)$/;

  for (const line of input.split("\n")) {

    const match = line.match(regex);
    if (match) {
      const key = match.at(1)!;
      let list = rules.get(key);
      if (list == null) rules.set(key, list = []);
      list.push(match.at(2)!);
    }
    else if (line.length) medicine = line;
  }

  return ({ medicine, rules })
}

interface Compression {
  lookup: Map<string, string>,
  next: number,
}

const elementRegex = /[A-Z][a-z]?/g
function compress(input: Input): Input {
  const compression: Compression = { lookup: new Map(), next: 0 };
  function compressEl(el: string) {
    if (el == "e") return "e";
    let key = compression.lookup.get(el);
    if (key == null) {
      key = String.fromCharCode('a'.charCodeAt(0) + compression.next);
      compression.lookup.set(el, key);
      compression.next++;
      // skip over 'e'
      if (compression.next == 4) compression.next++
    }
    return key
  }

  function compressMolecule(molecule: string) {
    let output = ""
    for (const match of molecule.matchAll(elementRegex)) {
      output += compressEl(match[0]);
    }
    return output;
  }

  const output: Input = { rules: new Map<string, string[]>, medicine: compressMolecule(input.medicine) };

  for (const entry  of input.rules.entries()) {
    const key = compressEl(entry[0]);
    const list: string[] = [];
    output.rules.set(key, list);
    for (const value of entry[1]) {
      list.push(compressMolecule(value));
    }
  }

  console.log(output);

  return output
}

function count(compressed: Input) {
  const results = new Set(mutate(compressed.medicine, compressed.rules));
  return results.size;
}

function* mutate(molecule: string, rules: RuleSet) {
  for (let i = 0; i < molecule.length; i++) {
    const el = molecule[i];

    const prefix = molecule.slice(0,i)
    const suffix = molecule.slice(i+1)
    const rs = rules.get(el);
    if (!rs) continue;
    for (const replacement of rs) {
      const result =  prefix + replacement + suffix;
      yield result;
    }
  }
}



function part1() {
  console.log(count(compress(parse())));
}


interface QueueEntry {
  molecule: string,
  steps: number,
}
// part 2 needs some kind of dijkstra / BFS
// we can prune by the fact that every replacement rule increases the size of the output and we can prune molecules that are too large.
function part2() {
  // the priority should be to focus on molecules that are close to the target length.
  const input = compress(parse());

  const N = input.medicine.length;

  const seen = new Set<string>();

  // we have a queue at home
  const queue = new FibHeap<string>();
  queue.insert(0, "e");

  while (true)  {
    const min =  queue.findMin()!;
    if (min == null) {
      console.error("Queue empty!");
      return null; 
    }
    const [steps, molecule] = min;
    queue.deleteMin()!;

    if (seen.has(molecule)) {
      continue;
    }
    else {
      seen.add(molecule);
    }

    for (const next of mutate(molecule, input.rules)) {
      if (next == input.medicine) {

        return steps + 1
      }
      else if (next.length >= N) {
        continue
      }
      else {
        queue.insert(steps + 1, next);
      }
    }
  }
}

function main() {
  const answer = part2();
  if (answer !== null) {
    console.log(answer);
  }
}
main()
