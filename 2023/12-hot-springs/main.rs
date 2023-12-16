#!/usr/bin/env cargo +nightly -Zscript

#![feature(iter_intersperse)]
use std::collections::hash_map::HashMap;

#[derive(Debug, Clone, Copy)]
enum Spring {
    Working,
    Broken,
    Unknown,
}
struct SpringRow {
    pub springs: Vec<Spring>,
    pub counts: Vec<usize>,
}

impl std::fmt::Debug for SpringRow {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(
            f,
            "{} {}",
            self.springs
                .iter()
                .map(|s| match s {
                    Spring::Broken => '#',
                    Spring::Working => '.',
                    Spring::Unknown => '?',
                })
                .collect::<String>(),
            self.counts
                .iter()
                .map(|x| x.to_string())
                .intersperse(",".to_owned())
                .collect::<String>()
        )
    }
}

impl SpringRow {
    pub fn new(springs: Vec<Spring>, counts: Vec<usize>) -> Self {
        Self { springs, counts }
    }

    pub fn ways(&mut self) -> usize {
        dbg!(&self);
        let mut cache = HashMap::with_capacity(self.springs.len() * self.counts.len());
        self.ways_rec(&mut cache, 0, 0, 0, None)
    }

    fn ways_rec(
        &self,
        cache: &mut HashMap<usize, usize>,
        s: usize,
        c: usize,
        run: usize,
        spring: Option<Spring>,
    ) -> usize {
        //println!("s: {}, c: {}, run: {}", s, c, run);
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
        let key = s * self.counts.len() + c;
        if let Some(v) = cache.get(&key) {
            return *v;
        }

        let ways = match spring.unwrap_or(self.springs[s]) {
            Spring::Broken => {
                if self.counts.get(c).map_or(false, |count| run < *count) {
                    self.ways_rec(cache, s + 1, c, run + 1, None)
                } else {
                    0
                }
            }
            Spring::Working => {
                if run == 0 {
                    self.ways_rec(cache, s + 1, c, 0, None)
                } else if self.counts.get(c).map_or(false, |x| *x == run) {
                    self.ways_rec(cache, s + 1, c + 1, 0, None)
                } else {
                    0
                }
            }
            Spring::Unknown => {
                self.ways_rec(cache, s, c, run, Some(Spring::Working))
                    + self.ways_rec(cache, s, c, run, Some(Spring::Broken))
            }
        };
        cache.insert(key, ways);
        ways
    }
}

fn main() {
    let text = include_str!("example.txt");
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
                /*
                let mut springs = Vec::with_capacity(5 * (row.springs.len() + 1) - 1);
                for _ in 0..5 {
                    springs.extend_from_slice(&row.springs);
                    springs.push(Spring::Unknown);
                }
                */
                let unknown = vec![Spring::Unknown];
                let springs = (0..5)
                    .map(|_| &row.springs)
                    .intersperse(&unknown)
                    .flatten()
                    .copied()
                    .collect();
                SpringRow::new(springs, row.counts.repeat(5)).ways()
            })
            .sum::<usize>()
    );
}
