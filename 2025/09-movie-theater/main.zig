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

const Point = struct {
    x: u64,
    y: u64,

    pub fn format(self: Point, writer: anytype) !void {
        try writer.print("{d},{d}", .{ self.x, self.y });
    }
};

fn solve(init: std.process.Init, file: std.Io.File, part: Part) !u64 {
    _ = part;
    var points = try std.array_list.Aligned(Point, null).initCapacity(init.gpa, 10);
    defer points.deinit(init.gpa);
    {
        const buffer = try init.gpa.alloc(u8, 1024);
        defer init.gpa.free(buffer);
        defer file.close(init.io);

        var reader = file.reader(init.io, buffer);
        while (try reader.interface.takeDelimiter('\n')) |line| {
            var iter = std.mem.splitScalar(u8, line, ',');
            const x = try std.fmt.parseInt(u64, iter.next() orelse return error.missing, 10);
            const y = try std.fmt.parseInt(u64, iter.next() orelse return error.missing, 10);
            const point = Point{ .x = x, .y = y };
            try points.append(init.gpa, point);
        }
    }
    var maxArea: u64 = 0;

    const n = points.items.len;
    for (0..n) |i| {
        for (i + 1..n) |j| {
            const p1 = points.items[i];
            const p2 = points.items[j];
            const dy = (if (p1.y > p2.y) (p1.y - p2.y) else p2.y - p1.y);
            const dx = (if (p1.x > p2.x) (p1.x - p2.x) else p2.x - p1.x);
            const area = (dx + 1) * (dy + 1);
            if (area > maxArea) maxArea = area;
        }
    }
    return maxArea;
}
