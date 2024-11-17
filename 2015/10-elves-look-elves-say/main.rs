#![allow(unused_imports)]
#![allow(unused_mut)]
#![allow(unused_variables)]
#![allow(dead_code)]
#![allow(unreachable_code)]
use anyhow::{anyhow, bail, Result};
use std::{
    collections::hash_map::{Entry, HashMap},
    collections::HashSet,
    rc::Rc,
};

type Seq = (Rc<[Digit]>);
type Cache = HashMap<Seq, Seq>;
type AtomicElements = HashSet<Seq>;

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
//
// impl std::fmt::Debug for Seq {
//     fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
//         let result = self
//
//             .iter()
//             .copied()
//             .map(digit_to_int)
//             .map(|i| i.to_string())
//             .collect::<String>();
//         write!(f, "{}", result)
//     }
// }

fn main() -> Result<()> {
    let (cache, elements) = run(5);
    println!("{cache:#?}");
    println!("{elements:#?}");

    let input = include_str!("input.txt");

    //    println!("Input:\n{input}");
    let input = input.trim().chars().map(char_to_digit).collect::<Seq>();
    // println!("Input:\n{input:#?}");

    Ok(())
}

fn run(safety: usize) -> (Cache, AtomicElements) {
    let mut count = 0;
    let hydrogen = Seq::from([Digit::Two, Digit::Two]);
    let mut cache = Cache::from([(hydrogen.clone(), hydrogen.clone())]);
    let mut elements = AtomicElements::from([hydrogen]);

    let seed = Seq::from([Digit::One]);
    let mut current: Seq = seed;

    while count < safety && elements.len() < 94 {
        count += 1;

        let result = look_and_say_with(&mut cache, current.clone());
        // check all non-trivial splits
        for i in 1..(current.len()) {
            let (left, right) = current.split_at(i);

            let mut combined = look_and_say_with(&mut cache, Seq::from(left)).to_vec();
            combined.extend_from_slice(&look_and_say_with(&mut cache, Seq::from(right)));

            if combined.iter().zip(result.iter()).all(|(a, b)| a == b) {
                // elements.insert(Seq::from(left));
                elements.insert(Seq::from(right));
            }
        }
        current = result;
    }

    (cache, elements)
}

fn look_and_say_with(cache: &mut Cache, input: Seq) -> Seq {
    match cache.entry(input.clone()) {
        Entry::Occupied(e) => e.get().clone(),
        Entry::Vacant(e) => e.insert(look_and_say(input)).clone(),
    }
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
    if let Some(item) = item {
        result.push(int_to_digit(count));
        result.push(item);
    }
    Seq::from(result)
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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn look_and_say_test() {
        assert_eq!(
            look_and_say([Digit::One].into()),
            [Digit::One, Digit::One].into()
        );
    }
}
