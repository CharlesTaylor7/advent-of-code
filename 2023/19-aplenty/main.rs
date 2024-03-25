#!/usr/bin/env cargo +nightly -Zscript
//! ```cargo
//! [dependencies]
//! anyhow = "*"
//! ```
#![feature(iter_collect_into, ascii_char, ascii_char_variants)]
#![allow(unused_imports)]
#![allow(unused_mut)]
#![allow(unused_variables)]
#![allow(dead_code)]
#![allow(unreachable_code)]
use std::ascii;
use anyhow::{anyhow, bail, Result};
use std::collections::HashSet;
use std::{collections::HashMap, rc::Rc};

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
            pipeline: Pipeline { initial, workflows},
            parts,
        })
    }

    pub fn answer(&self) -> usize {
        let mut result = 0;
        for part in self.parts.iter() {
            if self.pipeline.accepts(part) {
                result += part.x + part.m + part.a + part.s;
            }
        }
        result
    }
}

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
        println!("{}", text);
        Ok(Part { x: 0, m: 0, a: 0, s: 0})
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
        let mut last: None::<Target>;
        for step in iterator {
            if !step.contains(':') {
               last = Some(Target:: 
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
            };
            let mut target = String::with_capacity(step.len());
            let target = match chars.next().ok_or(anyhow!("missing target"))? {
                ascii::Char::CapitalA => Target::Accept,
                ascii::Char::CapitalR => Target::Reject,
                char => {
                    target.push(char.to_char());
                    target.extend(chars.map(|c| c.to_char()));
                    Target::Workflow(WorkflowId(Rc::from(target)))
                }
            };
            steps.push(Instruction { prop, op, threshold, target});
        }

        println!("original: {}", text);
        println!("id: {}", id);

        Ok((WorkflowId(Rc::from(id)), Workflow {
            steps: vec![],
            last: Target::Accept,
        }))
    }
    pub fn run<'a>(&'a self, part: &Part) -> &'a Target {
     for step in self.steps.iter() {
        if step.matches(part) {
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

pub enum Op {
    LessThan,
    GreaterThan,
}

pub struct Instruction {
    pub prop: Prop,
    pub threshold: usize,
    pub op: Op,
    pub target: Target,
}

impl Instruction {
    pub fn matches(&self, part: &Part) -> bool {
        let rating = part.get(&self.prop);
        match self.op {
            Op::GreaterThan => rating > self.threshold,
            Op::LessThan => rating < self.threshold
        }
    }
}

fn main() -> Result<()> {
    let text = include_str!("example.txt");
    let input = Input::parse(text)?;
    println!("Part 1: {}", input.answer());
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
