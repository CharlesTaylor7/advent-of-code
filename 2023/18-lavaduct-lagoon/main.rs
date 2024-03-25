#!/usr/bin/env cargo +nightly -Zscript
//! ```cargo
//! [dependencies]
//! anyhow = "*"
//! ```
use anyhow::{anyhow, bail, Result};
use std::collections::HashSet;
use std::fs;
use std::io::{BufWriter, Write};

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Direction {
    Up,
    Right,
    Down,
    Left,
}

impl std::fmt::Display for Direction {
    fn fmt(&self, formatter: &mut std::fmt::Formatter) -> std::fmt::Result {
        match self {
            Direction::Right => write!(formatter, "R"),
            Direction::Left => write!(formatter, "L"),
            Direction::Up => write!(formatter, "U"),
            Direction::Down => write!(formatter, "D"),
        }
    }
}


#[derive(Debug, PartialEq, Eq)]
enum Orientation {
    Clockwise,
    AntiClockwise,
}

#[derive(Debug)]
struct Motion {
    pub amount: isize,
    pub dir: Direction,
}

impl std::fmt::Display for Motion {
    fn fmt(&self, formatter: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(formatter, "{} {}", self.dir, self.amount)
    }
}


#[derive(Clone, Debug, PartialEq, Eq, Hash)]
struct Point {
    pub x: isize,
    pub y: isize,
}

impl std::ops::Add for &Point {
    type Output = Point;
    fn add(self, rhs: Self) -> Self::Output {
       Self::Output {
           x: self.x + rhs.x,
           y: self.y + rhs.y,
       }
    }
}

impl std::fmt::Display for Point {
    fn fmt(&self, formatter: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(formatter, "({}, {})", self.x, self.y)
    }
}

impl Point {
    pub fn cross_product(&self, b: &Self) -> isize {
        self.x * b.y - self.y * b.x
    }

    pub fn advance(&mut self, motion: &Motion) {
        let Motion { amount, dir } = motion;
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
        dir => bail!("Invalid direction: {}", dir),
    };
    let amount: isize = parts[1].parse()?;

    Ok(Motion { amount, dir })
}

fn line_to_motion_part_2(line: &str) -> Result<Motion> {
    let part = line
        .split(['#', ')'])
        .nth(1)
        .ok_or(anyhow!("line is missing hex code"))?;
    let dir = part
        .chars()
        .nth(5)
        .ok_or(anyhow!("missing 5th hex character"))?;
    let dir = match dir {
        '0' => Direction::Right,
        '1' => Direction::Down,
        '2' => Direction::Left,
        '3' => Direction::Up,
        _ => bail!("direction is out of bounds"),
    };

    let hex: String = part.chars().take(5).collect();
    let amount = isize::from_str_radix(&hex, 16)?;
    Ok(Motion { amount, dir })
}

fn get_orientation(motions: &[Motion]) -> Orientation {
    // we are detecting the last interasection of the trench with positive x axis
    let mut orientation = Orientation::Clockwise;
    let mut current = Point { x: 0, y: 0 };
    let mut prev_y = 0_isize;
    for motion in motions.iter() {
        current.advance(motion);
        let sign = isize::signum(current.y);
        if sign != prev_y {
            orientation = if sign > 0 {
                Orientation::AntiClockwise
            } else {
                Orientation::Clockwise
            };
        }
        if sign != 0 {
            prev_y = sign;
        }
    }
    orientation
}

fn get_bounds(motions: &[Motion]) -> Bounds {
    let mut bounds = Bounds {
        min: Point { x: 0, y: 0 },
        max: Point { x: 0, y: 0 },
    };
    let mut current = Point { x: 0, y: 0 };
    for motion in motions {
        current.advance(motion);
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
    bounds
}


fn dump_ppm(motions: &[Motion], bounds: &Bounds) -> Result<()> {
    let mut current = Point { x: 0, y: 0 };
    let mut trench = HashSet::new();
    let mut vertices = HashSet::new();
    for motion in motions {
        for _ in 0..motion.amount {
            current.advance(&Motion {
                amount: 1,
                dir: motion.dir,
            });
            trench.insert(current.clone());
        }
        vertices.insert(current.clone());
    }
    let mut file = BufWriter::new(
        fs::OpenOptions::new()
            .truncate(true)
            .write(true)
            .create(true)
            .open("trench.ppm")?,
    );

    write!(
        &mut file,
        "P6 {} {} 255\n",
        bounds.max.x - bounds.min.x + 1,
        bounds.max.y - bounds.min.y + 1
    )?;
    for y in bounds.min.y..=bounds.max.y {
        for x in bounds.min.x..=bounds.max.x {
            let point = &Point { x, y };

            if vertices.contains(&point) {
                // red
                file.write_all(&[255, 0, 0]).unwrap();
            } else if trench.contains(&point) {
                // black
                file.write_all(&[0, 0, 0]).unwrap();
            } else {
                // white
                file.write_all(&[255, 255, 255]).unwrap();
            }
        }
    }
    file.flush().unwrap();
    Ok(())
}


// The corner is a small adjustment to trace around the outside of the trenches perimeter. 
// We shift up to 1 square down or to the right.
fn adjust_corner(corner: &mut Point, dir: Direction) {
    match dir {
        Direction::Right => { corner.y = 0; },
        Direction::Left => { corner.y = 1; },

        Direction::Up => { corner.x = 0; },
        Direction::Down => { corner.x = 1; },
    }
}

fn get_vertices(motions: &[Motion], _orientation: Orientation) -> Vec<Point> {
    let n = motions.len();
    let mut vertices = Vec::<Point>::with_capacity(n);

    let mut current = Point { x: 0, y: 0 };
    // The corner is a small adjustment to trace around the outside of the trenches perimeter. 
    // We shift up to 1 square down or to the right.
    let mut corner = Point { x: 0, y: 0 };
    adjust_corner(&mut corner, motions.last().expect("non empty list").dir);
    for motion in motions.iter() {
        adjust_corner(&mut corner, motion.dir);
        let point = &current + &corner;

        vertices.push(point);

        current.advance(motion);
    }
    vertices
}


fn get_area(vertices: &[Point]) -> isize {
    let mut signed_area = 0_isize;
    for i in 0..vertices.len() - 1 {
        let block = vertices[i].cross_product(&vertices[i+1]);
        signed_area += block;
    }
    signed_area.abs() / 2
}

pub enum Part {
    Part1, Part2
}

pub fn run(part: Part) -> Result<isize> {
    let func = match part { Part::Part1 => line_to_motion_part_1, Part::Part2 => line_to_motion_part_2 };
    let input = include_str!("input.txt");
    let motions = input
        .lines()
        .map(func)
        .collect::<Result<Vec<_>>>()?;

    if matches!(part, Part::Part1) {
        let bounds = get_bounds(&motions);
        dump_ppm(&motions, &bounds)?;
    }

    let orientation = get_orientation(&motions);
    let vertices = get_vertices(&motions, orientation);
    let area = get_area(&vertices);
    Ok(area)
}

fn main() -> Result<()> {
    println!("Part1: {}", run(Part::Part1)?);
    println!("Part2: {}", run(Part::Part2)?);
    Ok(())
}
