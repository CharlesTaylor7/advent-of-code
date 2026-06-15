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

// n*(n-1) / 2 pairs... iterate the pairs and calculcate pair wise differences.
// then sort the differences and start merging into circuits
// multiply the size of the three largest circuits
//
// (1) parse the file into an array
// (2) build another array of distances and pairs and sort them.
// (3) perform merges by using an array of lists?
// (4) sort again
// (5) output final product
//
// can optimize by using an incremental sort instead of a full sort.
// "selection algorithms" on wikipedia.
// heap select works
//
// heap select on 1000 pairs
// then heap select on the 3 circuits

const Coordinate = u10;
const Point = packed struct {
    x: Coordinate,
    y: Coordinate,
    z: Coordinate,

    fn distance_squared(self: Point, other: Point) u32 {
        const dx: u32 = self.x - other.x;
        const dy: u32 = self.y - other.y;
        const dz: u32 = self.z - other.z;
        return dx * dx + dy * dy + dz * dz;
    }
};

const PointList = std.array_list.Aligned(Point, null);
const Pair = packed struct {
    i: usize,
    j: usize,
    dist: u32,
};
const Heap = std.array_list.Aligned(Pair, null);

fn solve(init: std.process.Init, file: std.Io.File, part: Part) !u64 {
    _ = part;
    const points = parse_file(init, file);
    defer points.deinit(init.gpa);

    var pairs = try init.gpa.alloc(Pair, 1000);
    _ = &pairs;
}

fn parse_int(buffer: ?[]u8) !Coordinate {
    return try std.fmt.parseInt(Coordinate, buffer orelse error.MissingArg, 10);
}

fn parse_file(init: std.process.Init, file: std.Io.File) !PointList {
    var points = try PointList.initCapacity(init.gpa, 10);
    {
        const buffer = try init.gpa.alloc(u8, 1024);
        defer init.gpa.free(buffer);
        defer file.close(init.io);

        var reader = file.reader(init.io, buffer);
        while (try reader.interface.takeDelimiter('\n')) |line| {
            var iter = std.mem.splitScalar(u8, line, ',');
            const point = Point{
                .x = try parse_int(iter.next()),
                .y = try parse_int(iter.next()),
                .z = try parse_int(iter.next()),
            };
            try points.append(init.gpa, point);
        }
    }

    return points;
}
