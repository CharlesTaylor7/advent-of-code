#!/usr/bin/env cargo +nightly -Zscript 
use std::collections::HashSet;
use std::{borrow::Cow, num::ParseIntError}; 

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Direction {
    Up,
    Right,
    Down,
    Left,
}
impl Direction {
    pub const ALL: [Direction; 4] = [Direction::Up, Direction::Right, Direction::Down, Direction::Left];

    pub fn inward(&self, orientation: &Orientation) -> Self {
        match (self, orientation) {
            (Direction::Up, Orientation::Clockwise) => Direction::Right,
            (Direction::Up, Orientation::AntiClockwise) => Direction::Left,

            (Direction::Down, Orientation::Clockwise) => Direction::Left,
            (Direction::Down, Orientation::AntiClockwise) => Direction::Right,

            (Direction::Right, Orientation::Clockwise) => Direction::Down,
            (Direction::Right, Orientation::AntiClockwise) => Direction::Up,

            (Direction::Left, Orientation::Clockwise) => Direction::Up,
            (Direction::Left, Orientation::AntiClockwise) => Direction::Down,
        }
 
    }
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
    let input = include_str!("example.txt");

    let mut orientation = Orientation::Clockwise;

    let motions = input.lines().map(|line| line_to_motion(line) ).collect::<Result<Vec<_>>>()?;

    let mut current = Point { x: 0, y: 0 };


    // we need to detect the last direction of the intersection trench path with the positive x axis.
    let mut orientation = Orientation::Clockwise;
    let mut visited = HashSet::new();
    let mut prev_y = 0_isize;
    for motion in motions.iter() {
        for _ in 0..motion.amount {
            // advance 1 square at a time and save them all into the visited set
            current.advance(&Motion{dir: motion.dir, amount: 1});
            visited.insert(current.clone());
        }
        let sign = isize::signum(current.y);
        if sign != prev_y {
            orientation = if sign > 0 { Orientation::AntiClockwise } else { Orientation::Clockwise };
        }
        if sign != 0 {
            prev_y = sign;
        }
    }

    let mut point = Point { x: 0, y: 0 };
    let mut to_visit = Vec::with_capacity(100);
    for motion in motions.iter() {
        let mut copy = point.clone();

        // advance once along the path
        // advance once inward
        copy.advance(&Motion { amount: 1, dir: motion.dir });
        copy.advance(&Motion { amount: 1, dir: motion.dir.inward(&orientation) });
        to_visit.push(copy);

        point.advance(&motion);
    }


    // we have deduced orientation, so we need to a second pass around the trench to seed the bfs
    // with points adjacent to the trench and perpendicular to the path.
    while let Some(point) = to_visit.pop() {
        if visited.contains(&point) {
            continue;
        }
        visited.insert(point.clone());

        let mut current = point;
        for d in Direction::ALL {
            current.advance(&Motion { dir: d, amount: 1});
            to_visit.push(current.clone());
            current.advance(&Motion { dir: d, amount: -1});
        }
    }

    println!("answer: {:?}", visited.len());

    Ok(())
}
