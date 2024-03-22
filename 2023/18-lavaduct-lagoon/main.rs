#!/usr/bin/env cargo +nightly -Zscript

#![allow(unused_imports)]
#![allow(unused_mut)]
#![allow(unused_variables)]
#![allow(dead_code)]
#![allow(unreachable_code)]

use std::{borrow::Cow, num::ParseIntError}; 

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Direction {
    Up,
    Right,
    Down,
    Left,
}

#[derive(Debug, PartialEq, Eq)]
enum Orientation {
    Clockwise,
    AntiClockwise,
}

struct Motion {
    pub amount: isize,
    pub dir: Direction,
}

#[derive(Clone, Debug, PartialEq, Eq, Hash)]
struct Point {
    pub x: isize,
    pub y: isize,
}

impl Point {
    pub fn advance(&mut self, motion: &Motion){
        let Motion { amount, dir }  = motion;
        match dir {
            Direction::Left => {
                self.x -= amount;
            }

            Direction::Right => {
                self.x += amount;
            }

            Direction::Up => {
                self.y -= amount;
            }

            Direction::Down => {
                self.y += amount;
            }
        }
    }
}

#[derive(Clone, Debug, PartialEq, Eq)]
struct Bounds {
    pub min: Point,
    pub max: Point,
}

type Result<T> = std::result::Result<T, Cow<'static, str>>;

fn line_to_motion(line: &str) -> Result<Motion> {
    let parts: Vec<_> = line.split(" ").collect();
    let dir = match parts[0] {
        "R" => Direction::Right,
        "L" => Direction::Left,
        "U" => Direction::Up,
        "D" => Direction::Down,
        dir => Err(Cow::Owned(format!("Invalid direction: {}", dir)))?
    };
    let amount: isize = parts[1].parse().map_err(|e: ParseIntError| e.to_string())?;

    Ok(Motion { amount, dir })
}

// we need to detect if the loop is being formed in a counter clockwise or clockwise direction.
// then we can use a simple bfs on the interior of the loop to calculate the carved out area.
fn main() -> Result<()> {
    let input = include_str!("custom.txt");

    let mut orientation = Orientation::Clockwise;

    let motions = input.lines().map(|line| line_to_motion(line) ).collect::<Result<Vec<_>>>()?;

    let mut current = Point { x: 0, y: 0 };
    let bounds = Bounds {
        min: current.clone(),
        max: current.clone(),
    };


    let mut bounds = Bounds { min: Point { x: 0, y: 0 }, max: Point { x: 0, y: 0 }};
    for motion in motions {
        match motion.dir {
            Direction::Down => {
                bounds.max.y = std::cmp::max(bounds.max.y, current.y);
            }

            Direction::Up => {
                bounds.min.y = std::cmp::min(bounds.min.y, current.y);
            }

            Direction::Right => {
                bounds.max.x = std::cmp::max(bounds.max.x, current.x);
            }

            Direction::Left => {
                bounds.min.x = std::cmp::min(bounds.min.x, current.x);
            }
        };
    }
    println!("Bounds: {:#?}", bounds);
    Ok(())
}
