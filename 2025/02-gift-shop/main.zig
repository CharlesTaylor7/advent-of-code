const std = @import("std");
const AocError = error{ NotImplemented, InvalidPart, MissingArg, InvalidRange };
const Part = enum { one, two };
const Args = struct { part: Part, filename: []const u8 };

const Range = struct {
    start: []u8,
    end: []u8,
};

pub fn main(init: std.process.Init) !void {
    const args = try parse_args(init.minimal.args);

    const file = try std.Io.Dir.cwd().openFile(init.io, args.filename, .{});
    const answer = try switch (args.part) {
        Part.one => part1(init, file),
        Part.two => part2(init, file),
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

// leap over odd number of digits
//
// take the first n/2 digits and iterate those and see if they fall in the range.
pub fn part1(init: std.process.Init, file: std.Io.File) !u64 {
    var total: u64 = 0;
    const buffer = try init.gpa.alloc(u8, 1024);
    defer init.gpa.free(buffer);

    var reader = file.reader(init.io, buffer);
    while (try reader.interface.takeDelimiter(',')) |range| {
        var parts = std.mem.tokenizeScalar(u8, range, '-');
        const start = parts.next() orelse return AocError.InvalidRange;
        const end = parts.next() orelse return AocError.InvalidRange;

        // assume start and end have close to the same number of digits
        //
        if (start.len > end.len) return AocError.InvalidRange;
        if (start.len % 2 == 1 and end.len % 2 == 1) continue;

        const a = start[0 .. start.len / 2];
        const b = start[start.len / 2 ..];
        const c = end[0 .. end.len / 2];
        const d = end[end.len / 2 ..];
        std.debug.print("{s} {s} - {s} {s}\n", .{ a, b, c, d });
    }
    total += 0;
    return total;
}

// TODO:
pub fn part2(init: std.process.Init, file: std.Io.File) !u64 {
    _ = init;
    _ = file;
    return 42;
}
