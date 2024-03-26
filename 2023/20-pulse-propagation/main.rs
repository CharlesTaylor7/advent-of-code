#!/usr/bin/env cargo +nightly -Zscript
//! ```cargo
//! [dependencies]
//! anyhow = "*"
//! ```
use anyhow::{anyhow, bail, Result};
use std::char;
use std::collections::{HashMap, VecDeque};
use std::fs;
use std::io::{Write, BufWriter};
use std::process::Command;

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

impl <'a> Module<'a> {
    pub fn reset(&mut self) {
        match self {
            Self::Broadcast => {},
            Self::FlipFlop { switch } => {
                *switch = Switch::Off;
            }

            Self::Conjunction { inputs } => {
                for pulse in inputs.values_mut() {
                    *pulse = Pulse::Low;
                }
            }
        }
    }
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
    pub push_count: usize,
}

impl<'a> Network<'a> {
    pub fn part1(&mut self) -> Result<usize> {
        for _ in 0..1000 {
            self.push_button_once()?;
        }
        Ok(self.low_pulses * self.high_pulses)
    }

    pub fn part2(&mut self) -> Result<usize> {
        loop {
            if self.push_button_once()? {
                return Ok(self.push_count);
            }
        }
    }

    pub fn reset(&mut self) {
        for module in self.modules.values_mut() {
            module.reset();
        }
    }
      
    pub fn push_button_once(&mut self) -> Result<bool> {
        self.push_count += 1;
        self.messages.push_back(Packet { from: ModuleId("button"), to: BROADCASTER, pulse: Pulse::Low});
        while let Some(packet) = self.messages.pop_front() {
            if packet.to == ModuleId("rx") && matches!(packet.pulse, Pulse::Low) {
                return Ok(true);
            }
            
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
        Ok(false)
    }

    pub fn parse(text: &'a str) -> Result<Self> {
        let mut modules = HashMap::new();
        let mut cables = HashMap::new();

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
            cables.insert(id, rest.split(", ").map(|id| ModuleId(id)).collect());
        }

        for (id, cables) in cables.iter() {
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
            cables,
            push_count: 0,
        })
    }

    pub fn dump_graphviz(&self) -> Result<()>{
        let file = fs::OpenOptions::new()
            .truncate(true)
            .write(true)
            .create(true)
            .open(format!("network-{}.dot", self.push_count))?;
        let mut file = BufWriter::new(file);

        let indent = "";
        write!(&mut file, "strict digraph {{\n")?;
        // min rank
        write!(&mut file, "{indent: <2}subgraph {{\n")?;
        write!(&mut file, "{indent: <4}rank=min;\n{indent: <4}")?;
        write!(&mut file, "{}; ", BROADCASTER.0)?;
        write!(&mut file, "\n{indent: <2}}}\n")?;

        // max rank
        write!(&mut file, "{indent: <2}subgraph {{\n")?;
        write!(&mut file, "{indent: <4}rank=max;\n{indent: <4}")?;
        write!(&mut file, "{}; ", "rx")?;
        write!(&mut file, "\n{indent: <2}}}\n")?;

        for (from, to) in self.cables.iter() {
            for to in to.iter() {
                // todo: include module type and module state as colors or labels
                write!(
                    &mut file,
                    "{indent: <2}{} -> {}\n",
                    from.0, to.0
                )?;
            }
        }
        write!(&mut file, "}}")?;
        file.flush()?;
        Command::new("dot")
            .args([
                "-Tsvg",
                &format!("network-{}.dot", self.push_count),
                "-o",
                &format!("network-{}.svg", self.push_count),
            ])
            .output()?;
        Ok(())
    }
}

fn main() -> Result<()> {
    let input = include_str!("input.txt");
    let mut network = Network::parse(input)?;

    println!("Part 1: {}", network.part1()?);
    network.reset();
    println!("Part 2: {}", network.part2()?);

    Ok(())
}
