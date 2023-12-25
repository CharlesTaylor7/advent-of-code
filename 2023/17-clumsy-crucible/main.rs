#!/usr/bin/env cargo +nightly -Zscript

use std::collections::hash_map::Entry;
use std::collections::HashMap;
use std::fmt::Debug;

// todo:
// re encode neighbors as a leap of 1 to 3 elments
// encode directions as vertical vs horizontal in the p queue

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

            start = end;
            end = (end * 2) + 1;
        }
    }
}

impl<T: Debug> PriorityQueue<T> {
    pub fn with_capacity(capacity: usize) -> Self {
        Self {
            data: Vec::with_capacity(capacity),
        }
    }

    fn check_invariants(&self) {
        for (index, (priority, _)) in self.data.iter().enumerate() {
            if index > 0 {
                let parent = self.data[(index - 1) / 2].0;
                if parent > *priority {
                    println!("{:#?}", self.data);
                    panic!("heap property broken: {}", index);
                }
            }
        }
    }

    pub fn insert(&mut self, key: usize, value: T) {
        println!("insert: {key}, {value:#?}");
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

        println!("pop: {min:#?}");
        self.check_invariants();
        Some(min)
    }
}

struct Node {
    pub p: Point2d,
    pub a: Axis,
}

impl std::fmt::Debug for Node {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "({},{},{:#?})", self.p.x, self.p.y, self.a)
    }
}

#[derive(Clone)]
struct Point2d {
    pub x: usize,
    pub y: usize,
}

impl Point2d {
    pub fn new(x: usize, y: usize) -> Self {
        Self { x, y }
    }
}

#[repr(u8)]
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Direction {
    #[allow(dead_code)]
    North = 0,
    East = 1,
    South = 2,
    #[allow(dead_code)]
    West = 3,
}
impl Direction {
    pub fn axis(&self) -> Axis {
        let n = (*self) as u8;
        unsafe { std::mem::transmute(n % 2) }
    }
}

#[repr(u8)]
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Axis {
    Vertical = 0,
    Horizontal = 1,
}
impl Axis {
    const DIRS_HORIZONTAL: [Direction; 2] = [Direction::East, Direction::West];
    const DIRS_VERTICAL: [Direction; 2] = [Direction::North, Direction::South];

    pub fn dirs(&self) -> &[Direction] {
        match self {
            Axis::Vertical => &Axis::DIRS_VERTICAL,
            Axis::Horizontal => &Axis::DIRS_HORIZONTAL,
        }
    }

    pub fn opposite(&self) -> Axis {
        match self {
            Axis::Vertical => Axis::Horizontal,
            Axis::Horizontal => Axis::Vertical,
        }
    }
}

struct Map {
    pub width: usize,
    pub height: usize,
    pub data: Vec<u8>,
}

impl Map {
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

    fn key_2d(&self, point: &Point2d) -> usize {
        point.x + point.y * self.width
    }

    fn node_key(&self, node: &Node) -> usize {
        self.key_2d(&node.p) + node.a as usize * self.width * self.height
    }

    pub fn dijkstra(&self, max_leap: usize) -> usize {
        let capacity = self.width * self.height * 2;
        let mut queue = PriorityQueue::with_capacity(capacity);

        let mut distances = HashMap::<usize, usize>::with_capacity(capacity);

        let initial = Point2d::new(0, 0);
        let dirs = [Direction::South, Direction::East];
        for dir in dirs {
            let mut distance = 0;
            let mut p = initial.clone();
            for _ in 1..=max_leap {
                if let Some(point) = self.advance(&p, dir) {
                    distance += self.data[self.key_2d(&point)] as usize;
                    let node = Node {
                        p: point.clone(),
                        a: dir.axis(),
                    };
                    p = point;
                    distances.insert(self.node_key(&node), distance);
                    queue.insert(distance, node);
                } else {
                    break;
                }
            }
        }

        while let Some((dist, node)) = queue.pop() {
            if node.p.x == self.width - 1 && node.p.y == self.height - 1 {
                return dist;
            }

            // skip past remnants in the queue
            if distances
                .get(&self.node_key(&node))
                .is_some_and(|d| *d < dist)
            {
                println!("skipping already processed point");
                continue;
            }

            for dir in node.a.opposite().dirs() {
                let mut point = node.p.clone();
                let mut distance = dist;
                for leap in 1..=max_leap {
                    if let Some(next) = self.advance(&point, *dir) {
                        let node = Node {
                            p: next.clone(),
                            a: dir.axis(),
                        };
                        distance += self.data[self.key_2d(&node.p)] as usize;
                        point = next;

                        println!("{dir:#?} leap {leap} to neighbor: {node:#?} cost: {distance}",);
                        match distances.entry(self.node_key(&node)) {
                            Entry::Occupied(mut entry) => {
                                println!(
                                    "node exists already with a travel cost of {}",
                                    *entry.get()
                                );
                                if distance < *entry.get() {
                                    entry.insert(distance);
                                    queue.insert(distance, node)
                                }
                            }

                            Entry::Vacant(entry) => {
                                entry.insert(distance);
                                queue.insert(distance, node);
                            }
                        }
                    } else {
                        break;
                    }
                }
            }
        }
        panic!("No path to the end");
    }
}

fn main() {
    let input = include_str!("input.txt");

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

    println!("Part 1: {}", map.dijkstra(3));
}
