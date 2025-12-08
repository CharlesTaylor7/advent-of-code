const std = @import("std");
const AocError = error{ NotImplemented, InvalidPart, MissingArg, InvalidRange };
const Part = enum { one, two };
const Args = struct { part: Part, filename: []const u8 };
const Context = struct {
    alloc: std.mem.Allocator,
    input: []u8,
};
const Range = struct {
    start: []u8,
    end: []u8,
};

pub fn main() !void {
    const args = try parse_args();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    const cwd = std.fs.cwd();

    const fileContents = try cwd.readFileAlloc(alloc, args.filename, 100000);
    defer alloc.free(fileContents);

    const context = Context{ .alloc = alloc, .input = fileContents };
    const answer = try switch (args.part) {
        Part.one => part1(context),
        Part.two => part2(context),
    };
    std.debug.print("{d}\n", .{answer});
}

fn parse_args() !Args {
    var args = std.process.args();
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
// brute force way:
// iterate over every id and sum up the invalid ones
//
// other way:
// smarter iteration. leap over odd number of digits
// iterate over the first "half" of each sequence of digits
//
pub fn part1(context: Context) !u64 {
    var ranges = std.mem.tokenizeAny(u8, context.input, ",\n");
    var total: u64 = 0;
    total += 0;

    var scratch_1 = [12]u8{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    var scratch_2 = [12]u8{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };

    while (ranges.next()) |range| {
        if (range.len == 0) break;
        var iter = std.mem.splitScalar(u8, range, '-');

        var start = iter.next() orelse return AocError.InvalidRange;
        var end = iter.next() orelse return AocError.InvalidRange;

        if (start.len % 2 == 1) {
            var slice = scratch_1[0 .. start.len + 1];
            slice[0] = toDigit(1);
            for (0..start.len) |i| {
                slice[i + 1] = toDigit(0);
            }
            start = slice;
        }

        if (end.len % 2 == 1) {
            var slice = scratch_2[0 .. end.len - 1];
            for (0..end.len - 1) |i| {
                slice[i] = toDigit(9);
            }
            end = slice;
        }

        if (start.len > end.len) continue;
        if (start.len < end.len) return AocError.NotImplemented;

        const n = start.len / 2;
        const a = try std.fmt.parseInt(u32, start[0..n], 10);

        const b = try std.fmt.parseInt(u32, start[n..], 10);
        const c = try std.fmt.parseInt(u32, end[0..n], 10);
        const d = try std.fmt.parseInt(u32, end[n..], 10);

        for (a..c + 1) |i| {
            if (i == a and a < b) continue;
            if (i == c and c > d) continue;
            const id: u64 = i + i * (std.math.pow(u64, 10, n));
            total += id;
        }
    }
    return total;
}

fn toDigit(digit: comptime_int) u8 {
    if (digit < 0) return undefined;
    if (digit > 9) return undefined;
    return digit + 48;
}

pub fn part2(context: Context) !u64 {
    var ranges = std.mem.tokenizeAny(u8, context.input, ",\n");
    var total: u64 = 0;
    total += 0;

    while (ranges.next()) |range| {
        if (range.len == 0) break;
        var iter = std.mem.splitScalar(u8, range, '-');

        const start = iter.next() orelse return AocError.InvalidRange;
        const end = iter.next() orelse return AocError.InvalidRange;
        const a = try std.fmt.parseInt(u64, start, 10);
        const b = try std.fmt.parseInt(u64, end, 10);
        var ids = std.array_list.Aligned(u64).initCapacity(context.alloc, 4);
        defer ids.deinit();

        std.debug.print("{d} {d}\n", .{ a, b });

        for (2..end.len + 1) |r| {
            std.debug.print(r);
        }
        // for (a..c + 1) |i| {
        //     if (i == a and a < b) continue;
        //     if (i == c and c > d) continue;
        //     const id: u64 = i + i * (std.math.pow(u64, 10, n));
        //     total += id;
        // }
    }
    return total;
}
