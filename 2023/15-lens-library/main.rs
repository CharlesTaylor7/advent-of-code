#!/usr/bin/env cargo +nightly -Zscript

#![allow(unused_imports)]
#![allow(unused_mut)]
#![allow(unused_variables)]
#![allow(dead_code)]
#![allow(unreachable_code)]

enum Dummy {}

impl std::fmt::Debug for Dummy {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "{}", 42)
    }
}

fn main() {
    let input = include_str!("example.txt");
    println!("Input:\n{input}");
    println!("Part 1: {}", 42);
}

#[cfg(test)]
mod tests {
    use crate::*;

    #[test]
    pub fn dummy() {
        assert_eq!(2 + 2, 4);
    }
}
