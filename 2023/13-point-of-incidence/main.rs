#!/usr/bin/env cargo +nightly -Zscript

#![feature(iter_collect_into)]

enum Dummy {}

impl std::fmt::Debug for Dummy {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "{}", 42)
    }
}

struct Grid {
    pub height: usize,
    pub width: usize,
    pub data: Vec<char>,
}

impl Grid {
    fn row(&self, j: usize) -> &[char] {
        &self.data[(j * self.width)..(j + 1) * self.width]
    }

    fn col(&self, i: usize) -> String {
        (0..self.height)
            .map(move |j| self.data[(j * self.width) + i])
            .collect()
    }

    fn check_symmetry(&self) -> usize {
        //println!("h={} w={}", self.height, self.width);
        // check columns
        'check_col: for i in 1..self.width {
            for k in 0..std::cmp::min(i, self.width - i) {
                if self.col(i - k - 1) != self.col(i + k) {
                    continue 'check_col;
                }
            }

            return i;
        }

        // check rows
        'check_row: for j in 1..self.height {
            for k in 0..std::cmp::min(j, self.height - j) {
                if self.row(j - k - 1) != self.row(j + k) {
                    continue 'check_row;
                }
            }

            return j * 100;
        }

        panic!("no symmetry")
    }
}

fn main() {
    let input = include_str!("input.txt");

    let mut tally = 0;
    let mut grid: Grid = Grid {
        height: 0,
        width: 0,
        data: Vec::new(),
    };
    for line in input.lines() {
        if line.is_empty() {
            tally += grid.check_symmetry();
            grid.height = 0;
            grid.data.clear();
        } else {
            grid.width = line.len();
            grid.height += 1;
            line.chars().collect_into(&mut grid.data);
        }
    }
    tally += grid.check_symmetry();

    println!("Part 1: {}", tally);
}
