const REGEX =
  /\w+: capacity (?<capacity>-?\d+), durability (?<durability>-?\d+), flavor (?<flavor>-?\d+), texture (?<texture>-?\d+), calories (?<calories>-?\d+)/;

type Calories = number;
type Capacity = number;
type Durability = number;
type Flavor = number;
type Texture = number;

type Vector = [Calories, Capacity, Durability, Flavor, Texture];

function brand(
  groups: Record<string, string>,
  field: string,
) {
  return Number(groups[field]);
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
  console.log(matrix);

  // calories -> List of vectors that hit that calorie count
  const ways: Array<Set<string>> = Array(500);
  ways.push([[0, 0, 0, 0, 0]]);

  let max = Number.NEGATIVE_INFINITY;
  const seen = new Set<string>();

  heap.insert(-tastiness(initial), initial);
  while (true) {
    const min = heap.findMin();
    if (min == null) throw new Error("heap empty!");
    const [_, vector] = min;

    for (let i = 0; i < 4; i++) {
      const next = Array.from(vector) as Vector;

      for (let j = 0; j < 5; j++) {
        next[j] += matrix[i][j];
      }

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
