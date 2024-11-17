#![allow(unused_imports)]
#![allow(unused_mut)]
#![allow(unused_variables)]
#![allow(dead_code)]
#![allow(unreachable_code)]
// brute force
use anyhow::{anyhow, bail, Result};
use std::{
    collections::hash_map::{Entry, HashMap},
    collections::HashSet,
    rc::Rc,
};

#[derive(Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
enum Digit {
    One,
    Two,
    Three,
}

impl std::fmt::Debug for Digit {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "{}", digit_to_int(*self))
    }
}

// brute force go brrr..
// john conway's description of atomic elements would be interesting to try out eventually.
fn main() -> Result<()> {
    let input = include_str!("input.txt");

    //    println!("Input:\n{input}");
    let mut current = input.trim().chars().map(char_to_digit).collect::<Vec<_>>();
    let mut next = Vec::new();
    for i in 0..50 {
        look_and_say(&current, &mut next);
        current.clear();
        std::mem::swap(&mut current, &mut next);
    }
    println!("{}", current.len());

    Ok(())
}

fn look_and_say(input: &[Digit], result: &mut Vec<Digit>) {
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
    if let Some(item) = item {
        result.push(int_to_digit(count));
        result.push(item);
    }
}

fn char_to_digit(c: char) -> Digit {
    match c {
        '1' => Digit::One,
        '2' => Digit::Two,
        '3' => Digit::Three,
        _ => panic!("unexpected: {c}"),
    }
}

fn digit_to_int(digit: Digit) -> u8 {
    match digit {
        Digit::One => 1,
        Digit::Two => 2,
        Digit::Three => 3,
    }
}

fn int_to_digit(num: u8) -> Digit {
    match num {
        1 => Digit::One,
        2 => Digit::Two,
        3 => Digit::Three,
        _ => panic!("unexpected: {num}"),
    }
}
