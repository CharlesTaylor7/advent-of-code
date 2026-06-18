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
const Polygon = std.hash_map.AutoHashMap(Point, void);

fn solve(init: std.process.Init, file: std.Io.File, part: Part) !u64 {
    return switch (part) {
        .one => part1(init, file),
        .two => part2(init, file),
    };
}

// for part 2... we need to figure out the largest rectangle that fits into a given polygon.
// I can just do bounds checking on the two shapes?
// the very lazy approach is to make a very large hash set with the polygon points and enumerate the rectangles points.
// The slightly better is to do some linear algebra? I think we can check inclusion by doing some cross products.
fn part2(init: std.process.Init, file: std.Io.File) !u64 {
    // dumb way massive hash set.
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
    var polygon = Polygon.init(init.gpa);
    defer polygon.deinit();

    const n = points.items.len;
    try put_line(&polygon, points.items[0], points.getLast());
    for (0..n - 1) |i| {
        const p1 = points.items[i];
        const p2 = points.items[i + 1];
        try put_line(&polygon, p1, p2);
    }

    std.debug.print("{d}\n", .{polygon.count()});
    return polygon.count();
}
fn put_line(polygon: *Polygon, p1: Point, p2: Point) !void {
    if (p1.x == p2.x) {
        const x = p1.x;
        if (p1.y < p2.y) {
            for (p1.y..p2.y + 1) |y| {
                try polygon.put(.{ .x = x, .y = y }, {});
            }
        } else {
            for (p2.y..p1.y + 1) |y| {
                try polygon.put(.{ .x = x, .y = y }, {});
            }
        }
    } else {
        const y = p1.y;
        if (p1.x < p2.x) {
            for (p1.x..p2.x + 1) |x| {
                try polygon.put(.{ .x = x, .y = y }, {});
            }
        } else {
            for (p2.x..p1.x + 1) |x| {
                try polygon.put(.{ .x = x, .y = y }, {});
            }
        }
    }
}

fn part1(init: std.process.Init, file: std.Io.File) !u64 {
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
