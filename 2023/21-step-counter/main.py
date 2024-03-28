from typing import Tuple
from dataclasses import dataclass, field


# Since there are only two types of tiles, we can save space by just
# recording all the rock locations as a set
@dataclass
class Garden:
    start: Tuple[int, int] = (0, 0)
    rocks: set[Tuple[int, int]] = field(default_factory=set)
    width: int = 0
    height: int = 0

    def parse(self, file_path: str) -> "Garden":
        with open(file_path, "r") as file:
            for y, line in enumerate(file.readlines()):
                for x, char in enumerate(line):
                    if char == "#":
                        self.rocks.add((x, y))
                    elif char == "S":
                        self.start = (x, y)

        self.width = x + 1  # pyright: ignore
        self.height = y + 1  # pyright: ignore

        return self

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
    return Garden().parse(file).solve(step_count)


assert main("./2023/21-step-counter/example.txt", 6) == 16
assert main("./2023/21-step-counter/input.txt", 64) == 3820
