#!/usr/bin/env cargo +nightly -Zscript
//! ```cargo
//! [dependencies]
//! anyhow = "*"
//! ```
use anyhow::{anyhow, bail, Result};
use std::char;
use std::collections::{HashMap, VecDeque};
use std::fs;
use std::io::{BufWriter, Write};
use std::process::Command;
use std::rc::Rc;

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

#[derive(Debug, Clone)]
pub enum Module<'a> {
    Broadcast,
    FlipFlop {
        switch: Switch,
    },
    Conjunction {
        inputs: HashMap<ModuleId<'a>, Pulse>,
    },
}

impl<'a> Module<'a> {
    pub fn reset(&mut self) {
        match self {
            Self::Broadcast => {}
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
type Pulses<'a> = HashMap<(ModuleId<'a>, ModuleId<'a>), Pulse>;

#[derive(Debug, Clone)]
pub struct Network<'a> {
    pub initial: ModuleId<'a>,
    pub terminal: ModuleId<'a>,
    pub modules: HashMap<ModuleId<'a>, Module<'a>>,
    pub cables: HashMap<ModuleId<'a>, Rc<[ModuleId<'a>]>>,
}

#[derive(Debug)]
pub struct NetworkEngine<'a> {
    pub network: Network<'a>,
    pub messages: VecDeque<Packet<'a>>,
    pub low_pulses: usize,
    pub high_pulses: usize,
    pub push_count: usize,
}

impl<'a> NetworkEngine<'a> {
    pub fn new(network: Network<'a>) -> Self {
        Self {
            network,
            messages: VecDeque::new(),
            low_pulses: 0,
            high_pulses: 0,
            push_count: 0,
        }
    }

    pub fn part1(&mut self) -> Result<usize> {
        for _ in 0..1000 {
            self.push_button()?;
        }
        Ok(self.low_pulses * self.high_pulses)
    }
    pub fn reset(&mut self) {
        self.network.reset();
        self.push_count = 0;
        self.low_pulses = 0;
        self.high_pulses = 0;
        self.messages.clear();
    }

    pub fn push_button(&mut self) -> Result<bool> {
        self.push_count += 1;
        self.messages.push_back(Packet {
            from: ModuleId("button"),
            to: self.network.initial,
            pulse: Pulse::Low,
        });

        while let Some(packet) = self.messages.pop_front() {
            if packet.to == self.network.terminal && matches!(packet.pulse, Pulse::Low) {
                return Ok(true);
            }

            match packet.pulse {
                Pulse::Low => {
                    self.low_pulses += 1;
                }
                Pulse::High => {
                    self.high_pulses += 1;
                }
            }

            match self.network.modules.get_mut(&packet.to) {
                None => {}
                Some(Module::Broadcast) => {
                    for id in self.network.cables[&packet.to].iter() {
                        self.messages.push_back(Packet {
                            from: packet.to,
                            to: *id,
                            pulse: packet.pulse,
                        });
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

                        for id in self
                            .network
                            .cables
                            .get(&packet.to)
                            .into_iter()
                            .flat_map(|o| o.into_iter())
                        {
                            self.messages.push_back(Packet {
                                from: packet.to,
                                to: *id,
                                pulse,
                            });
                        }
                    }
                }

                Some(Module::Conjunction { inputs }) => {
                    inputs.insert(packet.from, packet.pulse);
                    let pulse = if inputs.values().all(|p| matches!(p, Pulse::High)) {
                        Pulse::Low
                    } else {
                        Pulse::High
                    };

                    for id in self
                        .network
                        .cables
                        .get(&packet.to)
                        .into_iter()
                        .flat_map(|o| o.into_iter())
                    {
                        self.messages.push_back(Packet {
                            from: packet.to,
                            to: *id,
                            pulse,
                        });
                    }
                }
            }
        }
        Ok(false)
    }

    pub fn dump_graphviz(&self, pulses: &Pulses<'a>) -> Result<()> {
        let file = fs::OpenOptions::new()
            .truncate(true)
            .write(true)
            .create(true)
            .open(format!("graphviz/dot/{}.dot", self.push_count))?;
        let mut file = BufWriter::new(file);

        let indent = "";
        write!(&mut file, "strict digraph {{\n")?;
        // min rank
        write!(&mut file, "{indent: <2}subgraph {{\n")?;
        write!(&mut file, "{indent: <4}rank=min;\n{indent: <4}")?;
        write!(&mut file, "{}; ", self.network.initial.0)?;
        write!(&mut file, "\n{indent: <2}}}\n")?;

        // max rank
        write!(&mut file, "{indent: <2}subgraph {{\n")?;
        write!(&mut file, "{indent: <4}rank=max;\n{indent: <4}")?;
        write!(&mut file, "{}; ", self.network.terminal.0)?;
        write!(&mut file, "\n{indent: <2}}}\n")?;

        // node labels
        for (id, module) in self.network.modules.iter() {
            let module_type = match module {
                Module::Broadcast => "",
                Module::FlipFlop { .. } => "%",
                Module::Conjunction { .. } => "&",
            };
            let color = match module {
                Module::FlipFlop { switch: Switch::On } => "blue",
                Module::FlipFlop {
                    switch: Switch::Off,
                } => "green",
                _ => "lightgrey",
            };

            write!(
                &mut file,
                "{indent: <2}{}[label=\"{}{}\";color=\"{}\"]\n",
                id.0, module_type, id.0, color
            )?;
        }

        for (from, to) in self.network.cables.iter() {
            for to in to.iter() {
                let label = match pulses.get(&(*from, *to)) {
                    Some(Pulse::Low) => "green",
                    Some(Pulse::High) => "blue",
                    None => "grey",
                };
                write!(
                    &mut file,
                    "{indent: <2}{} -> {}[color=\"{}\"]\n",
                    from.0, to.0, label
                )?;
            }
        }
        write!(&mut file, "}}")?;
        file.flush()?;
        Command::new("dot")
            .args([
                "-Tsvg",
                &format!("graphviz/dot/{}.dot", self.push_count),
                "-o",
                &format!("graphviz/svg/{}.svg", self.push_count),
            ])
            .output()?;
        Ok(())
    }
}

fn gcd(a: usize, b: usize) -> usize {
    if a == 0 {
        b
    } else if b == 0 {
        a
    } else {
        let max = std::cmp::max(a, b);
        let min = std::cmp::min(a, b);
        gcd(max % min, min)
    }
}

fn lcm(a: usize, b: usize) -> usize {
    a * b / gcd(a, b)
}

impl<'a> Network<'a> {
    pub fn part2(self) -> Result<usize> {
        let networks = [
            self.sliced(ModuleId("ts"), ModuleId("bq")),
            self.sliced(ModuleId("ls"), ModuleId("qh")),
            self.sliced(ModuleId("fv"), ModuleId("lt")),
            self.sliced(ModuleId("bn"), ModuleId("vz")),
        ];

        // just look at the first one for now
        let mut answer = 1;
        for network in networks {
            let mut engine = NetworkEngine::new(network);
            for i in 1..10_000 {
                if engine.push_button()? {
                    println!("{}", i);
                    answer = lcm(answer, i);
                    break;
                }
            }
            /*
            let mut bit = 1;
            let mut binary = 0_usize;
            let mut node_id = network.initial;
            while let Some(slice) = &network.cables.get(&node_id) {
                if slice.len() > 2 {
                    bail!("too many children");
                }
                if slice.len() == 2 {
                    binary += bit;
                }
                if let Some(id) = slice.iter().find(|id| **id != network.terminal) {
                    node_id = *id;
                    bit <<= 1;
                } else {
                    break;
                }
            }
            product *= binary;
            println!("{}", binary);
            */
        }
        Ok(answer)
    }

    pub fn reset(&mut self) {
        for module in self.modules.values_mut() {
            module.reset();
        }
    }

    pub fn remove_key(&mut self, id: ModuleId<'a>) {
        self.cables.remove(&id);
        self.modules.remove(&id);
    }

    pub fn sliced(&self, initial: ModuleId<'a>, terminal: ModuleId<'a>) -> Self {
        let mut modules = HashMap::new();
        let mut cables = HashMap::new();
        let mut to_visit = Vec::new();
        to_visit.push(initial);
        while let Some(id) = to_visit.pop() {
            modules.insert(id, self.modules[&id].clone());
            if id != terminal {
                cables.insert(id, self.cables[&id].clone());
                for cable in cables.get(&id).into_iter().flat_map(|c| c.into_iter()) {
                    if !modules.contains_key(cable) {
                        to_visit.push(*cable);
                    }
                }
            }
        }
        Self {
            initial,
            terminal,
            modules,
            cables,
        }
    }

    pub fn parse(text: &'a str) -> Result<Self> {
        let mut modules = HashMap::new();
        let mut cables: HashMap<ModuleId<'_>, Rc<[ModuleId<'_>]>> = HashMap::new();

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
                        Module::FlipFlop {
                            switch: Switch::Off,
                        }
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
            let vector = rest.split(", ").map(|id| ModuleId(id)).collect::<Rc<_>>();
            cables.insert(id, vector);
        }

        for (id, cables) in cables.iter() {
            for cable in cables.iter() {
                if let Some(Module::Conjunction { inputs }) = modules.get_mut(cable) {
                    inputs.insert(*id, Pulse::Low);
                }
            }
        }

        Ok(Self {
            modules,
            cables,
            initial: BROADCASTER,
            terminal: ModuleId("rx"),
        })
    }
}

fn main() -> Result<()> {
    let input = include_str!("input.txt");
    let network = Network::parse(input)?;
    let mut engine = NetworkEngine::new(network);
    //engine.dump_graphviz(&mut HashMap::new())?;

    println!("Part 1: {}", engine.part1()?);

    let NetworkEngine { mut network, .. } = engine;
    network.reset();

    println!("Part 2: {}", network.part2()?);

    Ok(())
}
