#!/usr/bin/env cargo +nightly -Zscript

use std::collections::HashSet;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
enum Direction {
    North = 1,
    East = 2,
    West = 4,
    South = 8,
}

impl Direction {
    const ALL: [Self; 4] = [
        Direction::North,
        Direction::East,
        Direction::West,
        Direction::South,
    ];

    pub const fn bit_value(&self) -> u8 {
        unsafe { std::mem::transmute(*self) }
    }
    pub unsafe fn from_bit(val: u8) -> Self {
        unsafe { std::mem::transmute(val) }
    }

    pub fn opposite(&self) -> Self {
        match self {
            Direction::North => Direction::South,
            Direction::East => Direction::West,
            Direction::West => Direction::East,
            Direction::South => Direction::North,
        }
    }
}

#[derive(Clone, PartialEq, Eq, Hash)]
struct Location {
    pub row: usize,
    pub col: usize,
}

impl std::fmt::Debug for Location {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "({}, {})", self.col, self.row)
    }
}

impl Location {
    // get the directional difference if the locations are adjacent
    pub fn diff_adjacent(&self, loc: &Location) -> Option<Direction> {
        let dx = (self.col as i64) - (loc.col as i64);
        let dy = (self.row as i64) - (loc.row as i64);
        //let dy= self.row.into() - loc.row.into();
        if dx != 0 && dy == 0 {
            return match dx {
                1 => Some(Direction::East),
                -1 => Some(Direction::West),
                _ => None,
            };
        }

        if dx == 0 && dy != 0 {
            return match dy {
                1 => Some(Direction::South),
                -1 => Some(Direction::North),
                _ => None,
            };
        }
        None
    }
    pub fn advance(&self, dir: Direction) -> Self {
        match dir {
            Direction::North => Self {
                row: self.row - 1,
                col: self.col,
            },

            Direction::East => Self {
                row: self.row,
                col: self.col + 1,
            },

            Direction::West => Self {
                row: self.row,
                col: self.col - 1,
            },

            Direction::South => Self {
                row: self.row + 1,
                col: self.col,
            },
        }
    }
}

#[derive(PartialEq, Eq)]
enum PathStep {
    Next(Location, Direction),
    Done,
    Failure,
}

struct PathState {
    locations: Vec<Location>,
    step: PathStep,
}

// Row major order matrix of map
struct Map {
    pub height: usize,
    pub width: usize,
    pub start: Location,
    data: Vec<Tile>,
}

impl std::fmt::Debug for Map {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        let mut data = String::with_capacity((self.width + 1) * self.height);
        for row in 0..self.height {
            for col in 0..self.width {
                data.push_str(
                    &self
                        .lookup(&Location { row, col })
                        .map_or("?".to_owned(), |s| format!("{:#?}", s)),
                );
            }
            data.push('\n')
        }
        write!(f, "{}", data)
    }
}

impl Map {
    pub fn parse(text: &str) -> Map {
        let mut data = Vec::with_capacity(text.len());
        let mut width = 0;
        let mut row = 0;
        let mut start = None;
        for l in text.lines() {
            width = l.len();
            for (col, c) in l.chars().enumerate() {
                let cell = Tile::parse(c);
                data.push(cell);
                if cell == Tile::Start {
                    start = Some(Location { row, col })
                }
            }
            row += 1;
        }
        Map {
            height: row,
            //+ 1,
            width,
            data,
            start: start.unwrap(),
        }
    }

    fn to_index(&self, location: &Location) -> usize {
        location.row * self.width + location.col
    }

    pub fn lookup(&self, location: &Location) -> Option<Tile> {
        self.data.get(self.to_index(location)).cloned()
    }

    pub fn update(&mut self, location: &Location, tile: Tile) {
        let index = self.to_index(location);
        self.data.get_mut(index).map(|v| {
            *v = tile;
        });
    }

    pub fn step(&self, loc: &Location, from: Direction) -> PathStep {
        let cell = self.lookup(loc);
        match cell {
            None => PathStep::Failure,
            Some(Tile::Empty(_)) => PathStep::Failure,
            Some(Tile::Start) => PathStep::Done,
            Some(Tile::Pipe(pipe)) => match pipe.follow(from) {
                None => PathStep::Failure,
                Some(next) => PathStep::Next(loc.advance(next), next.opposite()),
            },
        }
    }

    pub fn find_path(&self) -> Vec<Location> {
        let mut paths = Vec::with_capacity(4);
        for d in Direction::ALL {
            paths.push(PathState {
                locations: Vec::with_capacity(self.width * self.height),
                step: PathStep::Next(self.start.advance(d), d.opposite()),
            });
        }
        loop {
            for i in 0..4 {
                let state = &mut paths[i];
                match std::mem::replace(&mut state.step, PathStep::Failure) {
                    PathStep::Failure => continue,
                    PathStep::Done => {
                        return std::mem::replace(&mut state.locations, Vec::with_capacity(0));
                    }
                    PathStep::Next(loc, dir) => {
                        state.step = self.step(&loc, dir);
                        state.locations.push(loc);
                    }
                }
            }
        }
    }
    pub fn fill_in_start(&mut self, first: &Location, last: &Location) {
        let start_pipe = Pipe::create(
            first.diff_adjacent(&self.start).unwrap(),
            last.diff_adjacent(&self.start).unwrap(),
        );

        self.update(&self.start.clone(), Tile::Pipe(start_pipe));
    }

    pub fn clear_debris(&mut self, pipes: HashSet<Location>) {
        for row in 0..self.height {
            for col in 0..self.width {
                let loc = Location { row, col };
                if !pipes.contains(&loc) {
                    self.update(&loc, Tile::Empty(None))
                }
            }
        }
    }

    pub fn winding_number(&mut self, loc: &Location, path: &[Location]) -> i32 {
        let mut winding = 0;

        let mut dy: isize = (self.start.row as isize) - (loc.row as isize);
        for i in 0..path.len() {
            let current = &path[i];
            if current.row == loc.row && current.col > loc.col {
                if let Some(Tile::Pipe(pipe)) = self.lookup(current) {
                    if pipe.has(Direction::North) && dy == 1 {
                        winding += 1;
                    }
                    if pipe.has(Direction::South) && dy == -1 {
                        winding -= 1;
                    }
                }
            }
            let delta = (current.row as isize) - (loc.row as isize);
            if delta != 0 {
                dy = delta;
            }
        }

        return winding;
    }

    pub fn winding_test(&mut self, path: Vec<Location>) -> usize {
        let mut tally = 0;
        for row in 0..self.height {
            for col in 0..self.width {
                let current = Location { row, col };
                if self.lookup(&current) != Some(Tile::Empty(None)) {
                    continue;
                }
                let tag = if self.winding_number(&current, &path) % 2 == 0 {
                    Tag::Exterior
                } else {
                    Tag::Interior
                };
                if tag == Tag::Interior {
                    tally += 1;
                }
                self.update(&current, Tile::Empty(Some(tag)));
            }
        }
        tally
    }
}

#[derive(PartialEq, Eq, Copy, Clone)]
enum Tile {
    Pipe(Pipe),
    Empty(Option<Tag>),
    Start,
}

impl std::fmt::Debug for Tile {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(
            f,
            "{}",
            match self {
                Tile::Pipe(pipe) => format!("{:#?}", pipe),
                Tile::Empty(None) => ".".to_owned(),
                Tile::Empty(Some(Tag::Exterior)) => ".".to_owned(),
                Tile::Empty(Some(Tag::Interior)) => "*".to_owned(),
                Tile::Start => "S".to_owned(),
            }
        )
    }
}

#[derive(PartialEq, Eq, Copy, Clone, Debug)]
enum Tag {
    Interior,
    Exterior,
}

impl Tile {
    pub fn parse(text: char) -> Self {
        match text {
            '.' => Tile::Empty(None),
            'S' => Tile::Start,
            _ => Pipe::parse(text).map_or(Tile::Empty(None), Tile::Pipe),
        }
    }
}

#[derive(PartialEq, Eq, Copy, Clone)]
struct Pipe(u8);

impl std::fmt::Debug for Pipe {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "{}", {
            if *self == Pipe::N_S {
                '|'
            } else if *self == Pipe::E_W {
                '-'
            } else if *self == Pipe::N_W {
                'J'
            } else if *self == Pipe::N_E {
                'L'
            } else if *self == Pipe::S_E {
                'F'
            } else if *self == Pipe::S_W {
                '7'
            } else {
                '?'
            }
        })
    }
}

impl Pipe {
    const N_S: Self = Self::create(Direction::North, Direction::South);
    const E_W: Self = Self::create(Direction::East, Direction::West);

    const S_E: Self = Self::create(Direction::South, Direction::East);
    const S_W: Self = Self::create(Direction::South, Direction::West);
    const N_E: Self = Self::create(Direction::North, Direction::East);
    const N_W: Self = Self::create(Direction::North, Direction::West);

    pub const fn create(a: Direction, b: Direction) -> Self {
        Self(a.bit_value() + b.bit_value())
    }

    pub fn parse(text: char) -> Option<Self> {
        match text {
            '|' => Some(Self::N_S),
            '-' => Some(Self::E_W),
            'F' => Some(Self::S_E),
            'J' => Some(Self::N_W),
            '7' => Some(Self::S_W),
            'L' => Some(Self::N_E),
            _ => None,
        }
    }

    pub fn has(&self, dir: Direction) -> bool {
        self.0 & dir.bit_value() > 0
    }

    pub fn follow(&self, from: Direction) -> Option<Direction> {
        let test = self.0 & from.bit_value();
        if test > 0 {
            unsafe { Some(Direction::from_bit(self.0 - from.bit_value())) }
        } else {
            None
        }
    }
}

fn main() -> std::io::Result<()> {
    let text = include_str!("input.txt");

    let mut map = Map::parse(text);

    let path = map.find_path();
    println!("Part 1: {}", path.len() / 2);

    map.fill_in_start(&path[0], &path[path.len() - 2]);

    let pipes = path.iter().cloned().collect::<HashSet<Location>>();
    map.clear_debris(pipes);

    let tally = map.winding_test(path);
    println!("Part 2: {}", tally);

    Ok(())
}

#[cfg(test)]
mod tests {
    use crate::*;

    #[test]
    pub fn pipe_follow() {
        assert_eq!(Pipe::N_E.follow(Direction::North), Some(Direction::East));
        assert_eq!(Pipe::N_E.follow(Direction::East), Some(Direction::North));
        assert_eq!(Pipe::N_E.follow(Direction::South), None);
        assert_eq!(Pipe::N_E.follow(Direction::West), None);
    }

    #[test]
    pub fn pipe_parse_debug_roundtrip() {
        const PIPE_CHARS: &str = "-|F7JL";
        for c in PIPE_CHARS.chars() {
            assert_eq!(format!("{:#?}", Pipe::parse(c).unwrap()), format!("{}", c));
        }
    }
}
