const std = @import("std");
const AocError = error{ NotImplemented, InvalidPart, MissingArg };
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

pub fn solve(init: std.process.Init, file: std.Io.File, part: Part) !usize {
    var total: u64 = 0;
    const buffer = try init.gpa.alloc(u8, 1024);
    defer init.gpa.free(buffer);

    var reader = file.readerStreaming(init.io, buffer);

    while (try reader.interface.takeDelimiter('\n')) |line| {
        const joltage = maxJoltage(line, if (part == Part.one) 2 else 12);
        total += joltage;
    }

    return total;
}

// use the largest digit in the first n-d, in the earliest position
// then the largest digit in a later position.
fn maxJoltage(battery: []const u8, digits: usize) u64 {
    if (battery.len == 0) return 0;
    var joltage: u64 = 0;

    var start: usize = 0;
    var max_d: u64 = 0;

    for (0..digits) |n| {
        const end = battery.len - digits + n + 1;
        for (start..end) |i| {
            // char to digit
            const d = battery[i] - 48;

            if (d > max_d) {
                start = i + 1;
                max_d = d;
            }
            if (max_d == 9) break;
        }
        joltage *= 10;
        joltage += max_d;
        max_d = 0;
    }
    return joltage;
}
