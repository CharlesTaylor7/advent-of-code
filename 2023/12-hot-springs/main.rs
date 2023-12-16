#!/usr/bin/env cargo +nightly -Zscript

#![allow(unused_imports)]
#![allow(unused_mut)]
#![allow(unused_variables)]
#![allow(dead_code)]
#![allow(unreachable_code)]
use std::fmt::{Debug, Formatter};

#[derive(Debug)]
enum Spring {
    Working,
    Broken,
    Unknown,
}
#[derive(Debug)]
struct SpringRow {
    pub springs: Vec<Spring>,
    pub counts: Vec<usize>,
}

impl SpringRow {
    pub fn ways(&self) -> usize {
        //(self);
        self.ways_rec(0, 0, 0)
    }

    fn ways_rec(&self, s: usize, c: usize, run: usize) -> usize {
        // println!("s: {}, c: {}, run: {}", s, c, run);
        let max_s = self.springs.len() - 1;
        let max_c = self.counts.len() - 1;
        if s > max_s {
            return if c > max_c && run == 0 {
                1
            } else if c == max_c && self.counts[c] == run {
                1
            } else {
                0
            };
        }

        match self.springs[s] {
            Spring::Broken => {
                if run < self.counts[c] {
                    self.ways_rec(s + 1, c, run + 1)
                } else {
                    0
                }
            }
            Spring::Working => {
                if run == 0 {
                    self.ways_rec(s + 1, c, 0)
                } else if self.counts.get(c).map_or(false, |x| *x == run) {
                    self.ways_rec(s + 1, c + 1, 0)
                } else {
                    0
                }
            }
            Spring::Unknown => {
                todo!();
            }
        }
    }
}

fn main() {
    let text = include_str!("example2.txt");
    let tally: usize = text
        .lines()
        .map(|line| {
            let split = line.split(" ").collect::<Vec<_>>();
            let springs = split[0]
                .chars()
                .map(|c| match c {
                    '.' => Spring::Working,
                    '#' => Spring::Broken,
                    '?' => Spring::Unknown,
                    _ => panic!(),
                })
                .collect();

            let counts = split[1].split(",").map(|x| x.parse().unwrap()).collect();

            let row = SpringRow { springs, counts };

            row.ways()
        })
        .sum();

    println!("Part 1: {}", tally);
}

#[cfg(test)]
mod tests {
    use crate::*;

    #[test]
    pub fn dummy() {
        assert_eq!(2 + 2, 4);
    }
}
