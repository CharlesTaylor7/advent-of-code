#!/usr/bin/env cargo +nightly -Zscript

#![allow(unused_imports)]
#![allow(unused_mut)]
#![allow(unused_variables)]
#![allow(dead_code)]
#![allow(unreachable_code)]

use std::collections::HashSet;

struct Map {
    pub width: usize,
    pub height: usize,
    pub data: Vec<Tile>,
}

impl Map {
    fn energize_from(&self, point: Point, dir: Direction) -> usize {
        let mut to_check = Vec::with_capacity(self.data.len());
        to_check.push((point, dir));

        let mut energized: HashSet<usize> = HashSet::with_capacity(self.data.len());
        let mut seen: HashSet<String> = HashSet::with_capacity(4 * self.data.len());
        let mut dir_buffer = Vec::with_capacity(2);

        while let Some((point, dir)) = to_check.pop() {
            let key = point.x + point.y * self.width;
            energized.insert(key);
            if !seen.insert(format!("{}-{:#?}", key, dir)) {
                continue;
            }

            check_tile(self.data[key], dir, &mut dir_buffer);
            for d in dir_buffer.iter() {
                if let Some(next) = self.advance(&point, &d) {
                    to_check.push((next, *d))
                }
            }
        }

        return energized.len();
    }

    fn advance(&self, point: &Point, dir: &Direction) -> Option<Point> {
        match dir {
            Direction::South => {
                if point.y + 1 >= self.height {
                    None
                } else {
                    Some(Point {
                        x: point.x,
                        y: point.y + 1,
                    })
                }
            }
            Direction::East => {
                if point.x + 1 >= self.width {
                    None
                } else {
                    Some(Point {
                        x: point.x + 1,
                        y: point.y,
                    })
                }
            }

            Direction::North => {
                if point.y == 0 {
                    None
                } else {
                    Some(Point {
                        x: point.x,
                        y: point.y - 1,
                    })
                }
            }

            Direction::West => {
                if point.x == 0 {
                    None
                } else {
                    Some(Point {
                        x: point.x - 1,
                        y: point.y,
                    })
                }
            }
        }
    }
}

struct Point {
    pub x: usize,
    pub y: usize,
}

#[derive(Debug, Copy, Clone)]
enum Direction {
    North,
    East,
    West,
    South,
}

#[derive(Copy, Clone)]
enum Tile {
    MirrorSE, // reflects South into East
    MirrorSW, // reflects South into West
    VerticalSplitter,
    HorizontalSplitter,
    Empty,
}

fn check_tile(tile: Tile, dir: Direction, dirs: &mut Vec<Direction>) {
    dirs.clear();
    match tile {
        Tile::Empty => {
            dirs.push(dir);
        }
        Tile::MirrorSW => {
            dirs.push(match dir {
                Direction::South => Direction::West,
                Direction::West => Direction::South,
                Direction::North => Direction::East,
                Direction::East => Direction::North,
            });
        }
        Tile::MirrorSE => {
            dirs.push(match dir {
                Direction::South => Direction::East,
                Direction::East => Direction::South,
                Direction::North => Direction::West,
                Direction::West => Direction::North,
            });
        }
        Tile::VerticalSplitter => {
            match dir {
                Direction::South => dirs.push(dir),
                Direction::North => dirs.push(dir),
                Direction::East => {
                    dirs.push(Direction::North);
                    dirs.push(Direction::South);
                }
                Direction::West => {
                    dirs.push(Direction::North);
                    dirs.push(Direction::South);
                }
            };
        }
        Tile::HorizontalSplitter => {
            match dir {
                Direction::East => dirs.push(dir),
                Direction::West => dirs.push(dir),
                Direction::North => {
                    dirs.push(Direction::East);
                    dirs.push(Direction::West);
                }
                Direction::South => {
                    dirs.push(Direction::East);
                    dirs.push(Direction::West);
                }
            };
        }
    }
}
fn main() {
    let input = include_str!("input.txt");

    let mut map = Map {
        width: 0,
        height: 0,
        data: Vec::with_capacity(input.len()),
    };
    for line in input.lines() {
        map.width = line.len();
        map.height += 1;
        for c in line.chars() {
            let tile = match c {
                '.' => Tile::Empty,
                '\\' => Tile::MirrorSE,
                '/' => Tile::MirrorSW,
                '-' => Tile::HorizontalSplitter,
                '|' => Tile::VerticalSplitter,
                _ => panic!("unrecognized character: {}", c),
            };
            map.data.push(tile);
        }
    }
    let part1 = map.energize_from(Point { x: 0, y: 0 }, Direction::East);
    println!("Part 1: {}", part1);

    let mut max = 0;
    for x in 0..map.width {
        let e = map.energize_from(Point { x, y: 0 }, Direction::South);
        if e > max {
            max = e;
        }
    }
    for x in 0..map.width {
        let e = map.energize_from(
            Point {
                x,
                y: map.height - 1,
            },
            Direction::North,
        );
        if e > max {
            max = e;
        }
    }
    for y in 0..map.height {
        let e = map.energize_from(Point { x: 0, y }, Direction::East);
        if e > max {
            max = e;
        }
    }
    for y in 0..map.height {
        let e = map.energize_from(
            Point {
                x: map.width - 1,
                y,
            },
            Direction::West,
        );
        if e > max {
            max = e;
        }
    }

    println!("Part 2: {}", max);
}
