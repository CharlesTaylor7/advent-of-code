#!/usr/bin/env cargo +nightly -Zscript

#![feature(iter_collect_into)]

use std::collections::HashMap;

#[derive(Debug, Copy, Clone)]
enum Direction {
    North,
    West,
    South,
    East,
}
impl Direction {
    const ALL: [Direction; 4] = [
        Direction::North,
        Direction::West,
        Direction::South,
        Direction::East,
    ];
}

#[derive(PartialEq)]
enum Tile {
    Empty,
    Slide,
    Fixed,
}

struct Grid {
    pub width: usize,
    pub height: usize,
    pub data: Vec<Tile>,
}

impl std::fmt::Debug for Grid {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        let mut data = String::with_capacity((self.width + 1) * self.height);
        for row in 0..self.height {
            for col in 0..self.width {
                data.push(match self.data[row * self.width + col] {
                    Tile::Empty => '.',
                    Tile::Slide => 'O',
                    Tile::Fixed => '#',
                })
            }
            data.push('\n')
        }
        write!(f, "{}", data)
    }
}

impl Grid {
    fn load(&self) -> usize {
        let mut tally = 0;
        for i in 0..self.width {
            for j in 0..self.height {
                if self.data[j * self.width + i] == Tile::Slide {
                    tally += self.height - j;
                }
            }
        }

        tally
    }

    fn tilt(&mut self, direction: Direction) {
        match direction {
            Direction::North => self.tilt_north(),
            Direction::West => self.tilt_west(),
            Direction::South => self.tilt_south(),
            Direction::East => self.tilt_east(),
        }
    }

    fn tilt_north(&mut self) {
        for i in 0..self.width {
            let mut row = 0;
            for j in 0..self.height {
                match self.data[j * self.width + i] {
                    Tile::Slide => {
                        self.data[j * self.width + i] = Tile::Empty;
                        self.data[row * self.width + i] = Tile::Slide;
                        row += 1;
                    }
                    Tile::Fixed => row = j + 1,
                    Tile::Empty => {}
                }
            }
        }
    }

    fn tilt_south(&mut self) {
        for i in 0..self.width {
            let mut row = self.height;
            for k in 0..self.height {
                let j = self.height - 1 - k;
                match self.data[j * self.width + i] {
                    Tile::Slide => {
                        self.data[j * self.width + i] = Tile::Empty;
                        self.data[(row - 1) * self.width + i] = Tile::Slide;
                        row -= 1;
                    }
                    Tile::Fixed => row = j,
                    Tile::Empty => {}
                }
            }
        }
    }

    fn tilt_west(&mut self) {
        for j in 0..self.height {
            let mut col = 0;
            for i in 0..self.width {
                match self.data[j * self.width + i] {
                    Tile::Slide => {
                        self.data[j * self.width + i] = Tile::Empty;
                        self.data[j * self.width + col] = Tile::Slide;
                        col += 1;
                    }
                    Tile::Fixed => col = i + 1,
                    Tile::Empty => {}
                }
            }
        }
    }

    fn tilt_east(&mut self) {
        for j in 0..self.height {
            let mut col = self.height;
            for k in 0..self.width {
                let i = self.height - 1 - k;
                match self.data[j * self.width + i] {
                    Tile::Slide => {
                        self.data[j * self.width + i] = Tile::Empty;
                        self.data[j * self.width + (col - 1)] = Tile::Slide;
                        col -= 1;
                    }
                    Tile::Fixed => col = i,
                    Tile::Empty => {}
                }
            }
        }
    }
}

fn main() {
    let input = include_str!("input.txt");

    let mut grid = Grid {
        width: 0,
        height: 0,
        data: Vec::new(),
    };
    for line in input.lines() {
        grid.width = line.len();
        grid.height += 1;
        line.chars()
            .map(|c| match c {
                '.' => Tile::Empty,
                'O' => Tile::Slide,
                '#' => Tile::Fixed,
                _ => panic!("Unrecognized character tile: {c}"),
            })
            .collect_into(&mut grid.data);
    }

    let mut seen: HashMap<String, usize> = HashMap::new();
    let mut first = true;
    const CYCLES: usize = 1_000_000_000;
    for n in 0..CYCLES {
        for d in Direction::ALL {
            grid.tilt(d);
            if first {
                println!("Part 1: {}", grid.load());
                first = false;
            }
        }
        let text = format!("{:#?}", grid);
        if let Some(p) = seen.insert(text, n) {
            let interval = n - p;
            let rest = (CYCLES - p - 1) % interval;
            for _ in 0..rest {
                for d in Direction::ALL {
                    grid.tilt(d);
                }
            }
            println!("Part 2: {}", grid.load());
            break;
        }
    }
}
