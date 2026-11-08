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

fn parseOffset(arg: []const u8) !i8 {
    return std.fmt.parseInt(i8, arg, 10) catch  {

        std.debug.print("{s}\n", .{arg});
        std.debug.print("{d}\n", .{arg.len});
        return error.InvalidOffset;
    };
}

fn solve(init: std.process.Init, file: std.Io.File, part: Part) !u64 {
    return switch (part) {
        .one => part1(init, file),
        .two => part2(init, file),
    };
}

fn parse(init: std.process.Init, file: std.Io.File) !State {
    const buffer = try init.gpa.alloc(u8, 1024);
    defer init.gpa.free(buffer);
    defer file.close(init.io);

    var reader = file.reader(init.io, buffer);
    var program = try std.array_list.Aligned(Instruction, null).initCapacity(init.gpa, 100);

    while (try reader.interface.takeDelimiter('\n')) |line| {
        var iterator = std.mem.splitAny(u8, line, " ,+");

        std.debug.print("{s}\n", .{line});
        const code = std.meta.stringToEnum(Code, iterator.next() orelse return error.InvalidInstruction) orelse return error.InvalidInstruction;

        var register: Register = .a;
        var offset: i8 = 0;
        switch (code) {
            .jmp => {
                const rawOffset = iterator.next() orelse return error.InvalidInstruction;
                offset = try parseOffset(rawOffset);
            },

            .jio, .jie => {
                const rawRegister = iterator.next() orelse return error.InvalidInstruction;
                
                register = std.meta.stringToEnum(Register, rawRegister) orelse return error.InvalidInstruction;

                const rawOffset = while (true) {
                    const raw = iterator.next() orelse return error.InvalidInstruction;
                    if (raw.len > 0) break raw;
                };
                    
                offset = try parseOffset(rawOffset);
            },
            .inc, .hlf, .tpl => {
                const rawRegister = iterator.next() orelse return error.InvalidInstruction;
                register = std.meta.stringToEnum(Register, rawRegister) orelse return error.InvalidInstruction;
            },
        }

        const instruction = Instruction{
            .code = code,
            .register = register,
            .offset = offset,
        };
        std.debug.print("{}\n", .{instruction});
        try program.append(init.gpa, instruction);
    }
    program.shrinkAndFree(init.gpa, program.items.len);
    return State{
        .program = try program.toOwnedSlice(init.gpa),
    };
}

fn part1(init: std.process.Init, file: std.Io.File) !u64 {
    var state = try parse(init, file);
    defer init.gpa.free(state.program);
    return state.execute();
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

// instructions
// half:
// hlf <register>
// triple:
// tpl <register>
// increment:
// inc <register>
// jump:
// jmp <offset>
// jump if even
// jie <register>, <offset>
// jump if odd
// jio <register>, <offset>
//
const Code = enum(u4) { hlf, tpl, inc, jmp, jie, jio };
const Register = enum(u1) { a, b };
const Instruction = struct { code: Code, register: Register, offset: i8 };
const State = struct {
    program: []Instruction,
    line: usize = 0,
    reg_a: u64 = 0,
    reg_b: u64 = 0,

    pub fn register(self: *@This(), reg: Register) *u64 {
        return switch (reg) {
            .a => &self.reg_a,
            .b => &self.reg_b,
        };
    }

    pub fn execute(self: *@This()) u64 {
        while (self.line < self.program.len) {
            const instruction = self.program[self.line];
            var jmp: i8 = 1;
            switch (instruction.code) {
                .hlf => {
                    self.register(instruction.register).* /= 2;
                },

                .tpl => {
                    self.register(instruction.register).* *= 3;
                },

                .inc => {
                    self.register(instruction.register).* += 1;
                },

                .jmp => {
                    jmp = instruction.offset;
                },
                .jie => {
                    if (self.register(instruction.register).* % 2 == 0) {
                        jmp = instruction.offset;
                    }
                },
                .jio => {
                    if (self.register(instruction.register).* % 2 == 1) {
                        jmp = instruction.offset;
                    }
                },
            }

            if (jmp > 0) {
                self.line += @intCast(jmp);
            } else {
                self.line = @intCast(@as(i8, @intCast(self.line)) + jmp);
            }
        }
        return self.reg_b;
    }
};
