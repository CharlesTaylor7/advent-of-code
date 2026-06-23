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

fn solve(init: std.process.Init, file: std.Io.File, part: Part) !u64 {
    return switch (part) {
        .one => part1(init, file),
        .two => part2(init, file),
    };
}

// brute force let's go!
// alright we need to do aggressive caching and dynamic programming
// basically if you already fit the shapes and you add a row, you're good.
// if you add a shape, you need to try all the existing configurations right?
// I am going to try to work for the solution because that will enhance my enjoyment of it.
//
// the search space is freaking massive.
//
// Adding a new piece means checking very previously working configuration again...
//
// one idea is to just place the "easy" pieces first.
// Another is to exclude all the grids that would be too large
// another is to see which pieces fit togeht
fn part1(init: std.process.Init, file: std.Io.File) !u64 {
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

const Shape = struct {
    fn shift(self: @This()) void {
            _ = self;
            //
        }
    };

    fn rotate(self: @This()) void {
        _ = self;
        //
    }
};

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
