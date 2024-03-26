#!/usr/bin/env cargo +nightly -Zscript
#![allow(unused_imports)]
#![allow(unused_mut)]
#![allow(unused_variables)]
#![allow(dead_code)]
#![allow(unreachable_code)]
#![feature(ascii_char, ascii_char_variants)]
//! ```cargo
//! [dependencies]
//! anyhow = "*"
//! ```
use std::{rc::Rc, collections::{HashMap, HashSet}};
use anyhow::{anyhow, bail, Result};
use std::ascii::Char;


fn main() -> Result<()> {
    let input = include_str!("input.txt");

    let width = input.find('\n').expect("newline");
    let height = input.len() / (width + 1);
    let start = input.find('S').expect("start");
    let input = input.as_ascii().expect("ascii");

    let mut visited: HashSet<usize> = HashSet::new();
    visited.insert(start);

    for _ in 0..64 {
        let mut next = HashSet::new();
        for value in visited {
            let col = value % (width + 1);
            let row = value / (width + 1);
            if col > 0 && input[value - 1] != Char::NumberSign {
                next.insert(value - 1);
            }
            if col < width && input[value + 1] != Char::NumberSign {
                next.insert(value + 1);
            }
            if row > 0 && input[value - (width + 1)] != Char::NumberSign {
                next.insert(value - (width + 1));
            }

            if row + 1 < height && input[value + (width + 1)] != Char::NumberSign {
                next.insert(value + (width + 1));
            }
        }

        visited = next;
    }

    println!("dimensions: {} x {}", width, height);
    println!("Part 1: {}", visited.len());
    Ok(())
}

