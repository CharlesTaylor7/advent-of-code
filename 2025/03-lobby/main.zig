const std = @import("std");
const AocError = error{ NotImplemented, InvalidPart, MissingArg };
const Part = enum { one, two };
const Args = struct { part: Part, filename: []const u8 };

pub fn main() !void {
    const args = try parse_args();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    const cwd = std.fs.cwd();

    const fileContents = try cwd.readFileAlloc(alloc, args.filename, 100000);
    defer alloc.free(fileContents);

    const answer = try switch (args.part) {
        Part.one => part1(fileContents),
        Part.two => part2(fileContents),
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

pub fn part1(fileContents: []const u8) !u64 {
    var total: u64 = 0;
    var rows = std.mem.splitScalar(u8, fileContents, '\n');
    while (rows.next()) |row| {
        std.debug.print("{s}\n", .{row});
        var max_d1: u8 = 0;
        var max_d2: u8 = 0;
        var max_i1: usize = 0;
        var max_i2: usize = 0;

        for (0..row.len) |i| {
            const cell = row[i];
            const value = cell - 48;
            if (value > max_d1) {
                max_d2 = max_d1;
                max_i2 = max_i1;
                max_d1 = value;
                max_i1 = i;
                std.debug.print("i: {d} max_d1: {d}\n", .{ i, value });
            } else if (value > max_d2) {
                max_d2 = value;
                max_i2 = i;
                std.debug.print("i: {d} max_d2: {d}\n", .{ i, value });
            }
        }
        const battery = if (max_i1 < max_i2) max_d1 * 10 + max_d2 else max_d2 * 10 + max_d1;
        std.debug.print("battery: {d}\n", .{battery});
        total += battery;
    }

    return total;
}

pub fn part2(fileContents: []const u8) !u64 {
    _ = fileContents;
    return AocError.NotImplemented;
}
