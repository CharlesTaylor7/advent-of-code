#!/usr/bin/env cargo +nightly -Zscript

#![allow(unused_imports)]
#![allow(unused_mut)]
#![allow(unused_variables)]
#![allow(dead_code)]
#![allow(unreachable_code)]

use std::{collections::HashMap, rc::Rc};

enum Dummy {}

impl std::fmt::Debug for Dummy {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "{}", 42)
    }
}

pub struct Input {
    pub pipeline: Pipeline,
    pub parts: Vec<Part>,
}
impl Input {
    fn answer(&self) -> usize {
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
        'machine: loop {
            for step in self.workflows[&id].steps.iter() {
                if step.matches(part) {
                    match &step.target {
                        Target::Accept => return true,
                        Target::Reject => return false,
                        Target::Workflow(new_id) => {
                            id = new_id.clone();
                            continue 'machine;
                        }
                    }
                }
            }
        }
    }
}

pub struct Workflow {
    pub steps: Vec<Instruction>,
    pub last: Target,
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

fn main() {
    let input = include_str!("example.txt");
    println!("Input:\n{input}");
    println!("Part 1: {}", 42);
}

#[cfg(test)]
mod tests {
    use crate::*;

    #[test]
    pub fn dummy() {
        assert_eq!(2 + 2, 4);
    }
}
