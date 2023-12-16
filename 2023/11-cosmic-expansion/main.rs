#!/usr/bin/env cargo +nightly -Zscript

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
    let text = include_str!("input.txt");

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

    let expanded_rows: Vec<usize> = (0..height)
        .filter(|j| (0..width).all(|i| data[j * width + i] == Tile::Empty))
        .collect();

    let expanded_cols: Vec<usize> = (0..width)
        .filter(|i| (0..width).all(|j| data[j * width + i] == Tile::Empty))
        .collect();

    let mut distance = 0;
    let mut lines_crossed = 0;
    for i in 0..galaxies.len() {
        for j in (i + 1)..galaxies.len() {
            let a = &galaxies[i];
            let b = &galaxies[j];
            let dx = (b.x as isize) - (a.x as isize);
            let dy = (b.y as isize) - (a.y as isize);
            let manhattan = dx.abs() + dy.abs();
            let (start_x, end_x) = if a.x < b.x { (a.x, b.x) } else { (b.x, a.x) };
            let (start_y, end_y) = if a.y < b.y { (a.y, b.y) } else { (b.y, a.y) };

            let rows_crossed = expanded_rows
                .iter()
                .cloned()
                .filter(|j| *j > start_y && *j < end_y)
                .count() as isize;
            let cols_crossed = expanded_cols
                .iter()
                .cloned()
                .filter(|i| *i > start_x && *i < end_x)
                .count() as isize;

            distance += manhattan;
            lines_crossed += rows_crossed + cols_crossed;
        }
    }

    println!("Part 1: {}", distance + lines_crossed);
    println!("Part 2: {}", distance + 999_999 * lines_crossed);

    Ok(())
}
