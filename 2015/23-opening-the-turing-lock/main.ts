type Cmd = "hlf" | "tpl" | "inc" | "jmp" | "jie" | "jio";
type Register = "a" | "b";
type Instruction = { cmd: Cmd; register: Register; offset: number };
type Program = Instruction[];
type State = {
  a: number,
  b: number,
  i: number
}

const REGEXES = [
  /(?<cmd>jio) (?<register>[ab]), (?<offset>[+-]\d+)/,
  /(?<cmd>jie) (?<register>[ab]), (?<offset>[+-]\d+)/,
  /(?<cmd>jmp) (?<offset>[+-]\d+)/,
  /(?<cmd>inc) (?<register>[ab])/,
  /(?<cmd>tpl) (?<register>[ab])/,
  /(?<cmd>hlf) (?<register>[ab])/,
];

function parse(): Program {
  const program: Program = [];
  const input = Deno.readTextFileSync(import.meta.dirname + "/example.txt");
  for (const line of input.split("\n")) {
    let groups;
    for (const regex of REGEXES) {
      const match = line.match(regex);
      if (match) groups = match.groups!;
    }
    if (groups == null) continue
    program.push(
      {
        cmd: groups!["cmd"],
        register: groups!["register"],
        offset: Number(groups!["offset"]),
      } as Instruction,
    );
  }

  return program;
}

function run(program: Program) : State {
  console.log(program.length)
  const state = { a: 0, b: 0, i: 0}
  while (true) {
    const instruction = program[state.i]
    if (! instruction) return state;
    const { cmd, register, offset } = instruction;

    let jump = 1;
    if (cmd == "jmp") {
      jump = offset;
    }
    else if (cmd == "jio") {
      if (state[register] % 2 === 1) {
        jump = offset
      }
    }

    else if (cmd == "jie") {
      if (state[register] % 2 === 0) {
        jump = offset
      }
    }
    else if (cmd == "hlf") {
      state[register] /= 2;
    }

    else if (cmd == "tpl") {
      state[register] *= 3
    }

    else if (cmd == "inc") {
      state[register] += 1;
    }
    else {
      throw new Error()
    }

    state.i += jump
    console.log(state)
  }
}

console.log(run(parse()))
