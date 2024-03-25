#!/usr/bin/env cargo +nightly -Zscript
//! ```cargo
//! [dependencies]
//! anyhow = "*"
//! ```
use anyhow::{anyhow, bail, Result};
use std::char;
use std::collections::{HashMap, VecDeque};

#[derive(Debug)]
pub enum Pulse {
    Low,
    High,
}

#[derive(Debug)]
pub enum Switch {
    On,
    Off,
}

#[derive(Debug)]
pub enum Module<'a> {
    Broadcast,
    FlipFlop {
        state: Switch,
    },
    Conjunction {
        inputs: HashMap<ModuleId<'a>, Pulse>,
    },
}

#[derive(Eq, Hash, PartialEq, Clone, Copy, Debug)]
pub struct ModuleId<'a>(&'a str);

#[derive(Debug)]
pub struct Network<'a> {
    pub modules: HashMap<ModuleId<'a>, Module<'a>>,
    pub module_cables: HashMap<ModuleId<'a>, Vec<ModuleId<'a>>>,
    pub incoming: VecDeque<(ModuleId<'a>, Pulse)>,
    pub low_pulses: usize,
    pub high_pulses: usize,
}

impl<'a> Network<'a> {
    pub fn push_button(&mut self, count: usize) {
        println!("{:#?}", self);
        todo!()
    }
    pub fn parse(text: &'a str) -> Result<Self> {
        let mut modules = HashMap::new();
        let mut module_cables = HashMap::new();

        for line in text.lines() {
            let broadcast_id = "broadcaster";
            let (id, module, rest): (ModuleId, Module, &str) = {
                if let Some(rest) = line.strip_prefix(broadcast_id) {
                    (ModuleId(broadcast_id), Module::Broadcast, rest)
                } else if let Some(rest) = line.strip_prefix(['%', '&']) {
                    let (id, rest) = rest
                        .split_once(char::is_whitespace)
                        .ok_or(anyhow!("missing identifier"))?;

                    let id = ModuleId(id);

                    let module = if &line[0..1] == "%" {
                        Module::FlipFlop { state: Switch::Off }
                    } else {
                        Module::Conjunction {
                            inputs: HashMap::new(),
                        }
                    };

                    (id, module, rest)
                } else {
                    bail!("Invalid module");
                }
            };

            modules.insert(id, module);

            let rest = rest.trim_start_matches([' ', '-', '>']);

            let cables = rest.split(", ").map(|id| ModuleId(id)).collect::<Vec<_>>();
            module_cables.insert(id, cables);
        }

        for (id, cables) in module_cables.iter() {
            for cable in cables {
                if let Some(Module::Conjunction { inputs }) = modules.get_mut(cable) {
                    inputs.insert(*id, Pulse::Low);
                }
            }
        }

        Ok(Self {
            low_pulses: 0,
            high_pulses: 0,
            incoming: VecDeque::new(),
            modules,
            module_cables,
        })
    }
}

fn main() -> Result<()> {
    let input = include_str!("example.txt");
    let mut network = Network::parse(input)?;
    network.push_button(1000);

    println!("Input:\n{input}");
    println!("Part 1: {}", network.low_pulses * network.high_pulses);
    Ok(())
}
