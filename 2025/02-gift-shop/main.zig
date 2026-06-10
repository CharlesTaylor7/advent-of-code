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

pub fn parseInt(text: []const u8) !u64 {
    return std.fmt.parseInt(u64, text, 10) catch |err| {
        std.debug.print("could not parse {s}\n", .{text});
        return err;
    };
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
            .start = try parseInt(start),
            .end = try parseInt(end),
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

// for part 2 this doesn't work:
// two issues:
// - the sequence 222222, can be formed from 1,2,or 3 repetitions, but they all should count as the same invalid id, not 3.
// - The first n digits of range.start is not a good lower bound. it misses 111, in the range 95-115
pub fn invalidIdSum(range: Range, numParts: usize) !u64 {
    // std.debug.print("range: {d}-{d} \n", .{ range.start, range.end });
    var total: u64 = 0;

    const k = range.num_start_digits / numParts;
    var base = std.math.pow(u64, 10, k);

    const assembledLength = k * numParts;
    var initial = range.start;
    if (assembledLength == range.num_start_digits) {
        //

        //  std.debug.print("d:{d} p:{d} k: {d}\n", .{ range.num_start_digits, numParts, k });
        // first k digits of range.start
        for (0..numParts - 1) |_| {
            initial /= base;
        }

        const floor = base / 10;
        initial = if (initial < floor) floor else initial;
    } else if (assembledLength + 1 == range.num_start_digits) {
        initial = std.math.pow(u64, 10, k);
        base *= 10;
    } else {
        return 0;
    }

    // std.debug.print("initial:{d} base:{d}\n", .{ initial, base });
    if (initial > base) return 0;

    for (initial..base) |testNum| {
        // std.debug.print("testNum: {d}\n", .{testNum});
        var result: u64 = 0;
        for (0..numParts) |_| {
            result *= base;
            result += testNum;
        }
        if (result > range.end) break;
        if (result >= range.start) {
            // std.debug.print("Id: {d}\n", .{result});
            total += result;
        }
    }

    return total;
}
