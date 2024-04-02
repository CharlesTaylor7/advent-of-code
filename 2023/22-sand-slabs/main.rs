#!/usr/bin/env cargo +nightly -Zscript
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
use std::{
    any,
    borrow::{Borrow, BorrowMut},
    cmp,
    collections::{HashMap, HashSet},
    rc::Rc,
};

#[derive(Debug, Clone)]
pub enum Axis {
    X,
    Y,
    Z,
}

#[derive(Debug, Hash, Eq, PartialEq, Clone)]
pub struct Point {
    pub x: usize,
    pub y: usize,
    pub z: usize,
}
impl Point {
    pub fn parse(input: &str) -> Result<Self> {
        let (x, rest) = input.split_once(',').ok_or(anyhow!(""))?;
        let (y, z) = rest.split_once(',').ok_or(anyhow!(""))?;

        Ok(Self {
            x: x.parse()?,
            y: y.parse()?,
            z: z.parse()?,
        })
    }
}

#[derive(Debug, Clone)]
pub struct Brick {
    pub id: BrickId,
    pub start: Point,
    pub len: usize,
    pub axis: Axis,
}
impl Brick {
    pub fn parse(id: usize, input: &str) -> Result<Self> {
        let (a, b) = input.split_once('~').ok_or(anyhow!("missing ~"))?;
        let a = Point::parse(a)?;
        let b = Point::parse(b)?;

        let (axis, len) = match (b.x - a.x, b.y - a.y, b.z - a.z) {
            (x, 0, 0) => (Axis::X, x + 1),
            (0, y, 0) => (Axis::Y, y + 1),
            (0, 0, z) => (Axis::Z, z + 1),
            _ => bail!("not an axis"),
        };
        Ok(Self {
            id: BrickId(char::from_u32((id + 65) as u32).ok_or(anyhow!("not a valid ascii char"))?),
            axis,
            start: a,
            len,
        })
    }

    pub fn points(&self) -> impl Iterator<Item = Point> + '_ {
        BrickPoints {
            brick: self,
            index: 0,
        }
    }
}

struct BrickPoints<'a> {
    brick: &'a Brick,
    index: usize,
}

impl<'a> Iterator for BrickPoints<'a> {
    type Item = Point;
    fn next(&mut self) -> Option<Point> {
        if self.index < self.brick.len {
            let mut point = self.brick.start.clone();

            match self.brick.axis {
                Axis::X => point.x += self.index,
                Axis::Y => point.y += self.index,
                Axis::Z => point.z += self.index,
            }
            self.index += 1;
            Some(point)
        } else {
            None
        }
    }
}

#[derive(Debug, Clone, Copy, Hash, PartialEq, Eq)]
pub struct BrickId(pub char);

#[derive(Debug, Clone)]
pub struct Arena {
    pub bricks: Vec<Brick>,
    pub grid: HashMap<Point, BrickId>,
    pub max: Point,
}

impl Arena {
    pub fn parse(input: &str) -> Result<Self> {
        let bricks: Vec<Brick> = input
            .lines()
            .enumerate()
            .map(|(i, line)| Brick::parse(i, line))
            .collect::<Result<Vec<_>>>()?;

        let mut grid: HashMap<Point, BrickId> = HashMap::new();

        let mut max = Point { x: 0, y: 0, z: 0 };
        for brick in bricks.iter() {
            for point in brick.points() {
                max.x = cmp::max(max.x, point.x);
                max.y = cmp::max(max.y, point.y);
                max.z = cmp::max(max.z, point.z);
                grid.insert(point, brick.id);
            }
        }

        Ok(Self { bricks, grid, max })
    }

    pub fn print_projection_xy(&self) {
        print!("\nxy projection\n");
        for y in 0..(self.max.y + 1) {
            for x in 0..(self.max.x + 1) {
                let brick = (0..(self.max.z + 1))
                    .rev()
                    .find_map(|z| self.grid.get(&Point { x, y, z }));

                print!("{}", brick.map_or('.', |id| id.0));
            }
            print!("\n")
        }
        print!("\n")
    }

    pub fn print_projection_xz(&self) {
        print!("\nxz projection\n");
        for z in 1..(self.max.z + 1) {
            for x in 0..(self.max.x + 1) {
                let brick = (0..(self.max.y + 1)).find_map(|y| self.grid.get(&Point { x, y, z }));

                print!("{}", brick.map_or('.', |id| id.0));
            }
            print!("\n")
        }
    }

    pub fn print_projection_yz(&self) {
        print!("\nyz projection\n");
        for z in 1..(self.max.z + 1) {
            for y in 0..(self.max.y + 1) {
                let brick = (0..(self.max.x + 1)).find_map(|x| self.grid.get(&Point { x, y, z }));

                print!("{}", brick.map_or('.', |id| id.0));
            }
            print!("\n")
        }
    }

    pub fn settle(&mut self) -> bool {
        let mut moved = false;
        let mut settled: HashSet<BrickId> = HashSet::new();

        while settled.len() < self.bricks.len() {
            for brick in self.bricks.iter_mut() {
                if settled.contains(&brick.id) {
                    continue;
                }

                println!("{:?}", brick);
                let is_grounded = brick.start.z == 1;

                let supported_by = match brick.axis {
                    Axis::Z => {
                        let mut start = brick.start.clone();
                        start.z -= 1;

                        self.grid.get(&start)
                    }
                    Axis::X | Axis::Y => brick
                        .points()
                        .map(|mut p| {
                            p.z -= 1;
                            p
                        })
                        .find_map(|p| self.grid.get(&p)),
                };
                if is_grounded {
                    println!("grounded");
                } else {
                    println!("supported by: {:?}", supported_by);
                }
                if is_grounded || supported_by.is_some() {
                    settled.insert(brick.id);
                    continue;
                }

                println!("move: {:?}", brick.id);
                moved = true;
                for p in brick.points() {
                    self.grid.remove(&p);
                }
                brick.start.z -= 1;

                for p in brick.points() {
                    self.grid.insert(p, brick.id);
                }
            }
        }
        moved
    }

    pub fn part1(mut self) -> usize {
        let mut total = 0;
        let mut arena = self;
        let backup = arena.clone();
        for i in 0..arena.bricks.len() {
            arena.bricks.swap_remove(i);

            println!("remove: {}", i);
            if !arena.settle() {
                //println!("brick id: {}", i);
                total += 1;
            }
            arena = backup.clone();
        }
        total
    }
}

fn main() -> Result<()> {
    let input = include_str!("example.txt");
    let mut arena = Arena::parse(input)?;

    println!("Input:\n{input}");
    println!("initial");
    arena.settle();
    arena.print_projection_xy();
    arena.print_projection_yz();
    arena.print_projection_xz();
    //println!("Part 1: {}", arena.part1());
    Ok(())
}
