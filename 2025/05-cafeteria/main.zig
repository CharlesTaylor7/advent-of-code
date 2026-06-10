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

const Range = struct {
    start: u64,
    end: u64,
};
const FileSection = enum {
    ranges,
    ingredients,
};

fn solve(init: std.process.Init, file: std.Io.File, part: Part) !u64 {
    _ = part;

    var total: u64 = 0;
    var section = FileSection.ranges;

    var ranges = try std.array_list.Aligned(Range, null).initCapacity(init.gpa, 10);
    defer ranges.deinit(init.gpa);

    {
        const buffer = try init.gpa.alloc(u8, 1024);
        defer init.gpa.free(buffer);
        defer file.close(init.io);

        var reader = file.reader(init.io, buffer);

        while (try reader.interface.takeDelimiter('\n')) |line| {
            switch (section) {
                .ranges => {
                    if (line.len == 0) {
                        section = .ingredients;
                        continue;
                    }
                    var iter = std.mem.splitScalar(u8, line, '-');
                    const start = iter.next() orelse return error.InvalidRange;
                    const end = iter.next() orelse return error.InvalidRange;
                    const range =
                        Range{
                            .start = try std.fmt.parseInt(u64, start, 10),
                            .end = try std.fmt.parseInt(u64, end, 10),
                        };
                    try ranges.append(init.gpa, range);
                },
                .ingredients => {
                    const ingredient = try std.fmt.parseInt(u64, line, 10);

                    // std.debug.print("{d}\n", .{ingredient});
                    for (ranges.items) |range| {
                        if (ingredient >= range.start and ingredient <= range.end) {
                            // std.debug.print("range: {d}-{d}\n", .{ range.start, range.end });
                            total += 1;
                            break;
                        }
                    }
                },
            }
        }
    }
    return total;
}
