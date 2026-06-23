const std = @import("std");
const AocError = error{ NotImplemented, InvalidPart, MissingArg, InvalidRange };
const Part = enum { one, two };
const Args = struct { part: Part, filename: []const u8 };

pub fn main(init: std.process.Init) !void {
    const args = try parse_args(init.minimal.args);

    const file = try std.Io.Dir.cwd().openFile(init.io, args.filename, .{});
    const answer = try solve(init, file, args.part);
    const buffer = try init.gpa.alloc(u8, 1024);
    defer init.gpa.free(buffer);

    var stdout = std.Io.File.stdout().writer(init.io, buffer);
    try stdout.interface.print("{d}\n", .{answer});
    try stdout.interface.flush();
}

fn parse_args(passedArgs: std.process.Args) !Args {
    var args = passedArgs.iterate();
    _ = args.skip();
    const filename = args.next() orelse return AocError.MissingArg;
    const rawPart = args.next() orelse return AocError.MissingArg;
    const part = try parse_part(rawPart);
    return .{ .part = part, .filename = filename };
}

fn parse_part(arg: []const u8) !Part {
    const part = try std.fmt.parseInt(u8, arg, 10);
    if (part == 1) return Part.one;
    if (part == 2) return Part.two;
    return AocError.InvalidPart;
}

fn solve(init: std.process.Init, file: std.Io.File, part: Part) !u64 {
    return switch (part) {
        .one => part1(init, file),
        .two => part2(init, file),
    };
}

fn part1(init: std.process.Init, file: std.Io.File) !u64 {
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

const Winner = enum {
    wizard = 1,
    boss = 2,
};
const RoundResult = enum {
    wizard_wins,
    boss_wins,
    battle_continues,
};

const State = struct {
    wizard_hp: i8,
    wizard_mana: i8,
    boss_hp: i8,
    boss_dmg: i8,
    effect_shield_turns: u8 = 0,
    effect_poison_turns: u8 = 0,
    effect_recharge_turns: u8 = 0,

    fn spell_cost(spell: WizardSpell) u8 {
        switch (spell) {
            .magic_missile => 53,
            .drain => 73,
            .shield => 113,
            .poison => 173,
            .recharge => 229,
        }
    }

    fn check_winner(self: State) ?Winner {
        if (self.wizard_hp <= 0) return .boss;
        if (self.boss_hp <= 0) return .wizard;
        return null;
    }

    fn round(self: State, spell: WizardSpell) !?Winner {
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

    fn boss_attacks(self: @This()) void {
        const armor = if (self.effect_shield_turns > 0) 7 else 0;
        if (armor <= self.boss_dmg) {
            self.wizard_hp -= self.boss_dmg - armor;
        }
    }

    fn effects_tick(self: @This()) void {
        if (self.effect_shield_turns > 0) {
            self.effect_shield_turns -= 1;
        }
        if (self.effect_poison_turns > 0) {
            self.effect_poison_turns -= 1;
            self.boss_hp -= 3;
        }
        if (self.effect_recharge_turns > 0) {
            self.effect_recharge_turns_turns -= 1;
            self.wizard_mana += 101;
        }
    }

    fn cast_spell(self: *@This(), spell: WizardSpell) !void {
        if (self.wizard_mana < spell_cost()) return .NotEnoughMana;
        const effect_active = switch (spell) {
            .shield => self.effect_shield_turns > 0,
            .poison => self.effect_poison_turns > 0,
            .recharge => self.effect_recharge_turns > 0,
            else => false,
        };
        if (effect_active) return .EffectActive;

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
