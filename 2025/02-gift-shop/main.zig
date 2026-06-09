const std = @import("std");
const AocError = error{ NotImplemented, InvalidPart, MissingArg, InvalidRange };
const Part = enum { one, two };
const Args = struct { part: Part, filename: []const u8 };

const Range = struct {
    start: u64,
    end: u64,
    num_start_digits: usize,
    num_end_digits: usize,
};

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

pub fn solve(init: std.process.Init, file: std.Io.File, part: Part) !u64 {
    var total: u64 = 0;
    const buffer = try init.gpa.alloc(u8, 1024);
    defer init.gpa.free(buffer);

    var reader = file.reader(init.io, buffer);
    while (try reader.interface.takeDelimiter(',')) |raw| {
        var parts = std.mem.tokenizeAny(u8, raw, "-\n");
        const start = parts.next() orelse return AocError.InvalidRange;
        const end = parts.next() orelse return AocError.InvalidRange;

        const range = Range{
            .start = try std.fmt.parseInt(u32, start, 10),
            .end = try std.fmt.parseInt(u32, end, 10),
            .num_start_digits = start.len,
            .num_end_digits = end.len,
        };

        if (range.start > range.end) return AocError.InvalidRange;
        switch (part) {
            Part.one => {
                total += try invalidIdSum(range, 2);
            },

            Part.two => {
                for (2..(end.len + 1)) |num_parts| {
                    total += try invalidIdSum(range, num_parts);
                }
            },
        }
    }

    return total;
}

pub fn invalidIdSum(range: Range, numParts: usize) !u64 {
    var total: u64 = 0;

    const k = range.num_start_digits / numParts;
    const base = std.math.pow(u64, 10, k);

    // first k digits of range.start
    var initial = range.start;
    for (0..numParts - 1) |_| {
        initial /= base;
    }

    const floor = base / 10;
    initial = if (initial < floor) floor else initial;

    for (initial..base) |testNum| {
        std.debug.print("Id: {d}", .{testNum});
        var result: u64 = 0;
        for (0..numParts) |_| {
            result *= base;
            result += testNum;
        }
        if (result > range.end) break;
        if (result >= range.start) {
            std.debug.print("Id: {d}", .{result});
            total += result;
        }
    }

    return total;
}
