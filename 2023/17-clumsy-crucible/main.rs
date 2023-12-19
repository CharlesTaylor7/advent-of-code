#!/usr/bin/env cargo +nightly -Zscript

#![allow(unused_imports)]
#![allow(unused_mut)]
#![allow(unused_variables)]
#![allow(dead_code)]
#![allow(unreachable_code)]
#![feature(ascii_char)]

struct Map {
    pub width: usize,
    pub height: usize,
    pub data: Vec<u8>,
}

fn main() {
    let input = include_str!("example.txt");

    let mut map = Map {
        width: 0,
        height: 0,
        data: Vec::with_capacity(input.len()),
    };
    for line in input.lines() {
        for c in line.chars() {
            map.data.push(c.to_string().parse().unwrap());
        }
    }
    println!("Part 1: {:#?}", map.data);
}
