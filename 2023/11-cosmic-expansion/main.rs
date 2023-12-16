#!/usr/bin/env cargo +nightly -Zscript

#![allow(unused_imports)]
#![allow(unused_mut)]
#![allow(unused_variables)]
use std::fmt::{Debug, Formatter};

enum Dummy {}

impl Debug for Dummy {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        unreachable!()
    }
}

fn main() -> std::io::Result<()> {
    let text = include_str!("input.txt");
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
