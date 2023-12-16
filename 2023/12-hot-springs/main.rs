#!/usr/bin/env cargo +nightly -Zscript

#![allow(unused_imports)]
#![allow(unused_mut)]
#![allow(unused_variables)]
#![allow(dead_code)]
#![allow(unreachable_code)]
use std::fmt::{Debug, Formatter};

#[derive(Debug, Clone, Copy)]
enum Spring {
    Working,
    Broken,
    Unknown,
}
#[derive(Debug)]
struct SpringRow {
    pub springs: Vec<Spring>,
    pub counts: Vec<usize>,
    cache: Vec<usize>,
}

impl SpringRow {
    pub fn new(springs: Vec<Spring>, counts: Vec<usize>) -> Self {
        let cache = Vec::with_capacity(springs.len() * counts.len());
        Self {
            springs,
            counts,
            cache,
        }
    }

    pub fn ways(&mut self) -> usize {
        //(self);
        self.ways_rec(0, 0, 0, None)
    }

    // figure out how to memoize this
    fn ways_rec(&mut self, s: usize, c: usize, run: usize, spring: Option<Spring>) -> usize {
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

        match spring.unwrap_or(self.springs[s]) {
            Spring::Broken => {
                if self.counts.get(c).map_or(false, |count| run < *count) {
                    self.ways_rec(s + 1, c, run + 1, None)
                } else {
                    0
                }
            }
            Spring::Working => {
                if run == 0 {
                    self.ways_rec(s + 1, c, 0, None)
                } else if self.counts.get(c).map_or(false, |x| *x == run) {
                    self.ways_rec(s + 1, c + 1, 0, None)
                } else {
                    0
                }
            }
            Spring::Unknown => {
                self.ways_rec(s, c, run, Some(Spring::Working))
                    + self.ways_rec(s, c, run, Some(Spring::Broken))
            }
        }
    }
}

fn main() {
    let text = include_str!("input.txt");
    let mut part1: Vec<SpringRow> = text
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

            SpringRow::new(springs, counts)
        })
        .collect();

    println!(
        "Part 1: {}",
        part1.iter_mut().map(|row| row.ways()).sum::<usize>()
    );

    println!(
        "Part 2: {}",
        part1
            .iter()
            .map(|row| {
                let mut springs = Vec::with_capacity(5 * (row.springs.len() + 1) - 1);
                for _ in 0..5 {
                    springs.extend_from_slice(&row.springs);
                    springs.push(Spring::Unknown);
                }
                SpringRow::new(springs, row.counts.repeat(5)).ways()
            })
            .sum::<usize>()
    );
}

#[cfg(test)]
mod tests {
    use crate::*;

    #[test]
    pub fn dummy() {
        assert_eq!(2 + 2, 4);
    }
}
