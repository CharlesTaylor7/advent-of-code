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
    _ = fileContents;
    return AocError.NotImplemented;
}

pub fn part2(fileContents: []const u8) !u64 {
    _ = fileContents;
    return AocError.NotImplemented;
}
