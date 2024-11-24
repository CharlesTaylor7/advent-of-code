#![allow(unused_imports)]
#![allow(unused_mut)]
#![allow(unused_variables)]
#![allow(dead_code)]
#![allow(unreachable_code)]
use anyhow::{anyhow, bail, Result};
use std::{collections::HashMap, rc::Rc};

struct ReindeerStats {
    name: String,
    speed: u16,
    sprint: u16,
    rest: u16,
}

#[derive(Debug)]
struct ReindeerState {
    name: String,
    fly: bool,
    countdown: u16,
    score: u16,
    traveled: u16,
}

fn main() -> Result<()> {
    let input = include_str!("input.txt");
    // let input = r"Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.
    // Dancer can fly 16 km/s for 11 seconds, but then must rest for 162 seconds.";
    println!("{input}");

    let reindeer = input
        .lines()
        .map(|line| {
            let (name, _) = line.split_once(' ').unwrap();
            let vec = line
                .split_whitespace()
                .filter_map(|s| s.parse::<u16>().ok())
                .collect::<Vec<_>>();
            ReindeerStats {
                name: name.to_string(),
                speed: vec[0],
                sprint: vec[1],
                rest: vec[2],
            }
        })
        .collect::<Vec<_>>();

    let mut race: Vec<ReindeerState> = reindeer
        .iter()
        .map(|r| ReindeerState {
            name: r.name.clone(),
            fly: true,
            countdown: r.sprint,
            score: 0,
            traveled: 0,
        })
        .collect();

    for round in 1..=2053 {
        for (i, stats) in reindeer.iter().enumerate() {
            let r = &mut race[i];
            if r.fly {
                r.traveled += stats.speed;
                r.countdown -= 1;
                if r.countdown == 0 {
                    r.countdown = stats.rest;
                    r.fly = false;
                }
            } else {
                r.countdown -= 1;
                if r.countdown == 0 {
                    r.countdown = stats.sprint;
                    r.fly = true;
                }
            }
        }
        let max = race.iter().map(|r| r.traveled).max().unwrap();
        race.iter_mut().filter(|r| r.traveled == max).for_each(|r| {
            r.score += 1;
        });
    }

    print!("answer: {:#?}", race.iter().map(|r| r.score).max());
    Ok(())
}
