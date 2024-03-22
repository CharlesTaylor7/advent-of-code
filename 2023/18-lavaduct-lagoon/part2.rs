#!/usr/bin/env cargo +nightly -Zscript 
//! ```cargo
//! [dependencies]
//! anyhow = "*"
//! ```
//!
use std::collections::HashSet;
use std::fs;
use std::io::{Write,BufWriter};
use anyhow::{bail, anyhow, Result};

// PArt 2 is rough...
// The hexadecimal parsing is no big deal
// but the numbers are now much larger. My code won't scale properly now..
// But just for fun let's convert the code to handle hex and see where my code breaks.
//

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

fn line_to_motion_part_1(line: &str) -> Result<Motion> {
    let parts: Vec<_> = line.split(" ").collect();
    let dir = match parts[0] {
        "R" => Direction::Right,
        "L" => Direction::Left,
        "U" => Direction::Up,
        "D" => Direction::Down,
        dir => bail!("Invalid direction: {}", dir)
    };
    let amount: isize = parts[1].parse()?;

    Ok(Motion { amount, dir })
}



fn line_to_motion(line: &str) -> Result<Motion> {
    let part = line.split(['#', ')']).nth(1).ok_or(anyhow!("line is missing hex code"))?;
    let dir = part.chars().nth(5).ok_or(anyhow!("missing 5th hex character"))?;
    let dir = match dir {
        '0' => Direction::Right,
        '1' => Direction::Right,
        '2' => Direction::Right,
        '3' => Direction::Right,
        _ => bail!("direction is out of bounds")
    };

    let hex: String = part.chars().take(5).collect();
    let amount = isize::from_str_radix(&hex, 16)?;
    Ok(Motion { amount, dir })
}

// we need to detect if the loop is being formed in a counter clockwise or clockwise direction.
// then we can use a simple bfs on the interior of the loop to calculate the carved out area.
fn main() -> Result<()> {
    let input = include_str!("input.txt");

    let mut orientation = Orientation::Clockwise;

    let motions = input.lines().map(|line| line_to_motion_part_1(line)).collect::<Result<Vec<_>>>()?;

    let mut current = Point { x: 0, y: 0 };
    let bounds = Bounds {
        min: current.clone(),
        max: current.clone(),
    };


    let mut bounds = Bounds { min: Point { x: 0, y: 0 }, max: Point { x: 0, y: 0 }};
    let mut trench = HashSet::new();
    let mut vertices = HashSet::new();
    for motion in motions.iter() {
        for _ in 0..motion.amount {
            current.advance(&Motion { amount: 1, dir: motion.dir});
            trench.insert(current.clone());
        }

        vertices.insert(dbg!(current.clone()));
       
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

    // dump to ppm
    let mut file = BufWriter::new(fs::OpenOptions::new()
            .truncate(true)
            .write(true)
            .create(true)
            .open("trench.ppm")?);

    write!(&mut file, "P6 {} {} 255\n", bounds.max.x - bounds.min.x + 1, bounds.max.y - bounds.min.y + 1)?;
    for y in bounds.min.y..=bounds.max.y {
        for x in bounds.min.x..=bounds.max.x {
            let point= &Point { x, y};

            if vertices.contains(&point) {
                // red
                file.write_all(&[255, 0, 0]).unwrap();
            }
            else if trench.contains(&point) {
                // black
                file.write_all(&[0, 0, 0]).unwrap();
            }
            else {
                // white
                file.write_all(&[255, 255, 255]).unwrap();
            }
        }
        //file.write(b"\n");
    }
    file.flush().unwrap();

    Ok(())
}
