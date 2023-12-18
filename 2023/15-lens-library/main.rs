#!/usr/bin/env cargo +nightly -Zscript

#![allow(unused_imports)]
#![allow(unused_mut)]
#![allow(unused_variables)]
#![allow(dead_code)]
#![allow(unreachable_code)]

use std::collections::HashMap;

fn part1() {
    let input = include_str!("example.txt");
    let mut part1: usize = 0;
    let mut hash: usize = 0;
    const COMMA: u8 = 44;
    const NEWLINE: u8 = 10;
    for s in input.as_bytes() {
        if *s == COMMA || *s == NEWLINE {
            part1 += hash;
            //  print!("={}\n", hash);
            hash = 0;
            // println!("reset");
        } else {
            //print!("{}", *s as char);
            hash += *s as usize;
            // println!("Increased by {}: {}", *s as char, hash);
            hash *= 17;
            // println!("Multiplied by 17: {}", hash);
            hash %= 256;
            // println!("Modulo by 256: {}", hash);
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
struct Lens {
    focal: usize,
    order: usize,
    deleted: bool,
}

fn part2() {
    let input = include_str!("input.txt");

    let mut boxes: Vec<HashMap<String, Lens>> = vec![HashMap::new(); 256];
    for cmd in input.split(',') {
        let mut label = String::new();
        let mut focal_str = String::new();
        for c in cmd.chars() {
            if c.is_ascii_lowercase() {
                label.push(c);
            } else if c == '-' {
                let h = hash(&label);
                boxes[h].get_mut(&label).map(|lens| lens.deleted = true);
            } else if c.is_ascii_digit() {
                focal_str.push(c)
            }
        }

        if focal_str.len() > 0 {
            let h = hash(&label);
            let size = boxes[h].len();
            let focal = focal_str.parse().unwrap();
            boxes[h].insert(
                label,
                Lens {
                    focal,
                    order: size,
                    deleted: false,
                },
            );
        }
    }
    println!("{:#?}", boxes);
    let part2 = boxes
        .iter()
        .enumerate()
        .map(|(i, hash_map)| {
            (i + 1) * {
                let mut v: Vec<&Lens> = hash_map.values().filter(|lens| !lens.deleted).collect();
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
    part1();
    part2();
}
