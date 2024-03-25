#!/usr/bin/env cargo +nightly -Zscript
//! ```cargo
//! [dependencies]
//! anyhow = "*"
//! ```
#![feature(iter_collect_into, ascii_char, ascii_char_variants, iter_array_chunks)]
#![allow(unused_imports)]
#![allow(unused_mut)]
#![allow(unused_variables)]
#![allow(dead_code)]
#![allow(unreachable_code)]
use anyhow::{anyhow, bail, Result};
use std::ascii;
use std::collections::HashSet;
use std::{collections::HashMap, rc::Rc};

// For part 2, the idea is to trace all paths.
// we send an idealized part throught the machine.
// its just a list of constraints. 
// for each constraint encountered, we split the part in two, and trace both those paths.
// then we tally up the idealized parts at the end.
pub struct Input {
    pub pipeline: Pipeline,
    pub parts: Vec<Part>,
}
impl Input {
    pub fn parse(text: &str) -> Result<Self> {
        let mut iterator = text.lines();

        let initial = WorkflowId(Rc::from("in"));
        let workflows = iterator
            .by_ref()
            .take_while(|line| line.len() > 0)
            .map(Workflow::parse)
            .collect::<Result<HashMap<_, _>>>()?;

        let parts = iterator.map(Part::parse).collect::<Result<Vec<_>>>()?;
        Ok(Self {
            pipeline: Pipeline { initial, workflows },
            parts,
        })
    }

    pub fn accepted_total_rating(&self) -> usize {
        let mut result = 0;
        for part in self.parts.iter() {
            if self.pipeline.accepts(part) {
                result += part.x + part.m + part.a + part.s;
            }
        }
        result
    }
}


// The platonic ideal of a part. It doesn't have any concrete values, just a list of constraints it
// must satisfy
#[derive(Clone)]
pub struct PlatonicPart {
    pub constraints: Vec<Constraint>,
}

#[derive(Clone)]
pub enum Prop {
    X,
    M,
    A,
    S,
}

pub struct Part {
    pub x: usize,
    pub m: usize,
    pub a: usize,
    pub s: usize,
}

impl Part {
    pub fn parse(text: &str) -> Result<Self> {
        let mut part = Part {
            x: 0,
            m: 0,
            a: 0,
            s: 0,
        };
        let prop = None::<Prop>;
        // slice off first and last character for the brackets
        let chars = text[1..text.len() - 1].split(['=', ',']);
        for [k, v] in chars.array_chunks::<2>() {
            let v = v.parse()?;
            match k {
                "x" => {
                    part.x = v;
                }
                "m" => {
                    part.m = v;
                }
                "a" => {
                    part.a = v;
                }
                "s" => {
                    part.s = v;
                }
                k => bail!("Invalid property: {}", k),
            }
        }

        Ok(part)
    }

    fn get(&self, prop: &Prop) -> usize {
        match prop {
            Prop::X => self.x,
            Prop::M => self.m,
            Prop::A => self.a,
            Prop::S => self.s,
        }
    }
}

pub struct Pipeline {
    pub initial: WorkflowId,
    pub workflows: HashMap<WorkflowId, Workflow>,
}

impl Pipeline {
    pub fn accepts(&self, part: &Part) -> bool {
        let mut id = self.initial.clone();
        loop {
            match self.workflows[&id].run(part) {
                Target::Accept => return true,
                Target::Reject => return false,
                Target::Workflow(new_id) => {
                    id = new_id.clone();
                    continue;
                }
            }
        }
    }

    pub fn parts_accepted(&self) -> usize {
        let count = 0;
        let mut queue: Vec<(WorkflowId, PlatonicPart)> = Vec::new();
        queue.push((self.initial.clone(), PlatonicPart { constraints: Vec::new()}));
        while let Some((workflow_id, part)) = queue.pop() {
            
        }
        

        count
    }


}

pub struct Workflow {
    pub steps: Vec<Instruction>,
    pub last: Target,
}

impl Workflow {
    pub fn parse(text: &str) -> Result<(WorkflowId, Workflow)> {
        let mut iterator = text.split(['{', ',', '}']);
        let id = iterator.next().ok_or(anyhow!("missing workflow id"))?;

        let mut steps: Vec<Instruction> = Vec::new();
        let mut last = None::<Target>;
        for step in iterator {
            if !step.contains(':') {
                let target = match step {
                    "A" => Target::Accept,
                    "R" => Target::Reject,
                    id => Target::Workflow(WorkflowId(Rc::from(id))),
                };
                last = Some(target);
                break;
            }
            let chars = step.as_ascii().ok_or(anyhow!("not ascii"))?;
            let mut chars = chars.iter();

            let prop: Prop = match chars.next().ok_or(anyhow!("missing prop"))? {
                ascii::Char::SmallX => Prop::X,
                ascii::Char::SmallM => Prop::M,
                ascii::Char::SmallA => Prop::A,
                ascii::Char::SmallS => Prop::S,
                c => bail!("invalid property: {}", c),
            };

            let op: Op = match chars.next().ok_or(anyhow!("missing op"))? {
                ascii::Char::LessThanSign => Op::LessThan,
                ascii::Char::GreaterThanSign => Op::GreaterThan,
                c => bail!("invalid operator: {}", c),
            };

            let mut threshold = 0_usize;
            for char in chars.by_ref().take_while(|c| **c != ascii::Char::Colon) {
                threshold *= 10;
                threshold += (char.to_u8() - 48) as usize;
            }
            let mut target = String::with_capacity(step.len());
            let target = match chars.next().ok_or(anyhow!("missing target"))? {
                ascii::Char::CapitalA => Target::Accept,
                ascii::Char::CapitalR => Target::Reject,
                char => {
                    target.push(char.to_char());
                    //println!("matched: {:#?}", char.to_char());
                    target.extend(chars.map(|c| c.to_char()));
                    Target::Workflow(WorkflowId(Rc::from(target)))
                }
            };
            steps.push(Instruction {
                condition: Constraint { prop, op, threshold},
                target,
            });
        }

        Ok((
            WorkflowId(Rc::from(id)),
            Workflow {
                steps,
                last: last.expect("last"),
            },
        ))
    }
    pub fn run<'a>(&'a self, part: &Part) -> &'a Target {
        for step in self.steps.iter() {
            if step.condition.matches(part) {
                return &step.target;
            }
        }
        &self.last
    }
}

pub enum Target {
    Workflow(WorkflowId),
    Reject,
    Accept,
}

#[derive(Hash, Eq, PartialEq, Clone)]
pub struct WorkflowId(Rc<str>);

#[derive(Clone)]
pub enum Op {
    LessThan,
    GreaterThan,
    LessThanOrEqual,
    GreaterThanOrEqual,
}

impl Op {
    pub fn not(&self) -> Self {
        match self {
            Op::GreaterThan => Op::LessThanOrEqual,
            Op::LessThan => Op::GreaterThanOrEqual
            Op::GreaterThanOrEqual => Op::LessThan,
            Op::LessThanOrEqual => Op::GreaterThan,
        }
    }
}


pub struct Instruction {
    pub condition: Constraint,
    pub target: Target,
}

#[derive(Clone)]
pub struct Constraint {
    pub prop: Prop,
    pub op: Op,
    pub threshold: usize,
}

impl Constraint {
    pub fn matches(&self, part: &Part) -> bool {
        let rating = part.get(&self.prop);
        match self.op {
            Op::GreaterThan => rating > self.threshold,
            Op::LessThan => rating < self.threshold,

            Op::GreaterThanOrEqual => rating >= self.threshold,
            Op::LessThanOrEqual => rating <= self.threshold,
        }
    }
}

fn main() -> Result<()> {
    let text = include_str!("input.txt");
    let input = Input::parse(text)?;
    println!("Part 1: {}", input.accepted_total_rating());
    println!("Part 2: {}", input.pipeline.parts_accepted());
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
