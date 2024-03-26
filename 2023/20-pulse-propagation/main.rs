#!/usr/bin/env cargo +nightly -Zscript
//! ```cargo
//! [dependencies]
//! anyhow = "*"
//! ```
use anyhow::{anyhow, bail, Result};
use std::char;
use std::collections::{HashMap, VecDeque};

const BROADCASTER: ModuleId = ModuleId("broadcaster");

#[derive(Debug, Clone, Copy)]
pub enum Pulse {
    Low,
    High,
}

#[derive(Debug, Clone, Copy)]
pub enum Switch {
    On,
    Off,
}

#[derive(Debug)]
pub enum Module<'a> {
    Broadcast,
    FlipFlop {
        switch: Switch,
    },
    Conjunction {
        inputs: HashMap<ModuleId<'a>, Pulse>,
    },
}

#[derive(Eq, Hash, PartialEq, Clone, Copy, Debug)]
pub struct ModuleId<'a>(&'a str);

#[derive(Debug)]
pub struct Packet<'a> {
    from: ModuleId<'a>,
    to: ModuleId<'a>,
    pulse: Pulse,
}

#[derive(Debug)]
pub struct Network<'a> {
    pub modules: HashMap<ModuleId<'a>, Module<'a>>,
    pub cables: HashMap<ModuleId<'a>, Vec<ModuleId<'a>>>,
    pub messages: VecDeque<Packet<'a>>,
    pub low_pulses: usize,
    pub high_pulses: usize,
}

impl<'a> Network<'a> {
    pub fn push_button(&mut self, count: usize) -> Result<()> {
        for _ in 0..count {
            self.push_button_once()?;
            // println!("{:#?}", self.modules.values());
        }
        Ok(())
    }

    pub fn push_button_once(&mut self) -> Result<()> {
        self.messages.push_back(Packet { from: ModuleId("button"), to: BROADCASTER, pulse: Pulse::Low});
        while let Some(packet) = self.messages.pop_front() {
            match packet.pulse {
                Pulse::Low => { self.low_pulses += 1;}
                Pulse::High => { self.high_pulses += 1;}
            }
            
            match self.modules.get_mut(&packet.to) {
                None => {},
                Some(Module::Broadcast) => {
                    for id in self.cables[&packet.to].iter() {
                        self.messages.push_back(Packet { from: packet.to, to: *id, pulse: packet.pulse });
                    }
                }

                Some(Module::FlipFlop { switch }) => {
                    if matches!(packet.pulse, Pulse::Low) {
                        *switch = match switch {
                            Switch::On => Switch::Off,
                            Switch::Off => Switch::On,
                        };

                        let pulse = match switch {
                            Switch::On => Pulse::High,
                            Switch::Off => Pulse::Low,
                        };

                        for id in self.cables[&packet.to].iter() {
                            self.messages.push_back(Packet { from: packet.to, to: *id, pulse });
                        }
                    }
                }

                Some(Module::Conjunction { inputs }) => {
                    inputs.insert(packet.from, packet.pulse);
                    let pulse = if inputs.values().all(|p| matches!(p, Pulse::High)) { Pulse::Low } else { Pulse::High };

                    for id in self.cables[&packet.to].iter() {
                        self.messages.push_back(Packet { from: packet.to, to: *id, pulse });
                    }
                }
            }

        }
        Ok(())
    }

    pub fn parse(text: &'a str) -> Result<Self> {
        let mut modules = HashMap::new();
        let mut module_cables = HashMap::new();

        for line in text.lines() {
            let (id, module, rest): (ModuleId, Module, &str) = {
                if let Some(rest) = line.strip_prefix(BROADCASTER.0) {
                    (BROADCASTER, Module::Broadcast, rest)
                } else if let Some(rest) = line.strip_prefix(['%', '&']) {
                    let (id, rest) = rest
                        .split_once(char::is_whitespace)
                        .ok_or(anyhow!("missing identifier"))?;

                    let id = ModuleId(id);

                    let module = if &line[0..1] == "%" {
                        Module::FlipFlop { switch: Switch::Off }
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
            messages: VecDeque::new(),
            modules,
            cables: module_cables,
        })
    }
}

fn main() -> Result<()> {
    let input = include_str!("input.txt");
    let mut network = Network::parse(input)?;
    network.push_button(1000)?;

    println!("Part 1: {}", network.low_pulses * network.high_pulses);
    Ok(())
}
