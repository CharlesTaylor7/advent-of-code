#!/usr/bin/env cargo +nightly -Zscript

#![allow(unused_imports)]
#![allow(unused_mut)]
#![allow(unused_variables)]
#![allow(dead_code)]
#![allow(unreachable_code)]

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Direction {
    Up,
    Right,
    Down,
    Left,
}

#[derive(Clone, Debug, PartialEq, Eq)]
struct Point {
    pub x: isize,
    pub y: isize,
}

impl Point {
    pub fn cross_product(&self, other: &Point) -> isize {
        self.x * self.y - other.x * self.y
    }
    pub fn advance(&mut self, dir: Direction, amount: isize) {
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

fn main() {
    let input = include_str!("custom.txt");

    let mut perimeter = 0;
    let mut area = 0;
    let mut vertices = Vec::new();
    let mut current = Point { x: 0, y: 0 };
    let mut prev;
    let mut bounds = Bounds {
        min: current.clone(),
        max: current.clone(),
    };
    vertices.push(current.clone());
    for line in input.lines() {
        let parts: Vec<_> = line.split(" ").collect();
        let dir = match parts[0] {
            "R" => Direction::Right,
            "L" => Direction::Left,
            "U" => Direction::Up,
            "D" => Direction::Down,
            _ => panic!(),
        };
        let amount: isize = parts[1].parse().unwrap();

        perimeter += amount;
        prev = current.clone();
        current.advance(dir, amount + 1);
        area += prev.cross_product(&current);
        match dir {
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
        vertices.push(current.clone());
    }
    println!("Perimeter: {}", perimeter);
    println!("Bounds: {:#?}", bounds);
    println!("Part 1: {}", area);
}
