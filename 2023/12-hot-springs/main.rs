#!/usr/bin/env cargo +nightly -Zscript

#![allow(unused_imports)]
#![allow(unused_mut)]
#![allow(unused_variables)]
#![allow(dead_code)]
use std::fmt::{Debug, Formatter};

#[derive(Debug)]
enum Spring {
    Working,
    Broken,
    Unknown,
}

fn ways(springs: &[Spring], conditions: &[usize]) -> usize {
    //todo!()
    2
}

fn main() {
    let text = include_str!("example.txt");
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
                .collect::<Vec<_>>();

            let conditions = split[1]
                .split(",")
                .map(|x| x.parse().unwrap())
                .collect::<Vec<_>>();

            println!("springs: {:#?}", springs);
            println!("conditions: {:#?}", conditions);
            ways(&springs, &conditions)
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
