#!/usr/bin/env python3
import sys
import time
from typing import Iterator, Literal, Tuple, TypeAlias
from dataclasses import dataclass, field

Point: TypeAlias = Tuple[int, int]
Part: TypeAlias = Literal["part-1", "part-2"]


def is_even(point: Point) -> bool:
    return (point[0] + point[1]) % 2 == 0


def is_odd(point: Point) -> bool:
    return (point[0] + point[1]) % 2 == 1


# Since there are only two types of tiles, we can save space by just
# recording all the rock locations as a set
@dataclass
class Garden:
    start: Point
    rocks: set[Point]
    width: int
    height: int

    min_x: int
    max_x: int
    min_y: int
    max_y: int
    wave: list[Point] = field(default_factory=list)
    visited: set[Point] = field(default_factory=set)

    @classmethod
    def parse(cls, file_path: str) -> "Garden":
        rocks = set()
        start = None
        x = 0
        y = 0
        with open(file_path, "r") as file:
            for y, line in enumerate(file.readlines()):
                for x, char in enumerate(line):
                    if char == "#":
                        rocks.add((x, y))
                    elif char == "S":
                        start = (x, y)

        width = x
        height = y + 1
        # print("width", width)
        # print("height", width)

        assert start is not None
        return Garden(
            start=start,
            rocks=rocks,
            height=height,
            width=width,
            min_x=0,
            max_x=width - 1,
            min_y=0,
            max_y=height - 1,
        )

    def print(self, step: int):
        sys.stdout.write("\033c")

        sys.stdout.write(f"step {step}\n\n")
        for y in range(self.min_y, self.max_y + 1):
            for x in range(self.min_x, self.max_x + 1):
                if (x, y) in self.wave:
                    sys.stdout.write("*")
                elif (x, y) in self.visited:
                    sys.stdout.write("-")
                elif (x % self.width, y % self.height) in self.rocks:
                    sys.stdout.write("#")
                else:
                    sys.stdout.write(".")
            sys.stdout.write("\n")

        sys.stdout.flush()
        time.sleep(0.5)

    def part1(self, step_count: int) -> int:
        self.visited = {self.start}
        for _ in range(step_count):
            next = set()
            for x, y in self.visited:
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

            self.visited = next

        return len(self.visited)

    def neighbors(self) -> Iterator[Point]:
        for x, y in self.wave:
            # left
            yield (x - 1, y)

            # right
            yield (x + 1, y)

            # above
            yield (x, y - 1)

            # below
            yield (x, y + 1)

    def part2(self, step_count: int) -> int:
        self.wave = [self.start]
        self.visited = {self.start}
        for step in range(step_count):
            self.print(step)
            next = []
            for point in self.neighbors():
                normalized = (point[0] % self.width, point[1] % self.height)
                if normalized not in self.rocks and point not in self.visited:
                    next.append(point)
                    self.visited.add(point)

                    """
                    if point[0] < self.min_x:
                        self.min_x -= self.width

                    if point[0] > self.max_x:
                        self.max_x += self.width

                    if point[1] < self.min_y:
                        self.min_y -= self.height

                    if point[1] > self.max_y:
                        self.max_y += self.height
                    """

            self.wave = next

        if (step_count % 2 == 0) ^ is_even(self.start):
            return sum(1 for point in self.visited if is_odd(point))
        else:
            return sum(1 for point in self.visited if is_even(point))


def run(file: str, part: Part, step_count: int) -> int:
    garden = Garden.parse(file)
    return garden.part1(step_count) if part == "part-1" else garden.part2(step_count)


def test_part1():
    assert run("./2023/21-step-counter/example.txt", "part-1", 6) == 16
    assert run("./2023/21-step-counter/input.txt", "part-1", 64) == 3820


def test_part2_small():
    assert run("./2023/21-step-counter/example.txt", "part-2", 6) == 16
    assert run("./2023/21-step-counter/example.txt", "part-2", 10) == 50
    assert run("./2023/21-step-counter/example.txt", "part-2", 50) == 1594
    assert run("./2023/21-step-counter/example.txt", "part-2", 100) == 6536


def test_part2_large():
    assert run("./2023/21-step-counter/example.txt", "part-2", 500) == 167004
    assert run("./2023/21-step-counter/example.txt", "part-2", 1000) == 668697
    assert run("./2023/21-step-counter/example.txt", "part-2", 5000) == 16733044


def main():
    print(run("./2023/21-step-counter/input.txt", "part-2", 26501365))


if __name__ == "__main__":
    main()
