import { FibHeap } from "./queue.ts";

interface Input {
  rules: RuleSet;
  medicine: string;
}

type RuleSet = Map<string, string[]>;

function parse() {
  const input = Deno.readTextFileSync("./input.txt");
  let medicine = "";
  const rules = new Map<string, string[]>();

  const regex = /^(\w+) \=\> (\w+)$/;

  for (const line of input.split("\n")) {
    const match = line.match(regex);
    if (match) {
      const key = match.at(1)!;
      let list = rules.get(key);
      if (list == null) rules.set(key, (list = []));
      list.push(match.at(2)!);
    } else if (line.length) medicine = line;
  }

  return { medicine, rules };
}

interface Compression {
  lookup: Map<string, string>;
  next: number;
}

const elementRegex = /[A-Z][a-z]?/g;
function compress(input: Input): Input {
  const compression: Compression = { lookup: new Map(), next: 0 };
  function compressEl(el: string) {
    if (el == "e") return "e";
    let key = compression.lookup.get(el);
    if (key == null) {
      key = String.fromCharCode("a".charCodeAt(0) + compression.next);
      compression.lookup.set(el, key);
      compression.next++;
      // skip over 'e'
      if (compression.next == 4) compression.next++;
    }
    return key;
  }

  function compressMolecule(molecule: string) {
    let output = "";
    for (const match of molecule.matchAll(elementRegex)) {
      output += compressEl(match[0]);
    }
    return output;
  }

  const output: Input = {
    rules: new Map<string, string[]>(),
    medicine: compressMolecule(input.medicine),
  };

  for (const entry of input.rules.entries()) {
    const key = compressEl(entry[0]);
    const list: string[] = [];
    output.rules.set(key, list);
    for (const value of entry[1]) {
      list.push(compressMolecule(value));
    }
  }

  console.log(output);

  return output;
}

function count(compressed: Input) {
  const results = new Set(mutate(compressed.medicine, compressed.rules));
  return results.size;
}

function* mutate(molecule: string, rules: RuleSet) {
  for (let i = 0; i < molecule.length; i++) {
    const el = molecule[i];

    const prefix = molecule.slice(0, i);
    const suffix = molecule.slice(i + 1);
    const rs = rules.get(el);
    if (!rs) continue;
    for (const replacement of rs) {
      const result = prefix + replacement + suffix;
      yield result;
    }
  }
}

function* revert(molecule: string, rules: Rule[]) {
  for (const rule of rules) {
    for (const match of molecule.matchAll(new RegExp(rule.output, "g"))) {
      const prefix = molecule.slice(0, match.index);
      const replacement = rule.input;
      const suffix = molecule.slice(match.index + rule.output.length);
      yield prefix + replacement + suffix;
    }
  }
}

function part1() {
  console.log(count(compress(parse())));
}

// part 2 needs some kind of dijkstra / BFS
// we can prune by the fact that every replacement rule increases the size of the output and we can prune molecules that are too large.
function forwardPass() {
  // the priority should be to focus on molecules that are close to the target length.
  const input = compress(parse());

  const N = input.medicine.length;

  const seen = new Set<string>();

  // we have a queue at home
  const queue = new FibHeap<string>();
  queue.insert(0, "e");

  while (true) {
    const min = queue.findMin()!;
    if (min == null) {
      console.error("Queue empty!");
      return null;
    }
    const [steps, molecule] = min;
    queue.deleteMin()!;

    if (seen.has(molecule)) {
      continue;
    } else {
      seen.add(molecule);
    }

    for (const next of mutate(molecule, input.rules)) {
      if (next == input.medicine) {
        return steps + 1;
      } else if (next.length >= N) {
        continue;
      } else {
        queue.insert(steps + 1, next);
      }
    }
  }
}
interface QueueItem {
  steps: number;
  molecule: string;
}
function backwardsPass() {
  // the priority should be to focus on molecules that are close to the target length.
  const input = compress(parse());
  const N = input.medicine.length;
  const rules = iterRules(input.rules).toArray();
  // console.log(rules);

  const seen = new Set<string>();

  // we have a queue at home
  const queue = new FibHeap<QueueItem>();
  queue.insert(N, {
    molecule: input.medicine,
    steps: 0,
  });

  while (true) {
    const min = queue.findMin()!;
    if (min == null) {
      console.error("Queue empty!");
      return null;
    }
    queue.deleteMin()!;
    const [_, { molecule, steps }] = min;

    if (seen.has(molecule)) {
      continue;
    } else {
      seen.add(molecule);
    }

    for (const next of revert(molecule, rules)) {
      if (next == "e") {
        return steps + 1;
      } else if (next.length >= N) {
        continue;
      } else {
        queue.insert(molecule.length, { steps: steps + 1, molecule: next });
      }
    }
  }
}

interface Rule {
  input: string;
  output: string;
}

function* iterRules(input: RuleSet): Generator<Rule> {
  for (const entry of input.entries()) {
    for (const value of entry[1]) {
      yield { input: entry[0], output: value };
    }
  }
}

function main() {
  const answer = backwardsPass();
  if (answer !== null) {
    console.log(answer);
  }
}
main();
