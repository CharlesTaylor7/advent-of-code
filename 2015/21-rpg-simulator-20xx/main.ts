interface Stats {
  hp: number;
  dmg: number;
  armor: number;
}
function part1() {
  const boss: Stats = {
    hp: 104,
    dmg: 8,
    armor: 1,
  };
}

interface Equipment {
  cost: number;
  dmg: number;
  armor: number;
}

interface Shop {
  weapons: Equipment[];
  armor: Equipment[];
  rings: Equipment[];
}

function* outfit(): Generator<Stats> {
  const base: Stats = {
    hp: 100,
    dmg: 0,
    armor: 0,
  };
}

type Winner = "me" | "boss";
function simulate(mine: Stats, boss: Stats): Winner {
  const mineDmg = Math.max(1, mine.dmg - boss.armor);
  const turnsToKill = Math.ceil(boss.hp / mineDmg);
  const bossDmg = Math.max(1, boss.dmg - mine.armor);
  const turnsToLose = Math.ceil(mine.hp / bossDmg);
  return turnsToLose < turnsToKill ? "boss" : "me";
}

part1();
