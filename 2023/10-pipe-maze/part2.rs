#!/usr/bin/env cargo +nightly -Zscript

#![allow(dead_code)]
#![allow(non_snake_case)]
#![allow(unused_variables)]
#![allow(unused_mut)]

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Direction {
    North = 1,
    East = 2,
    West = 4,
    South = 8,
}

impl Direction {
    const ALL: [Self; 4] = [
        Direction::North,
        Direction::East,
        Direction::West,
        Direction::South,
    ];

    pub const fn bit_value(&self) -> u8 {
        unsafe { std::mem::transmute(*self) }
    }
    pub unsafe fn from_bit(val: u8) -> Self {
        unsafe { std::mem::transmute(val) }
    }

    pub fn opposite(&self) -> Self {
        match self {
            Direction::North => Direction::South,
            Direction::East => Direction::West,
            Direction::West => Direction::East,
            Direction::South => Direction::North,
        }
    }
}

// Row major order matrix of map
#[derive(Debug)]
struct Map {
    height: usize,
    width: usize,
    start: Location,
    data: Vec<Tile>,
}

#[derive(Debug)]
struct Location {
    pub row: usize,
    pub col: usize,
}

impl Map {
    pub fn parse(text: &str) -> Map {
        let mut data = Vec::with_capacity(text.len());
        let mut width = 0;
        let mut row = 0;
        let mut start = None;
        for l in text.lines() {
            width = l.len();
            for (col, c) in l.chars().enumerate() {
                let cell = Tile::parse(c);
                data.push(cell);
                if cell == Tile::Start {
                    start = Some(Location { row, col })
                }
            }
            row += 1;
        }
        Map {
            height: row + 1,
            width,
            data,
            start: start.unwrap(),
        }
    }

    pub fn lookup(&self, location: &Location) -> Tile {
        self.data[location.row * self.width + location.col]
    }
}

#[derive(PartialEq, Eq, Copy, Clone, Debug)]
enum Tile {
    Pipe(Pipe),
    Empty,
    Start,
    Exterior,
    Interior,
}

impl Tile {
    pub fn parse(text: char) -> Self {
        match text {
            '.' => Tile::Empty,
            'S' => Tile::Start,
            _ => Pipe::parse(text).map_or(Tile::Empty, Tile::Pipe),
        }
    }
}

#[derive(PartialEq, Eq, Copy, Clone, Debug)]
struct Pipe(u8);

impl Pipe {
    const N_S: Self = Self(Direction::North.bit_value() + Direction::South.bit_value());
    const E_W: Self = Self(Direction::East.bit_value() + Direction::West.bit_value());

    const S_E: Self = Self(Direction::South.bit_value() + Direction::East.bit_value());
    const S_W: Self = Self(Direction::South.bit_value() + Direction::West.bit_value());
    const N_E: Self = Self(Direction::North.bit_value() + Direction::East.bit_value());
    const N_W: Self = Self(Direction::North.bit_value() + Direction::West.bit_value());

    pub fn parse(text: char) -> Option<Self> {
        match text {
            '|' => Some(Self::N_S),
            '-' => Some(Self::E_W),
            'F' => Some(Self::S_E),
            'J' => Some(Self::N_W),
            '7' => Some(Self::S_W),
            'L' => Some(Self::N_E),
            _ => None,
        }
    }

    pub fn follow(&self, from: Direction) -> Option<Direction> {
        let test = self.0 & from.bit_value();
        if test > 0 {
            unsafe { Some(Direction::from_bit(self.0 - from.bit_value())) }
        } else {
            None
        }
    }
}

fn main() -> std::io::Result<()> {
    let example = include_str!("example.txt");

    println!("{:#?}", Map::parse(example));
    for d in Direction::ALL {
        println!("{:#?} {}", d, d.bit_value());
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use crate::*;

    #[test]
    pub fn pipe_follow() {
        assert_eq!(Pipe::N_E.follow(Direction::North), Some(Direction::East));
        assert_eq!(Pipe::N_E.follow(Direction::East), Some(Direction::North));
        assert_eq!(Pipe::N_E.follow(Direction::South), None);
        assert_eq!(Pipe::N_E.follow(Direction::West), None);
    }
}
