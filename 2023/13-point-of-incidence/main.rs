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

    fn row_iter(&self, j: usize) -> impl Iterator<Item = char> + '_ {
        self.data[(j * self.width)..(j + 1) * self.width]
            .iter()
            .copied()
    }

    fn col_iter(&self, i: usize) -> impl Iterator<Item = char> + '_ {
        (0..self.height).map(move |j| self.data[(j * self.width) + i])
    }

    fn check_symmetry_with_smudge(&self) -> usize {
        // check columns
        'check_col: for i in 1..self.width {
            let mut smudges = 0;
            for k in 0..std::cmp::min(i, self.width - i) {
                smudges += self
                    .col_iter(i - k - 1)
                    .zip(self.col_iter(i + k))
                    .filter(|(a, b)| a != b)
                    .count();
                if smudges > 1 {
                    continue 'check_col;
                }
            }

            if smudges == 1 {
                return i;
            }
        }

        // check rows
        'check_row: for j in 1..self.height {
            let mut smudges = 0;
            for k in 0..std::cmp::min(j, self.height - j) {
                let s = self
                    .row_iter(j - k - 1)
                    .zip(self.row_iter(j + k))
                    .filter(|(a, b)| a != b)
                    .count();

                smudges += s;
                if smudges > 1 {
                    continue 'check_row;
                }
            }

            if smudges == 1 {
                return j * 100;
            }
        }

        //panic!("no symmetry")
        println!("no symmetry");
        0
    }
}

fn main() {
    let input = include_str!("input.txt");

    let mut part1 = 0;
    let mut part2 = 0;
    let mut grid: Grid = Grid {
        height: 0,
        width: 0,
        data: Vec::new(),
    };
    for line in input.lines() {
        if line.is_empty() {
            part1 += grid.check_symmetry();
            part2 += grid.check_symmetry_with_smudge();
            grid.height = 0;
            grid.data.clear();
        } else {
            grid.width = line.len();
            grid.height += 1;
            line.chars().collect_into(&mut grid.data);
        }
    }
    part1 += grid.check_symmetry();
    part2 += grid.check_symmetry_with_smudge();

    println!("Part 1: {}", part1);
    println!("Part 2: {}", part2);
}
