#![allow(unused_imports)]
#![allow(unused_mut)]
#![allow(unused_variables)]
#![allow(dead_code)]
#![allow(unreachable_code)]
use anyhow::{anyhow, bail, Result};
use std::{collections::HashMap, rc::Rc};

fn main() -> Result<()> {
    let input = include_str!("input.txt");
    println!("Input:\n{input}");
    println!("Part 1: {}", 42);
    Ok(())
}

#[cfg(test)]
mod tests {
    use crate::*;

    #[test]
    pub fn dummy() {
        assert_eq!(2 + 2, 4);
    }
}
