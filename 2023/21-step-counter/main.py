from typing import Self, Tuple, TypeAlias, cast, Optional
from dataclasses import dataclass

Point: TypeAlias = Tuple[int, int]


def cast_not_none[T](value: Optional[T]) -> T:
    return cast(T, value)

# Since there are only two types of tiles, we can save space by just
# recording all the rock locations as a set
@dataclass
class Garden:
    start: Tuple[int, int]
    rocks: set[Tuple[int, int]]
    width: int
    height: int

    @classmethod
    def parse(cls, file_path: str) -> 'Garden':
        rocks = set()
        start = None
        with open(file_path, "r") as file:
            for y, line in enumerate(file.readlines()):
                for x, char in enumerate(line):
                    if char == "#":
                        rocks.add((x, y))
                    elif char == "S":
                        start = (x, y)

        width = x + 1  # pyright: ignore
        height = y + 1  # pyright: ignore
        start = cast_not_none(start)
        return Garden(start=start, rocks=rocks, height=height, width=width)

    def solve(self, step_count: int) -> int:
        visited = {self.start}
        for _ in range(step_count):
            next = set()
            for x, y in visited:
                # left
                if x > 0 and (x - 1, y) not in self.rocks:
                    next.add((x - 1, y))

                # right
                if x < self.width - 1 and (x + 1, y) not in self.rocks:
                    next.add((x + 1, y))

                # above
                if y > 0 and (x, y - 1) not in self.rocks:
                    next.add((x, y - 1))

                # below
                if y < self.height - 1 and (x, y + 1) not in self.rocks:
                    next.add((x, y + 1))

            visited = next

        return len(visited)


def main(file: str, step_count: int) -> int:
    return Garden.parse(file).solve(step_count)


assert main("./2023/21-step-counter/example.txt", 6) == 16
assert main("./2023/21-step-counter/input.txt", 64) == 3820
