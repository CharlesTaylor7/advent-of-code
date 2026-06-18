const std = @import("std");
fn ArrayList(ty: type) type {
    return std.array_list.Aligned(ty, null);
}
const HashMap = std.hash_map.AutoHashMap;

const Allocator = std.mem.Allocator;

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

// This is a change making problem in disguise!
// It's all binary. We just need to figure out the numbers reachable by 1 xor, and then 2 xors etc.
const Section = enum { goal, buttons, joltage };
const MachinePart1 = struct {
    // encode in binary
    goal: u10,
    // binary
    buttons: ArrayList(u10),

    // [.#.#] (0,2,3) (1,3) {11,10,11,21}
    fn parse(alloc: Allocator, line: []u8) !@This() {
        var section: Section = .goal;
        var goal: u10 = 0;
        var buttons = try ArrayList(u10).initCapacity(alloc, 10);
        errdefer buttons.deinit(alloc);
        var button: u10 = 0;
        var digits: u4 = 0;

        var goalie: u10 = 1;
        for (line) |c| {
            std.debug.print("c: {c}\n", .{c});
            switch (section) {
                .goal => {
                    switch (c) {
                        '#' => {
                            goal += goalie;
                            goalie <<= 1;
                        },
                        '.' => {
                            goalie <<= 1;
                        },
                        ']' => {
                            section = .buttons;
                        },
                        ' ', '[' => {
                            //
                        },
                        else => return error.InvalidMachine,
                    }

                    std.debug.print("goal: {d}\n", .{goal});
                },
                .buttons => {
                    switch (c) {
                        ')' => {
                            // grow button
                            button += @as(u10, 1) << digits;
                            try buttons.append(alloc, button);
                            digits = 0;
                            button = 0;
                            std.debug.print("buttons: {any}\n", .{buttons.items});
                        },
                        '0'...'9' => {
                            // append digit
                            digits = @intCast(c - '0');
                            std.debug.print("digits: {any}\n", .{digits});
                        },
                        ',' => {
                            // grow button
                            button += @as(u10, 1) << digits;
                            digits = 0;
                            std.debug.print("button: {any}\n", .{button});
                        },

                        '(', ' ' => {},

                        '{' => {
                            section = .joltage;
                        },

                        else => return error.InvalidMachine,
                    }
                },

                .joltage => {
                    //
                    break;
                },
            }
        }
        return .{
            .buttons = buttons,
            .goal = goal,
        };
    }

    pub fn free(self: *@This(), alloc: Allocator) void {
        self.buttons.deinit(alloc);
    }

    pub fn solve(self: @This(), alloc: Allocator) !u64 {
        var a = try ArrayList(u10).initCapacity(alloc, self.buttons.items.len);
        var b = try ArrayList(u10).initCapacity(alloc, a.capacity * a.capacity);
        defer a.deinit(alloc);
        defer b.deinit(alloc);

        try a.append(alloc, 0);
        var current: *ArrayList(u10) = undefined;
        var next: *ArrayList(u10) = undefined;
        var presses: u64 = 0;
        while (true) {
            if (presses % 2 == 0) {
                current = &a;
                next = &b;
            } else {
                current = &b;
                next = &a;
            }

            presses += 1;
            for (self.buttons.items) |button| {
                for (current.items) |item| {
                    const val = button ^ item;
                    if (val == self.goal) return presses;
                    try next.append(alloc, val);
                }
            }
            current.clearRetainingCapacity();
        }

        unreachable;
    }
};

const MachinePart2 = struct {
    // encode in binary
    // binary
    buttons: ArrayList(u10),
    joltage: ArrayList(u5),

    // [.#.#] (0,2,3) (1,3) {11,10,11,21}
    fn parse(alloc: Allocator, line: []u8) !@This() {
        var section: Section = .goal;
        _ = &section;
        var buttons = try ArrayList(u10).initCapacity(alloc, 10);
        errdefer buttons.deinit(alloc);

        var joltage = try ArrayList(u5).initCapacity(alloc, 10);
        errdefer joltage.deinit(alloc);
        for (line) |c| {
            std.debug.print("c: {c}\n", .{c});
            switch (section) {
                .goal => {},
                .buttons => {},
                .joltage => {},
            }
        }
        return .{
            .buttons = buttons,
            .joltage = joltage,
        };
    }

    pub fn free(self: *@This(), alloc: Allocator) void {
        self.buttons.deinit(alloc);
    }

    pub fn solve(self: @This(), alloc: Allocator) !u64 {
        var a = try ArrayList(u10).initCapacity(alloc, self.buttons.items.len);
        var b = try ArrayList(u10).initCapacity(alloc, a.capacity * a.capacity);
        defer a.deinit(alloc);
        defer b.deinit(alloc);

        try a.append(alloc, 0);
        var current: *ArrayList(u10) = undefined;
        var next: *ArrayList(u10) = undefined;
        var presses: u64 = 0;
        while (true) {
            if (presses % 2 == 0) {
                current = &a;
                next = &b;
            } else {
                current = &b;
                next = &a;
            }

            presses += 1;
            for (self.buttons.items) |button| {
                for (current.items) |item| {
                    const val = button ^ item;
                    if (val == self.joltage) return presses;
                    try next.append(alloc, val);
                }
            }
            current.clearRetainingCapacity();
        }

        unreachable;
    }
};

fn solve(init: std.process.Init, file: std.Io.File, part: Part) !u64 {
    var total: u64 = 0;
    const buffer = try init.gpa.alloc(u8, 1024);
    defer init.gpa.free(buffer);
    defer file.close(init.io);

    var reader = file.reader(init.io, buffer);
    switch (part) {
        .one => {
            while (try reader.interface.takeDelimiter('\n')) |line| {
                var machine = try MachinePart1.parse(init.gpa, line);
                defer machine.free(init.gpa);

                total += try machine.solve(init.gpa);
            }
        },
        .two => {
            while (try reader.interface.takeDelimiter('\n')) |line| {
                var machine = try MachinePart2.parse(init.gpa, line);
                defer machine.free(init.gpa);

                total += try machine.solve(init.gpa);
            }
        },
    }
    return total;
}
