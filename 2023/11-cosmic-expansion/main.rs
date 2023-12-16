#!/usr/bin/env cargo +nightly -Zscript

#![allow(unused_imports)]
#![allow(unused_mut)]
#![allow(unused_variables)]
#![allow(dead_code)]
use std::fmt::{Debug, Formatter};
///
/// struct Map {
///     pub width: usize,
///     pub height: usize,
///     data: Vec<Tile>,
/// }
///
/// impl Map {
///     pub fn lookup(&self, x: usize, y: usize) -> Tile {
///
///     }
///     pub fn from_str(text:
/// }
///
///
#[derive(PartialEq)]
enum Tile {
    Empty,
    Galaxy,
}

struct Point {
    pub x: usize,
    pub y: usize,
}
fn main() -> std::io::Result<()> {
    let text = include_str!("example.txt");

    let mut data: Vec<Tile> = Vec::with_capacity(text.len());
    let mut galaxies: Vec<Point> = Vec::new();
    let mut height = 0;
    let mut width = 0;
    for (row, line) in text.lines().enumerate() {
        width = line.len();
        for (col, c) in line.chars().enumerate() {
            let tile = match c {
                '.' => Tile::Empty,
                '#' => Tile::Galaxy,
                _ => panic!(),
            };
            data.push(tile);
            if c == '#' {
                galaxies.push(Point { x: col, y: row })
            }
        }
        height += 1;
    }

    let mut expanded_rows: Vec<usize> = Vec::with_capacity(height);
    for j in 0..height {
        if (0..width).all(|i| data[j * width + i] == Tile::Empty) {
            expanded_rows.push(j)
        }
    }

    let mut expanded_cols: Vec<usize> = Vec::with_capacity(width);
    for i in 0..width {
        if (0..height).all(|j| data[j * width + i] == Tile::Empty) {
            expanded_cols.push(i)
        }
    }

    let mut tally = 0;
    for i in 0..galaxies.len() {
        for j in (i + 1)..galaxies.len() {
            let a = &galaxies[i];
            let b = &galaxies[j];
            let dx = (b.x as isize) - (a.x as isize);
            let dy = (b.y as isize) - (a.y as isize);
            // manhattan distance
            let mut distance = dx.abs() + dy.abs();
            // count the number of expanded rows and columns crossed
            distance += expanded_rows
                .iter()
                .cloned()
                .filter(|j| *j > a.y && *j < b.y)
                .count() as isize;
            distance += expanded_cols
                .iter()
                .cloned()
                .filter(|i| *i > a.x && *i < b.x)
                .count() as isize;
            println!("{} to {}: {}", i + 1, j + 1, distance);
            tally += distance;
        }
    }

    println!("Part 1: {}", tally);

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
