from dataclasses import dataclass


def main():
    # Since there are only two types of tiles, we can save space by just
    # recording all the rock locations as a set
    rocks: set[int] = set()
    start: int

    with open("./2023/21-step-counter/example.txt", "r") as f:
        for y, line in enumerate(f.readlines()):
            width = len(line)
            for x, char in enumerate(line):
                if char == "#":
                    rocks.add(x + y * width)
                elif char == "S":
                    start = x + y * width


main()
