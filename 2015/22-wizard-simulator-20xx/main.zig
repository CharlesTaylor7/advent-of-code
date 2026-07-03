const std = @import("std");
const AocError = error{ NotImplemented, InvalidPart, MissingArg, InvalidRange };
const Part = enum { one, two };
const Args = struct { part: Part };

pub fn main(init: std.process.Init) !void {
    const args = try parse_args(init.minimal.args);

    const answer = try solve(init, args.part);
    const buffer = try init.gpa.alloc(u8, 1024);
    defer init.gpa.free(buffer);

    var stdout = std.Io.File.stdout().writer(init.io, buffer);
    try stdout.interface.print("{d}\n", .{answer});
    try stdout.interface.flush();
}

fn parse_args(passedArgs: std.process.Args) !Args {
    var args = passedArgs.iterate();
    _ = args.skip();
    const rawPart = args.next() orelse return AocError.MissingArg;
    const part = try parse_part(rawPart);
    return .{ .part = part };
}

fn parse_part(arg: []const u8) !Part {
    const part = try std.fmt.parseInt(u8, arg, 10);
    if (part == 1) return Part.one;
    if (part == 2) return Part.two;
    return AocError.InvalidPart;
}

fn solve(init: std.process.Init, part: Part) !u64 {
    return switch (part) {
        .one => part1(init, EXAMPLE),
        .two => return error.not_implemented,
    };
}

const EXAMPLE: State = .{
    .wizard_hp = 10,
    .wizard_mana = 250,
    .boss_hp = 13,
    .boss_dmg = 8,
};
const INPUT: State = .{
    .wizard_hp = 50,
    .wizard_mana = 500,
    .boss_hp = 51,
    .boss_dmg = 9,
};

const Queue = Heap(.{ .key = u64, .val = State });
fn part1(init: std.process.Init, state: State) !u64 {
    var queue = try Queue.init(init.gpa, 1000);
    defer queue.deinit(init.gpa);

    try queue.insert(init.gpa, state.total_mana_spent, state);
    while (queue.data.items.len > 0) {
        const root = try queue.extract_root();
        for (std.enums.values(WizardSpell)) |spell| {
            // copy the state
            var current: State = root.val;
            const winner = current.round(spell) catch continue;
            if (winner) |win| {
                switch (win) {
                    .boss => continue,
                    .wizard => {
                        std.debug.print("{}\n", .{state});
                        return state.total_mana_spent;
                    },
                }
            } else {
                try queue.insert(init.gpa, current.total_mana_spent, current);
            }
        }
    }

    return 42;
}

fn part2(init: std.process.Init, file: std.Io.File) !u64 {
    {
        const buffer = try init.gpa.alloc(u8, 1024);
        defer init.gpa.free(buffer);
        defer file.close(init.io);

        var reader = file.reader(init.io, buffer);
        while (try reader.interface.takeDelimiter('\n')) |line| {
            _ = line;
        }
    }
    return 42;
}

const WizardSpell = enum {
    magic_missile,
    drain,
    shield,
    poison,
    recharge,
};

const Winner = enum(u2) {
    wizard = 1,
    boss = 2,
};
const RoundResult = enum {
    wizard_wins,
    boss_wins,
    battle_continues,
};

const ArrayList = std.array_list.Aligned;
const HeapType = struct {
    key: type,
    val: type,
};
pub fn Heap(comptime heapType: HeapType) type {
    const Key = heapType.key;
    const Val = heapType.val;
    const HeapEntry = struct {
        key: Key,
        val: Val,
    };

    return struct {
        const Self = @This();

        const Storage = ArrayList(HeapEntry, null);
        data: Storage,

        fn init(alloc: std.mem.Allocator, capacity: usize) !Self {
            return .{
                .data = try Storage.initCapacity(alloc, capacity),
            };
        }
        fn deinit(self: *Self, gpa: std.mem.Allocator) void {
            self.data.deinit(gpa);
        }

        fn insert(self: *Self, alloc: std.mem.Allocator, key: Key, value: Val) !void {
            const pair = HeapEntry{ .key = key, .val = value };
            try self.data.append(alloc, pair);
            self._trickle_down();
        }

        fn extract_root(self: *Self) !HeapEntry {
            if (self.data.items.len == 0) return error.EmptyHeap;
            const entry = self.data.swapRemove(0);
            self._trickle_up();
            return entry;
        }

        fn _trickle_down(self: *Self) void {
            var k = self.data.items.len - 1;
            var temp: HeapEntry = undefined;
            while (k > 0) {
                const next = (k - 1) / 2;
                const child = self.data.items[k];
                const parent = self.data.items[next];
                if (has_priority(child.key, parent.key)) {
                    // swap
                    temp = self.data.items[k];
                    self.data.items[k] = self.data.items[next];
                    self.data.items[next] = temp;
                } else {
                    break;
                }
                k = next;
            }
        }

        fn _trickle_up(self: *Self) void {
            var k: usize = 0;

            var temp: HeapEntry = undefined;
            while (true) {
                const left = 2 * k + 1;
                const right = 2 * k + 2;
                if (left >= self.data.items.len) {
                    break;
                }
                // compare and swap left
                if (right == self.data.items.len or has_priority(self.data.items[left].key, self.data.items[right].key)) {
                    const parent = self.data.items[k];
                    const child = self.data.items[left];
                    if (has_priority(child.key, parent.key)) {
                        // swap
                        temp = self.data.items[k];
                        self.data.items[k] = self.data.items[left];
                        self.data.items[left] = temp;
                        k = left;
                    } else {
                        break;
                    }
                }

                // compare and swap right
                else {
                    const parent = self.data.items[k];
                    const child = self.data.items[right];
                    if (has_priority(child.key, parent.key)) {
                        // swap
                        temp = self.data.items[k];
                        self.data.items[k] = self.data.items[right];
                        self.data.items[right] = temp;
                        k = right;
                    } else {
                        break;
                    }
                }
            }
        }

        fn has_priority(a: Key, b: Key) bool {
            return a < b;
        }

        fn debug_print(self: *const Self) void {
            std.debug.print("\n", .{});
            var i: usize = 0;
            var powerOfTwo: usize = 2;
            while (i < self.data.items.len) {
                if (i == powerOfTwo - 1) {
                    std.debug.print("\n", .{});
                    powerOfTwo *= 2;
                }

                std.debug.print("{d} ", .{self.data.items[i].key});
                i += 1;
            }

            std.debug.print("\n", .{});
        }
    };
}
const State = struct {
    wizard_hp: i8,
    wizard_mana: i32,
    boss_hp: i8,
    boss_dmg: i8,
    effect_shield_turns: u8 = 0,
    effect_poison_turns: u8 = 0,
    effect_recharge_turns: u8 = 0,
    total_mana_spent: u64 = 0,

    fn spell_cost(spell: WizardSpell) u8 {
        return switch (spell) {
            .magic_missile => 53,
            .drain => 73,
            .shield => 113,
            .poison => 173,
            .recharge => 229,
        };
    }

    fn check_winner(self: State) ?Winner {
        if (self.wizard_hp <= 0) return .boss;
        if (self.boss_hp <= 0) return .wizard;
        return null;
    }

    fn round(self: *@This(), spell: WizardSpell) !?Winner {
        try self.cast_spell(spell);
        if (self.check_winner()) |win| return win;

        self.effects_tick();
        if (self.check_winner()) |win| return win;

        self.boss_attacks();
        if (self.check_winner()) |win| return win;

        self.effects_tick();
        if (self.check_winner()) |win| return win;

        return null;
    }

    fn boss_attacks(self: *@This()) void {
        const armor: i8 = if (self.effect_shield_turns > 0) 7 else 0;
        if (armor <= self.boss_dmg) {
            self.wizard_hp -= self.boss_dmg - armor;
        }
    }

    fn effects_tick(self: *@This()) void {
        if (self.effect_shield_turns > 0) {
            self.effect_shield_turns -= 1;
        }
        if (self.effect_poison_turns > 0) {
            self.effect_poison_turns -= 1;
            self.boss_hp -= 3;
        }
        if (self.effect_recharge_turns > 0) {
            self.effect_recharge_turns -= 1;
            self.wizard_mana += 101;
        }
    }

    fn cast_spell(self: *@This(), spell: WizardSpell) !void {
        if (self.wizard_mana < spell_cost(spell)) return error.NotEnoughMana;
        const effect_active = switch (spell) {
            .shield => self.effect_shield_turns > 0,
            .poison => self.effect_poison_turns > 0,
            .recharge => self.effect_recharge_turns > 0,
            else => false,
        };
        if (effect_active) return error.EffectActive;

        const cost = spell_cost(spell);
        self.wizard_mana -= cost;
        self.total_mana_spent += cost;

        switch (spell) {
            .magic_missile => {
                self.boss_hp -= 4;
            },

            .drain => {
                self.boss_hp -= 2;
                self.wizard_hp += 2;
            },

            .shield => {
                self.effect_shield_turns = 6;
            },

            .poison => {
                self.effect_poison_turns = 6;
            },

            .recharge => {
                self.effect_recharge_turns = 5;
            },
        }
    }
};
