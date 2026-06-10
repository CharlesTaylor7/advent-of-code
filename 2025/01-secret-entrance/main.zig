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
    const buffer = try init.gpa.alloc(u8, 1024);
    defer init.gpa.free(buffer);

    var reader = file.reader(init.io, buffer);

    const size = i32;
    var door: size = 50;
    var countPart1: usize = 0;
    var countPart2: usize = 0;
    while (try reader.interface.takeDelimiter('\n')) |line| {
        if (line.len == 0) break;

        if (line.len == 0) break;

        std.debug.print("{s}\n", .{line});
        const n = try std.fmt.parseInt(size, line[1..], 10);
        const sign: size = if (line[0] == 'L') -1 else if (line[0] == 'R') 1 else return InvalidFileError.BadDirection;

        const startedAtZero = door == 0;
        if (sign == -1) {
            door -= n;
            while (door < 0) {
                door += 100;
                countPart2 += 1;
                std.debug.print("click\n", .{});
            }
            if (door == 0) {
                countPart2 += 1;
                std.debug.print("click\n", .{});
            }
            if (startedAtZero) {
                countPart2 -= 1;
                std.debug.print("unclick\n", .{});
            }
        }

        if (sign == 1) {
            door += n;
            while (door >= 100) {
                door -= 100;
                countPart2 += 1;
                std.debug.print("click\n", .{});
            }
        }
        std.debug.print("door: {d}\n", .{door});
        if (door == 0) {
            countPart1 += 1;
        }
    }
    return switch (part) {
        .one => countPart1,
        .two => countPart2,
    };
}
const InvalidFileError = error{BadDirection};
