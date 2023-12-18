#!/usr/bin/env cargo +nightly -Zscript

#![allow(unused_imports)]
#![allow(unused_mut)]
#![allow(unused_variables)]
#![allow(dead_code)]
#![allow(unreachable_code)]

use std::collections::hash_map::Entry;
use std::collections::HashMap;

fn part1(input: &str) {
    let mut part1: usize = 0;
    let mut hash: usize = 0;
    const COMMA: u8 = 44;
    const NEWLINE: u8 = 10;
    for s in input.as_bytes() {
        if *s == COMMA || *s == NEWLINE {
            part1 += hash;
            hash = 0;
        } else {
            hash += *s as usize;
            hash *= 17;
            hash %= 256;
        }
    }
    part1 += hash;

    println!("Part 1: {}", part1);
}

fn hash(label: &str) -> usize {
    let mut result = 0;
    for b in label.as_bytes() {
        result += *b as usize;
        result *= 17;
        result %= 256;
    }
    result
}

#[derive(Clone, Debug)]
struct LensBox {
    pub data: HashMap<String, Lens>,
    pub order: usize,
}

impl LensBox {
    fn new() -> Self {
        Self {
            data: HashMap::new(),
            order: 0,
        }
    }
}

#[derive(Clone, Debug)]
struct Lens {
    focal: usize,
    order: usize,
    deleted: bool,
}

fn part2(input: &str) {
    let mut boxes: Vec<LensBox> = vec![LensBox::new(); 256];
    for cmd in input.split(',') {
        let mut label = String::new();
        let mut focal_str = String::new();
        for c in cmd.chars() {
            if c.is_ascii_lowercase() {
                label.push(c);
            } else if c == '-' {
                let h = hash(&label);
                boxes[h]
                    .data
                    .get_mut(&label)
                    .map(|lens| lens.deleted = true);

                //println!("remove: {}", label);
            } else if c.is_ascii_digit() {
                focal_str.push(c)
            }
        }

        if focal_str.len() > 0 {
            let h = hash(&label);
            let focal = focal_str.parse().unwrap();

            //println!("label: {}, focal: {}", label, focal);

            let order = boxes[h].order;
            match boxes[h].data.entry(label) {
                Entry::Occupied(mut e) => {
                    if e.get().deleted {
                        let default = Lens {
                            order,
                            focal,
                            deleted: false,
                        };
                        e.insert(default);
                        boxes[h].order += 1;
                    } else {
                        e.get_mut().focal = focal;
                    }
                }

                std::collections::hash_map::Entry::Vacant(e) => {
                    let default = Lens {
                        order,
                        focal,
                        deleted: false,
                    };
                    e.insert(default);
                    boxes[h].order += 1;
                }
            }
        }
    }
    //println!("{:#?}", boxes);
    let part2 = boxes
        .iter()
        .enumerate()
        .map(|(i, lens_box)| {
            (i + 1) * {
                let mut v: Vec<&Lens> = lens_box
                    .data
                    .values()
                    .filter(|lens| !lens.deleted)
                    .collect();
                v.sort_unstable_by_key(|lens| lens.order);

                v.into_iter()
                    .enumerate()
                    .map(|(i, lens)| (i + 1) * lens.focal)
                    .sum::<usize>()
            }
        })
        .sum::<usize>();

    println!("Part 2: {}", part2);
}

fn main() {
    let input = include_str!("input.txt");
    part1(&input);
    part2(&input);
}
