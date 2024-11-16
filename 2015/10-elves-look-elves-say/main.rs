#![allow(unused_imports)]
#![allow(unused_mut)]
#![allow(unused_variables)]
#![allow(dead_code)]
#![allow(unreachable_code)]
//! ```cargo
//! [dependencies]
//! anyhow = "*"
//! ```
use anyhow::{anyhow, bail, Result};
use std::{collections::HashMap, rc::Rc};

type Seq = Rc<[Digit]>;
type Table = HashMap<Seq, Seq>;

#[derive(Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
enum Digit {
    One,
    Two,
    Three,
}

fn main() -> Result<()> {
    let input = include_str!("input.txt");
    println!("Input:\n{input}");
    println!("Part 1: {}", 42);

    let input = input.chars().map(char_to_digit).collect::<Seq>();

    Ok(())
}

fn build_periodic_table() -> Table {
    let hydrogen = Seq::from([Digit::Two, Digit::Two]);
    let mut table = Table::from([(hydrogen.clone(), hydrogen)]);

    let seed = Seq::from([Digit::One]);
    let mut current: Seq = seed;
    while table.len() < 94 {
        if table.contains_key(&current) {}
        look_and_say(current.clone());
    }

    table
}

fn look_and_say(input: Seq) -> Seq {
    let mut result = Vec::<Digit>::new();
    let mut count = 0;
    let mut item: Option<Digit> = None;
    for c in input.iter().copied() {
        if Some(c) == item {
            count += 1;
        } else {
            if let Some(item) = item {
                result.push(int_to_digit(count));
                result.push(item);
            }
            count = 1;
            item = Some(c);
        }
    }
    Seq::from(result)
}

fn char_to_digit(c: char) -> Digit {
    match c {
        '1' => Digit::One,
        '2' => Digit::Two,
        '3' => Digit::Three,
        _ => panic!(),
    }
}

fn int_to_digit(num: u8) -> Digit {
    match num {
        1 => Digit::One,
        2 => Digit::Two,
        3 => Digit::Three,
        _ => panic!(),
    }
}

#[cfg(test)]
mod tests {
    use crate::*;

    #[test]
    pub fn dummy() {
        assert_eq!(2 + 2, 4);
    }
}
