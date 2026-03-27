import { FibHeap } from "@/queue.ts";

interface SpellCost {
  name: Spell;
  cost: number;
}
const EFFECTS = ["shield", "poison", "recharge"] as const;
type Effect = typeof EFFECTS[number];

const SPELLS = [
  "magic-missile",
  "drain",
  "shield",
  "poison",
  "recharge",
] as const;
type Spell = typeof SPELLS[number];

const spell_costs: Record<Spell, number> = {
  "magic-missile": 53,
  "drain": 73,
  "shield": 113,
  "poison": 173,
  "recharge": 229,
} as const;

interface State {
  boss: {
    hp: number;
    dmg: number;
  };
  wizard: {
    spent: number;
    mana: number;
    hp: number;
    armor: number;
  };
  effects: Record<Effect, number>;
}

type RoundResult = "continue" | "win" | "loss";
function round(state: State, spell: Spell): RoundResult {
  // effects
  applyEffects(state);
  if (state.boss.hp < 0) return "win";

  // wizard
  applyEffect(state, "begin", spell);
  if (state.wizard.mana < 0) return "loss";
  if (state.boss.hp <= 0) return "win";

  // effects
  applyEffects(state);
  if (state.boss.hp < 0) return "win";

  // boss
  bossAttack(state);
  if (state.wizard.hp <= 0) return "loss";
  return "continue";
}
function bossAttack(state: State): void {
  const dmg = Math.max(1, state.boss.dmg - state.wizard.armor);
  state.wizard.hp -= dmg;
}

type Event = "begin" | "end" | "active";

function applyEffects(state: State): void {
  for (const effect of EFFECTS) {
    if (state.effects[effect]) {
      applyEffect(state, "active", effect);
      state.effects[effect]--;

      if (state.effects[effect] === 0) {
        applyEffect(state, "end", effect);
      }
    }
  }
}

function applyEffect(state: State, event: Event, spell: Spell) {
  if (event == "begin") {
    state.wizard.mana -= spell_costs[spell];
    state.wizard.spent += spell_costs[spell];
  }
  switch (spell as Spell) {
    case "magic-missile": {
      if (event === "begin") {
        state.boss.hp -= 4;
      }

      return;
    }

    case "drain": {
      if (event === "begin") {
        state.boss.hp -= 2;
        state.wizard.hp += 2;
      }

      return;
    }

    case "shield": {
      if (event === "begin") {
        state.wizard.armor += 7;
        state.effects.shield = 6;
      }

      if (event === "end") {
        state.wizard.armor -= 7;
      }
      return;
    }

    case "poison": {
      if (event == "begin") {
        state.effects.poison = 6;
      }
      if (event == "active") {
        state.boss.hp -= 3;
      }
      return;
    }

    case "recharge": {
      if (event == "begin") {
        state.effects.recharge = 5;
      }
      if (event == "active") {
        state.wizard.mana += 101;
      }
      return;
    }
  }
}

function example() {
  const state: State = {
    wizard: {
      hp: 10,
      mana: 250,
      armor: 0,
    },
    boss: {
      hp: 14,
      dmg: 8,
    },
    effects: {
      poison: 0,
      shield: 0,
      recharge: 0,
    },
  };
  const spells: Spell[] = [
    "recharge",
    "shield",
    "drain",
    "poison",
    "magic-missile",
  ] as const;

  for (const spell of spells) {
    round(state, spell);
  }
}
function part1() {
  const state: State = {
    wizard: {
      spent: 0,
      mana: 500,
      hp: 100,
      armor: 0,
    },
    boss: {
      hp: 51,
      dmg: 9,
    },
    effects: {
      poison: 0,
      shield: 0,
      recharge: 0,
    },
  };

  const queue = new FibHeap();
  queue.insert(state.boss.hp, state);
  let cheapest = Number.POSITIVE_INFINITY;
  while (true) {
    const min = queue.findMin();

    if (min == null) break;
    queue.deleteMin();
    const [_, state] = min;
    for (const spell of SPELLS) {
      const clone = structuredClone(state) as State;
      switch (round(clone, spell)) {
        case "loss":
          continue;
        case "win":
          if (clone.wizard.spent < cheapest) cheapest = clone.wizard.spent;
          continue;
        case "continue": {
          if (clone.wizard.spent < cheapest) {
            queue.insert(clone.boss.hp, clone);
          }
          continue;
        }
      }
    }
  }
  return cheapest;
}

console.log(part1())
