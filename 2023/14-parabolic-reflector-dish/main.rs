#!/usr/bin/env cargo +nightly -Zscript

#![allow(unused_imports)]
#![allow(unused_mut)]
#![allow(unused_variables)]
#![allow(dead_code)]
#![allow(unreachable_code)]
#![feature(iter_collect_into)]

enum Dummy {}

impl std::fmt::Debug for Dummy {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "{}", 42)
    }
}

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

impl Grid {
    fn load(&self) -> usize {
        let mut tally = 0;
        for i in 0..self.width {
            let mut level = 0;
            for j in 0..self.height {
                match self.data[j * self.width + i] {
                    Tile::Slide => {
                        tally += self.height - level;
                        level += 1;
                    }
                    Tile::Fixed => level = j + 1,
                    Tile::Empty => {}
                }
            }
        }

        tally
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
    println!("Input:\n{input}");
    println!("Part 1: {}", grid.load());
}

#[cfg(test)]
mod tests {
    use crate::*;

    #[test]
    pub fn dummy() {
        assert_eq!(2 + 2, 4);
    }
}
