const std = @import("std");
const ArrayList = @import("std.array_list.Aligned");
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

const Coordinate = i18;
const Num = i64;
const Point = packed struct {
    x: Coordinate,
    y: Coordinate,
    z: Coordinate,

    fn distance_squared(self: Point, other: Point) Num {
        const dx: Num = self.x - other.x;
        const dy: Num = self.y - other.y;
        const dz: Num = self.z - other.z;
        return dx * dx + dy * dy + dz * dz;
    }
};

const PointList = std.array_list.Aligned(Point, null);
const CircuitPair = packed struct {
    i: usize,
    j: usize,
};

pub fn Heap(comptime Key: type, comptime Val: type) type {
    const HeapEntry = struct {
        key: Key,
        val: Val,
    };

    return struct {
        const Self = @This();
        const List = std.array_list.Aligned(HeapEntry, null);

        // the root of the heap is the largest of the mins
        data: List,

        fn init(alloc: std.mem.Allocator, capacity: usize) !Self {
            return .{
                .data = try List.initCapacity(alloc, capacity),
            };
        }
        fn deinit(self: *Self, gpa: std.mem.Allocator) void {
            self.data.deinit(gpa);
        }

        fn insert(self: *Self, key: Key, value: Val) !void {
            const pair = HeapEntry{ .key = key, .val = value };
            // room for more: append to end
            if (self.data.capacity > self.data.items.len) {
                self.data.appendAssumeCapacity(pair);
                self._trickle_down();
            }
            // less than the greatest -> Replace the root
            else if (pair.key < self.data.items[0].key) {
                self.data.items[0] = pair;
                self._trickle_up();
            }
        }

        fn _trickle_down(self: *Self) void {
            var k = self.data.items.len - 1;
            var temp: HeapEntry = undefined;
            while (k > 0) {
                const next = (k - 1) / 2;
                const a = self.data.items[k];
                const b = self.data.items[next];
                if (a.key > b.key) {
                    // swap
                    temp = self.data.items[k];
                    self.data.items[k] = self.data.items[next];
                    self.data.items[next] = temp;
                } else {
                    break;
                }
                k = next;
            }
        }
        fn _trickle_up(self: *Self) void {
            var k: usize = 0;

            var temp: HeapEntry = undefined;
            while (true) {
                const left = 2 * k + 1;
                const right = 2 * k + 2;
                if (left >= self.data.items.len) {
                    break;
                }
                // compare and swap left
                if (right == self.data.items.len or self.data.items[left].key > self.data.items[right].key) {
                    const a = self.data.items[k];
                    const b = self.data.items[left];
                    if (a.key < b.key) {
                        // swap
                        temp = self.data.items[k];
                        self.data.items[k] = self.data.items[left];
                        self.data.items[left] = temp;
                        k = left;
                    } else {
                        break;
                    }
                }

                // compare and swap right
                else {
                    const a = self.data.items[k];
                    const b = self.data.items[right];
                    if (a.key < b.key) {
                        // swap
                        temp = self.data.items[k];
                        self.data.items[k] = self.data.items[right];
                        self.data.items[right] = temp;
                        k = right;
                    } else {
                        break;
                    }
                }
            }
        }

        fn debug_print(self: *const Self) void {
            std.debug.print("\n", .{});
            var i: usize = 0;
            var powerOfTwo: usize = 2;
            while (i < self.data.items.len) {
                if (i == powerOfTwo - 1) {
                    std.debug.print("\n", .{});
                    powerOfTwo *= 2;
                }

                std.debug.print("{d} ", .{self.data.items[i].key});
                i += 1;
            }

            std.debug.print("\n", .{});
        }
    };
}

// a hash set
const Circuit = std.hash_map.AutoHashMap(usize, void);
const CircuitList = std.array_list.Aligned(Circuit, null);
const CircuitLookup = std.hash_map.AutoHashMap(usize, *Circuit);

const Circuits = struct {
    alloc: std.mem.Allocator,
    // single elements don't get a circuit
    list: CircuitList,
    lookup: CircuitLookup,

    fn init(alloc: std.mem.Allocator) !Circuits {
        return .{
            .alloc = alloc,
            .list = try CircuitList.initCapacity(alloc, 100),
            .lookup = CircuitLookup.init(alloc),
        };
    }

    fn free(self: *Circuits) void {
        for (0..self.list.items.len) |i| {
            self.list.items[i].deinit();
        }
        self.list.deinit(self.alloc);
        self.lookup.clearAndFree();
    }

    fn link_circuits(self: *Circuits, i: usize, j: usize) !void {
        const a = self.lookup.get(i);
        const b = self.lookup.get(j);
        // create a new set
        if (a == null and b == null) {
            var set = Circuit.init(self.alloc);
            try set.put(i, {});
            try set.put(j, {});
            try self.list.append(self.alloc, set);
            try self.lookup.put(i, &set);
            try self.lookup.put(j, &set);
            // merge sets
        } else if (a != null and b != null and a != b) {
            var iter = a.?.keyIterator();
            while (iter.next()) |key| {
                try b.?.put(key.*, {});
                try self.lookup.put(key.*, b.?);
            }
            // a is now empty, (but not null)
            // every lookup pointing to it should be pointing to b now
            a.?.clearRetainingCapacity();
            // insert singleton into existing
        } else if (b) |set| {
            try set.put(i, {});
            try self.lookup.put(i, set);
            // insert singleton into existing
        } else if (a) |set| {
            try set.put(j, {});
            try self.lookup.put(j, set);
        }
    }
};

fn solve(init: std.process.Init, file: std.Io.File, part: Part) !u64 {
    _ = part;
    var points = try parse_file(init, file);
    defer points.deinit(init.gpa);

    var pairs = try Heap(isize, CircuitPair).init(init.gpa, 1000);
    defer pairs.deinit(init.gpa);
    _ = &pairs;
    const n = points.items.len;
    for (0..n) |i| {
        for (i + 1..n) |j| {
            const d = points.items[i].distance_squared(points.items[j]);
            try pairs.insert(d, CircuitPair{ .i = i, .j = j });
        }
    }

    var circuits = try Circuits.init(init.gpa);
    defer circuits.free();
    for (pairs.data.items) |pair| {
        try circuits.link_circuits(pair.val.i, pair.val.j);
    }

    var circuit_heap = try Heap(usize, usize).init(init.gpa, 3);
    for (circuits.list.items) |circuit| {
        const len: usize = circuit.count();
        std.debug.print("{d}\n", .{len});
        try circuit_heap.insert(std.math.maxInt(usize) - len, len);
    }
    defer circuit_heap.deinit(init.gpa);

    const items = circuit_heap.data.items;

    std.debug.print("{any}\n", .{items});
    const result = items[0].val * items[1].val * items[2].val;
    std.debug.print("{d}\n", .{result});
    return result;
}

fn parse_int(buffer: ?[]const u8) !Coordinate {
    return try std.fmt.parseInt(Coordinate, buffer orelse return error.MissingArg, 10);
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
