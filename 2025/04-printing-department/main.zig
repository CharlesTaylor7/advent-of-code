const std = @import("std");
const AocError = error{ NotImplemented, InvalidPart, MissingArg };
const Part = enum { one, two };
const Args = struct { part: Part, filename: []const u8 };

pub fn main(init: std.process.Init) !void {
    const args = try parse_args(init.minimal.args);

    const cwd = std.Io.Dir.cwd();

    const fileContents = try cwd.readFileAlloc(init.io, args.filename, init.gpa, .unlimited);
    defer init.gpa.free(fileContents);

    const answer = try switch (args.part) {
        Part.one => part1(fileContents),
        Part.two => part2(fileContents),
    };
    std.debug.print("{d}\n", .{answer});
}

fn parse_args(passedArgs: std.process.Args) AocError!Args {
    var args = passedArgs.iterate();
    _ = args.skip();
    const filename = args.next() orelse return error.MissingArg;
    const rawPart = args.next() orelse return error.MissingArg;
    const part = try parse_part(rawPart);
    return .{ .part = part, .filename = filename };
}

fn parse_part(arg: []const u8) AocError!Part {
    const part = std.fmt.parseInt(u8, arg, 10) catch return AocError.InvalidPart;
    if (part == 1) return Part.one;
    if (part == 2) return Part.two;
    return AocError.InvalidPart;
}

pub fn part1(fileContents: []const u8) !u64 {
    var rows = std.mem.splitScalar(u8, fileContents, '\n');
    var prev: ?[]const u8 = null;
    var current: ?[]const u8 = null;
    var next: ?[]const u8 = null;
    while (rows.next()) |row| {
        current = row;

        // check 
        _ = row
    }

    return AocError.NotImplemented;
}

pub fn part2(fileContents: []const u8) !u64 {
    _ = fileContents;
    return AocError.NotImplemented;
}
