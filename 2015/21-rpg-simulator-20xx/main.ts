interface Stats {
  hp: number;
  dmg: number;
  armor: number;
}


function part2() {
  const boss: Stats = {
    hp: 104,
    dmg: 8,
    armor: 1,
  };
  const shop = parseShop();
  const builds = outfit(shop);
  return builds.filter(b => simulate(b, boss) == "boss").sort((a,b) => (b.gold - a.gold))[0];
}
function part1() {
  const boss: Stats = {
    hp: 104,
    dmg: 8,
    armor: 1,
  };
  const shop = parseShop();
  const builds = outfit(shop);
  return builds.filter(b => simulate(b, boss) == "me").sort((a,b) => (a.gold - b.gold))[0];
}
interface Equipment {
  cost: number;
  dmg: number;
  armor: number;
}
interface Build extends Stats {
  gold: number
}

interface Shop {
  weapons: Equipment[];
  armor: Equipment[];
  rings: Equipment[];
}

function outfit(shop: Shop): Array<Build> {
  const base: Build = {
    hp: 100,
    dmg: 0,
    armor: 0,
    gold: 0,
  };

  // create "empty" slots
  shop.armor.push({ cost: 0, dmg: 0, armor: 0});
  shop.rings.push({ cost: 0, dmg: 0, armor: 0});
  const builds: Array<Build> = [];
  for (const weapon of shop.weapons) {
    for (const armor of shop.armor) {
      for (const ring1 of shop.rings) {
        for (const ring2 of shop.rings) {
          if (ring1.cost == ring2.cost && ring1.cost !== 0) continue;
          builds.push(apply(apply(apply(apply(base, weapon), armor), ring1), ring2));
        }
      } 
    }
  }

  return builds;
}

function apply(stats: Build, equip: Equipment): Build {
  return ({ 
    hp: stats.hp, 
    gold: stats.gold + equip.cost,
    dmg: stats.dmg + equip.dmg, 
    armor: stats.armor + equip.armor
  })
}

type Winner = "me" | "boss";
function simulate(mine: Stats, boss: Stats): Winner {
  const mineDmg = Math.max(1, mine.dmg - boss.armor);
  const turnsToKill = Math.ceil(boss.hp / mineDmg);
  const bossDmg = Math.max(1, boss.dmg - mine.armor);
  const turnsToLose = Math.ceil(mine.hp / bossDmg);
  return turnsToLose < turnsToKill ? "boss" : "me";
}

type EquipmentType = "weapon" | "armor" | "ring";
function parseShop(): Shop {
  const input = Deno.readTextFileSync("./shop.txt");
  let type: EquipmentType = "weapon";
  const shop: Shop = { weapons: [], armor: [], rings: []};
  for (const line of input.split("\n")) {
    if (line.startsWith("Weapons")) {
      type = "weapon";
    }
    else if (line.startsWith("Armor")) { type = "armor"; }
    else if (line.startsWith("Rings")) { type = "ring";}

    else {
      const values = line.split(/\s+/).reverse();
      const equipment : Equipment = { 
        cost: Number(values[2]), dmg: Number(values[1]), armor: Number(values[0])
      };
      if (Number.isNaN(equipment.cost)) continue;
      switch (type as EquipmentType) {
        case "weapon": 
          shop.weapons.push(equipment);
          continue;

        case "armor": 
          shop.armor.push(equipment);
          continue;

        case "ring": 
          shop.rings.push(equipment);
          continue;
      }
    }
  }
  return shop;
}
console.log(part1())
console.log(part2())
