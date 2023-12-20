#!/usr/bin/env cargo +nightly -Zscript


use std::collections::hash_map::Entry;
use std::collections::HashMap;

// heap
struct PriorityQueue<T> {
    data: Vec<(usize, T)>,
}
impl<T> std::fmt::Debug for PriorityQueue<T> {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        let mut start = 0;
        let mut end = 1;
        println!("heap:");
        loop {
            for i in start..end {
                if let Some((p, _)) = self.data.get(i) {
                    write!(f, " {}", p)?;
                } else {
                    return Ok(());
                }
            }
            write!(f, "\n")?;

            start = end + 1;
            end = (end + 1) * 2;
        }
    }
}

impl<T> PriorityQueue<T> {
    pub fn with_capacity(capacity: usize) -> Self {
        Self {
            data: Vec::with_capacity(capacity),
        }
    }

    fn check_invariants(&self) {
        println!("{:#?}", self);
        for (index, (priority, _)) in self.data.iter().enumerate() {
            if index > 0 {
                let parent = self.data[(index - 1) / 2].0;
                if parent > *priority {
                    panic!("heap property broken: {}", index);
                }
            }
        }
    }

    pub fn insert(&mut self, key: usize, value: T) {
        self.data.push((key, value));
        let mut i = self.data.len() - 1;
        while i > 0 {
            let parent = (i - 1) / 2;
            if self.data[parent].0 > self.data[i].0 {
                self.data.swap(parent, i);
                i = parent;
            } else {
                break;
            }
        }

        self.check_invariants();
    }

    pub fn pop(&mut self) -> Option<(usize, T)> {
        if self.data.len() == 0 {
            return None;
        }

        let min = self.data.swap_remove(0);
        let mut i = 0;

        loop {
            let left_child = 2 * i + 1;
            let right_child = 2 * i + 2;

            if left_child >= self.data.len() {
                break;
            }
            let child = if right_child >= self.data.len()
                || self.data[left_child].0 < self.data[right_child].0
            {
                left_child
            } else {
                right_child
            };
            if self.data[child].0 < self.data[i].0 {
                self.data.swap(child, i);
                i = child;
            } else {
                break;
            }
        }

        self.check_invariants();

        Some(min)
    }
}

struct Point4d {
    pub p: Point2d,
    pub z: u8,
    pub d: Direction,
}

impl Point4d {
    pub fn new(x: usize, y: usize, z: u8, d: Direction) -> Self {
        Self {
            p: Point2d::new(x, y),
            z,
            d,
        }
    }
}

struct Point2d {
    pub x: usize,
    pub y: usize,
}

impl Point2d {
    pub fn new(x: usize, y: usize) -> Self {
        Self { x, y }
    }
}

struct Map {
    pub width: usize,
    pub height: usize,
    pub data: Vec<u8>,
}

#[repr(u8)]
#[derive(Clone, Copy, Debug)]
enum Direction {
    #[allow(dead_code)]
    North = 0,
    East = 1,
    South = 2,
    #[allow(dead_code)]
    West = 3,
}
impl Direction {
    pub fn right(&self) -> Direction {
        let n = *self as u8;
        unsafe { std::mem::transmute(n + 1 % 4) }
    }

    pub fn left(&self) -> Direction {
        let n = *self as u8;
        unsafe { std::mem::transmute(n + 5 % 4) }
    }
}

impl Map {
    // every step forward increases depth up to this cap
    // every step left or right resets depth
    const DEPTH: u8 = 3;

    fn advance(&self, point: &Point2d, d: Direction) -> Option<Point2d> {
        match d {
            Direction::North => {
                if point.y == 0 {
                    None
                } else {
                    Some(Point2d {
                        y: point.y - 1,
                        ..*point
                    })
                }
            }

            Direction::East => {
                if point.x + 1 == self.width {
                    None
                } else {
                    Some(Point2d {
                        x: point.x + 1,
                        ..*point
                    })
                }
            }

            Direction::West => {
                if point.x == 0 {
                    None
                } else {
                    Some(Point2d {
                        x: point.x - 1,
                        ..*point
                    })
                }
            }

            Direction::South => {
                if point.y + 1 == self.height {
                    None
                } else {
                    Some(Point2d {
                        y: point.y + 1,
                        ..*point
                    })
                }
            }
        }
    }

    fn forward(&self, point: &Point4d) -> Option<Point4d> {
        if point.z + 1 == Self::DEPTH {
            return None;
        }

        let p = self.advance(&point.p, point.d)?;

        Some(Point4d {
            p,
            z: point.z + 1,
            d: point.d,
        })
    }

    fn right(&self, point: &Point4d) -> Option<Point4d> {
        let d = point.d.right();
        let p = self.advance(&point.p, point.d)?;

        Some(Point4d { p, z: 0, d })
    }

    fn left(&self, point: &Point4d) -> Option<Point4d> {
        let d = point.d.left();
        let p = self.advance(&point.p, point.d)?;

        Some(Point4d { p, z: 0, d })
    }

    fn key_2d(&self, point: &Point2d) -> usize {
        point.x + point.y * self.width
    }

    fn key_4d(&self, point: &Point4d) -> usize {
        self.key_2d(&point.p)
            + point.z as usize * self.width * self.height
            + point.d as usize * self.width * self.height * Self::DEPTH as usize
    }

    pub fn dijkstra(&self) -> usize {
        let capacity = self.width * self.height * 3 * 4;
        let mut queue = PriorityQueue::with_capacity(capacity);

        let mut distances = HashMap::<usize, usize>::with_capacity(capacity);

        let initial = [
            Point4d::new(0, 1, 0, Direction::South),
            Point4d::new(1, 0, 0, Direction::East),
        ];
        for point in initial {
            let distance = self.data[self.key_2d(&point.p)] as usize;
            distances.insert(self.key_4d(&point), distance);
            queue.insert(distance, point);
        }

        while let Some((distance, point)) = queue.pop() {
            println!(
                "({},{},{},{:#?}): {}",
                point.p.x, point.p.y, point.z, point.d, distance
            );
            if point.p.x == self.width - 1 && point.p.y == self.height - 1 {
                return distance;
            }

            // skip past remnants in the queue
            if distances
                .get(&self.key_4d(&point))
                .is_some_and(|d| *d < distance)
            {
                continue;
            }
            let neighbors = [self.forward(&point), self.right(&point), self.left(&point)];

            for n in neighbors.into_iter().flatten() {
                let d = distance + self.data[self.key_2d(&point.p)] as usize;
                match distances.entry(self.key_4d(&n)) {
                    Entry::Occupied(mut entry) => {
                        if d < *entry.get() {
                            entry.insert(d);
                            queue.insert(d, n)
                        }
                    }

                    Entry::Vacant(entry) => {
                        entry.insert(d);
                        queue.insert(d, n);
                    }
                }
            }
        }
        panic!();
    }
}

fn main() {
    let input = include_str!("example.txt");

    println!("{}", input);
    let mut map = Map {
        width: 0,
        height: 0,
        data: Vec::with_capacity(input.len()),
    };
    for line in input.lines() {
        map.width = line.len();
        map.height += 1;
        for c in line.chars() {
            map.data.push(c.to_string().parse().unwrap());
        }
    }
    println!("h: {}, w: {}", map.height, map.width);

    println!("Part 1: {}", map.dijkstra());
}
