#!/usr/bin/env cargo +nightly -Zscript

#![allow(unused_imports)]
#![allow(unused_mut)]
#![allow(unused_variables)]
#![allow(dead_code)]
#![allow(unreachable_code)]

fn main() {
    let input = include_bytes!("input.txt");
    let mut part1: usize = 0;
    let mut hash: usize = 0;
    const COMMA: u8 = 44;
    const NEWLINE: u8 = 10;
    for s in input {
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
    //print!("={}\n", hash);

    println!("Part 1: {}", part1);
}

#[cfg(test)]
mod tests {
    use crate::*;

    #[test]
    pub fn dummy() {
        assert_eq!(2 + 2, 4);
    }
}
