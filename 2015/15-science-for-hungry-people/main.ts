import { FibHeap } from "@/queue.ts";
const REGEX =
  /\w+: capacity (?<capacity>-?\d+), durability (?<durability>-?\d+), flavor (?<flavor>-?\d+), texture (?<texture>-?\d+), calories (?<calories>-?\d+)/;

const DIMENSIONS = ["calories", "capacity", "durability", "flavor", "texture"];
type Branded<T> = number & { __brand: T };
type Dim = typeof DIMENSIONS[number];
type Calories = Branded<"calories">;
type Capacity = Branded<"capacity">;
type Durability = Branded<"durability">;
type Flavor = Branded<"flavor">;
type Texture = Branded<"texture">;

type Vector = [Calories, Capacity, Durability, Flavor, Texture];

function brand<T extends Dim>(
  groups: Record<string, string>,
  field: T,
): Branded<T> {
  return Number(groups[field]) as Branded<T>;
}

// idea is dynamic programming.
// if
function part2() {
  const input = Deno.readTextFileSync(import.meta.dirname + "/input.txt");
  console.log(input);

  const matrix: Array<Vector> = [];
  for (const line of input.split("\n")) {
    const match = line.match(REGEX);
    if (!match?.groups) continue;
    const groups = match.groups;
    matrix.push([
      brand(groups, "calories"),
      brand(groups, "capacity"),
      brand(groups, "durability"),
      brand(groups, "flavor"),
      brand(groups, "texture"),
    ]);
  }

  const heap = new FibHeap<Vector>();
  let initial = [0, 0, 0, 0, 0];

  for (let i = 0; i < 4; i++) {
    for (let j = 0; j < 5; j++) {
      initial[j] += matrix[i][j] as number;
    }
  }

  let max = Number.NEGATIVE_INFINITY;
  const seen = new Set<string>();

  heap.insert(-tastiness(initial as Vector), initial as Vector);
  while (true) {
    const min = heap.findMin();
    if (min == null) throw new Error("heap empty!");
    const [_, vector] = min;

    for (let i = 0; i < 4; i++) {
      const next = Array.from(vector) as Vector;

      for (let j = 0; j < 5; j++) {
        (next as number[])[j] += matrix[i][j] as number;
      }

      console.log(next, seen.size);
      const s = next.toString();
      if (seen.has(s)) {
        continue;
      } else {
        seen.add(s);
      }

      if (next[0] > 500) continue;
      if (next[0] === 500) {
        const t = tastiness(next);
        if (t > max) max = t;
        continue;
      }

      heap.insert(-tastiness(next), next);
    }
  }
  console.log(matrix);
}

function tastiness(vector: Vector) {
  let total = 1;
  for (let n = 1; n < vector.length; n++) {
    if (vector[n] <= 0) return 0;
    total *= vector[n];
  }
  return total;
}
console.log(part2());
//
//
// # dumb but works
// # just start at an arbitrary point walk towards a local maximum
// export def part1 [] {
//   let costs = $in | parse -r $regex
//   mut partition = [25 25 25 25]
//   mut max = eval $costs $partition
//   mut continue = true
//   while $continue {
//     $continue = false
//     for i in (seq 0 3) {
//       for j in (seq 0 3 | filter { $in != $i }) {
//         let p = $partition | update $i { $in + 1 } | update $j { $in - 1 }
//         let score = taste $costs $p
//         if $score > $max {
//           $max = $score
//           $partition = $p
//           $continue = true
//         }
//       }
//     }
//   }
//   $max
// }
//
// export def part2 [] {
//
// }
//
// export def calories [costs: table, amounts: list<int>] {
//   $costs | get calories | into int | zip $amounts | each { |pair| $pair.0 * $pair.1 } | math sum
// }
//
// export def taste [costs: table, amounts: list<int>] {
//   let a =  $costs | get capacity | into int | zip $amounts | each { |pair| $pair.0 * $pair.1 } | math sum
//   let b = $costs | get durability | into int | zip $amounts | each { |pair| $pair.0 * $pair.1 } | math sum
//   let c = $costs | get flavor | into int | zip $amounts | each { |pair| $pair.0 * $pair.1 } | math sum
//   let d = $costs | get texture | into int | zip $amounts | each { |pair| $pair.0 * $pair.1 } | math sum
//   if $a <= 0 or $b <= 0 or $c <= 0 or $d <= 0 {
//     0
//   } else {
//     $a * $b * $c * $d
//   }
// }
//
//
//
// def count [buckets: list<int>, calories: int] {
//   stor reset
//   stor create -t calories -c { i: int, q: int, n: int }
//   stor open | query db "create index cache on calories(i, q)"
//
//   let n = ($buckets | length) - 1
//   seq 1 $calories
//   | each { go $buckets $n $in }
//   | last
// }
//
// # i is the index of the largest available bucket
// def go [buckets: list<int>, i: int, q: int] {
//   if $q == 0 { return 1 }
//   if $i < 0 { return 0 }
//   if $q < 0 { return 0 }
//   let rows = stor open | query db $"select n from calories where i = ($i) and q = ($q)"
//   if ($rows | is-not-empty) { return $rows.0.n }
//
//   let k = $buckets | get $i
//   let n = (go $buckets ($i - 1) $q) + (go $buckets ($i - 1) ($q - $k))
//   stor insert -t eggnog -d { i: $i, q: $q, n: $n }
//   $n
// }
