# // idea is dynamic programming.
from typing import Tuple
import re
from os import path
REGEX = re.compile(r'\w+: capacity (?P<capacity>-?\d+), durability (?P<durability>-?\d+), flavor (?P<flavor>-?\d+), texture (?P<texture>-?\d+), calories (?P<calories>-?\d+)')

matrix = []
with open(path.normpath(path.join(__file__, "../input.txt")), 'r') as file:
    for line in file.readlines():
        match = re.match(REGEX, line)
        if (not match):
            continue
        
        matrix.append([int(v) for v in match.groups()])

def add(v1, v2):
    return (v1[0] + v2[0], v1[1] + v2[1], v1[2] + v2[2], v1[3] + v2[3], v1[4] + v2[4])

def tastiness(v):
    total = 1
    for i in range(4):
        if v[i] <= 0: 
            return 0
        total *= v[i]

    return total

Vector = Tuple[int, int, int, int, int]
ways: list[set[Vector]] = [set() for _ in range(501)]

ways[0].add((0, 0, 0, 0, 0))
for i in range(500):
    for way in ways[i]:
        for ingredient in matrix:
            cal = way[4] + ingredient[4]
            if cal > 500:
                continue
            ways[cal].add(add(way, ingredient))

print(max(tastiness(way) for way in ways[500]))


#   heap.insert(-tastiness(initial as Vector), initial as Vector);
#   while (true) {
#     const min = heap.findMin();
#     if (min == null) throw new Error("heap empty!");
#     const [_, vector] = min;
#
#     for (let i = 0; i < 4; i++) {
#       const next = Array.from(vector) as Vector;
#
#       for (let j = 0; j < 5; j++) {
#         (next as number[])[j] += matrix[i][j] as number;
#       }
#
#       console.log(next, seen.size);
#       const s = next.toString();
#       if (seen.has(s)) {
#         continue;
#       } else {
#         seen.add(s);
#       }
#
#       if (next[0] > 500) continue;
#       if (next[0] === 500) {
#         const t = tastiness(next);
#         if (t > max) max = t;
#         continue;
#       }
#
#       heap.insert(-tastiness(next), next);
#     }
#   }
#   console.log(matrix);
# }
#
# function tastiness(vector: Vector) {
#   let total = 1;
#   for (let n = 1; n < vector.length; n++) {
#     if (vector[n] <= 0) return 0;
#     total *= vector[n];
#   }
#   return total;
# }
# console.l
