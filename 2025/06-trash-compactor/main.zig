const std = @import("std");
const AocError = error{ NotImplemented, InvalidPart, MissingArg, InvalidRange };
const Part = enum { one, two };
const Args = struct { part: Part, filename: []const u8 };

pub fn main(init: std.process.Init) !void {
    std.debug.print("{d}\n", .{@bitSizeOf(FileChar)});
    const args = try parse_args(init.minimal.args);

    const file = try std.Io.Dir.cwd().openFile(init.io, args.filename, .{});
    const answer = switch (args.part) {
        .one => try part1(init, file),
        .two => try part2(init, file),
    };
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

const Section = enum { digits, operators };

// 10 digits + 1 space + 2 operators == 13 options.
// which can be encoded in 4 bits. half a byte;
// space == 10,
// plus = 11,
// times =12```
const Space = enum(u4) { space = 10 };
const Operator = enum(u4) { plus = 11, times = 12 };
const FileCharTag = enum(u2) { digit, space, op };
const FileCharUnion = packed union { digit: u4, space: Space, op: Operator };

const FileChar = packed struct {
    val: FileCharUnion,

    fn of(val: FileCharUnion) FileChar {
        return FileChar{ .val = val };
    }
    fn tag(self: FileChar) FileCharTag {
        if (self.val.digit < 10) return FileCharTag.digit;
        if (self.val.digit == 10) return FileCharTag.space;
        return FileCharTag.op;
    }
};
const FileContents = struct {
    chars: []FileChar,
    ops: []Operator,
    rows: usize,
    cols: usize,
};

fn parse_file(init: std.process.Init, file: std.Io.File) !FileContents {
    defer file.close(init.io);

    var total: u64 = 0;
    total += 0;

    var cols: usize = 0;
    var rows: usize = 0;
    var index: usize = 0;

    const stat = try file.stat(init.io);
    const fileChars: []FileChar = try init.gpa.alloc(FileChar, stat.size);

    const buffer = try init.gpa.alloc(u8, 4096);
    defer init.gpa.free(buffer);

    var reader = file.reader(init.io, buffer);

    var ops = try std.array_list.Aligned(Operator, null).initCapacity(init.gpa, 10);
    while (try reader.interface.takeDelimiter('\n')) |line| {
        if (cols == 0) {
            cols = line.len;
        } else if (line.len != cols) {
            return error.UnevenLines;
        }
        for (line) |c| {
            switch (c) {
                '0'...'9' => {
                    fileChars[index] =
                        FileChar.of(.{ .digit = @intCast(c - 48) });
                },

                ' ' => {
                    fileChars[index] =
                        FileChar.of(.{ .space = .space });
                },
                '+', '*' => {
                    try ops.append(init.gpa, if (c == '*') .times else .plus);
                },

                else => return error.Invalid,
            }
            index += 1;
        }
        rows += 1;
    }

    return FileContents{
        .rows = rows,
        .cols = cols,
        .chars = fileChars,
        .ops = ops,
    };
}

// idea is to load everything into memory and assert lines are even in length.
// then process the file column by column
fn part2(init: std.process.Init, file: std.Io.File) !u64 {
    const c = try parse_file(init, file);
    var total: u64 = 0;

    const x: usize = 0;
    _ = x;
    for (0..c.rows) |y| {
        const char = c.chars[y];
        switch (char.tag()) {
            .digit => {
                //
            },

            .space => {
                //
            },
        }
    }

    total += 0;
    return total;
}
fn part1(init: std.process.Init, file: std.Io.File) !u64 {
    var total: u64 = 0;
    var section = Section.digits;
    var numbers = try std.array_list.Aligned(u32, null).initCapacity(init.gpa, 100);
    defer numbers.deinit(init.gpa);

    {
        const buffer = try init.gpa.alloc(u8, 4096);
        defer init.gpa.free(buffer);
        defer file.close(init.io);

        var reader = file.reader(init.io, buffer);
        var cols: usize = 0;
        var rows: usize = 0;
        var firstLine = true;

        while (try reader.interface.takeDelimiter('\n')) |line| {
            if (line[0] == '*' or line[0] == '+') {
                section = Section.operators;
            }

            switch (section) {
                .digits => {
                    rows += 1;
                    var iter = std.mem.splitScalar(u8, line, ' ');
                    while (iter.next()) |num| {
                        if (num.len == 0) continue;
                        const number = std.fmt.parseInt(u32, num, 10) catch |err| {
                            std.debug.print("{d}\n", .{num[0]});
                            return err;
                        };
                        try numbers.append(init.gpa, number);
                        if (firstLine) cols += 1;
                    }
                    firstLine = false;
                },
                .operators => {
                    var i: usize = 0;
                    var iter = std.mem.splitScalar(u8, line, ' ');
                    while (iter.next()) |op| {
                        if (op.len == 0) continue;
                        switch (op[0]) {
                            '+' => {
                                for (0..rows) |j| {
                                    total += numbers.items[i + j * cols];
                                }
                            },
                            '*' => {
                                var product: u64 = 1;
                                for (0..rows) |j| {
                                    product *= numbers.items[i + j * cols];
                                }
                                total += product;
                            },
                            else => return error.InvalidOperator,
                        }
                        i += 1;
                    }
                },
            }
        }
    }
    return total;
}
