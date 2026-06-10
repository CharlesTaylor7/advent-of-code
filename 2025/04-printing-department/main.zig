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

// -- TYPES --
const Window = []Tile;
const Tile = enum(u1) { blank, paper };
const TILES = .{ .blank = '.', .paper = '@' };
const Context = struct {
    removed: u8,
    grid: []Tile,
    counts: []i8,
    rows: usize,
    cols: usize,
};

// I don't see a way to do this streaming. I think we have to load the entire file
// I think we can still stream this, and optimize out stuff.
// let's get it working first though.
fn part2(init: std.process.Init, file: std.Io.File) !u64 {
    // overcounts a newline per row. but this is roughly the right size.
    const stat = try file.stat(init.io);
    const grid = try init.gpa.alloc(Tile, stat.size);
    defer init.gpa.free(grid);

    var rows: usize = 0;
    var cols: usize = 0;

    {
        const buffer = try init.gpa.alloc(u8, 1024);
        defer init.gpa.free(buffer);

        var reader = file.reader(init.io, buffer);

        while (try reader.interface.takeDelimiter('\n')) |line| {
            rows += 1;
            if (rows == 1) {
                cols = line.len;
            } else if (cols != line.len) {
                return error.UnevenLineLength;
            }

            for (0..cols) |i| {
                const tile = switch (line[i]) {
                    TILES.blank => Tile.blank,
                    TILES.paper => Tile.paper,
                    else => return error.InvalidTile,
                };
                grid[i] = tile;
            }
        }
    }
    // file no longer needed
    file.close(init.io);

    const size = rows * cols;
    const counts = try init.gpa.alloc(i8, size);
    defer init.gpa.free(counts);

    var context = Context{
        .counts = counts,
        .grid = grid[0..size],
        .rows = rows,
        .cols = cols,
        .removed = 0,
    };

    part2_loop(&context);

    return context.removed;
}

// updates grid in loop until it "settles"
fn part2_loop(context: *Context) void {
    // first pass
    for (0..context.cols) |i| {
        for (0..context.rows) |j| {
            const index = i + j * context.cols;
            if (context.grid[index] == .paper) {
                for (0..3) |dx| {
                    for (0..3) |dy| {
                        if (dx == 1 and dy == 1) continue;
                        if (i == 0 and dx == 0) continue;
                        if (j == 0 and dy == 0) continue;
                        if (context.grid[index + dx - 1 + (dy - 1) * context.cols] == .paper) {
                            context.counts[index] += 1;
                        }
                    }
                }
            }
        }
    }

    var settled = true;
    while (!settled) {
        for (0..context.cols) |i| {
            for (0..context.rows) |j| {
                const index = i + j * context.cols;
                if (context.grid[index] == .paper and context.counts[index] < 4) {
                    settled = false;
                    context.removed += 1;
                    context.grid[index] = .blank;

                    // drop all surrounding
                    for (0..3) |dx| {
                        for (0..3) |dy| {
                            if (dx == 1 and dy == 1) continue;
                            if (i == 0 and dx == 0) continue;
                            if (j == 0 and dy == 0) continue;
                            context.counts[index + dx - 1 + (dy - 1) * context.cols] -= 1;
                        }
                    }
                }
            }
        }
    }
}

fn part1(init: std.process.Init, file: std.Io.File) !u64 {
    const buffer = try init.gpa.alloc(u8, 1024);
    defer init.gpa.free(buffer);

    // stream a window of 3 lines at a time.
    var reader = file.reader(init.io, buffer);

    if (try reader.interface.takeDelimiter('\n')) |first| {
        const n = first.len;
        const window = try init.gpa.alloc(Tile, 3 * n);
        defer init.gpa.free(window);

        for (0..n) |i| {
            const tile = switch (first[i]) {
                TILES.blank => Tile.blank,
                TILES.paper => Tile.paper,
                else => return error.InvalidTile,
            };
            window[i] = tile;
        }

        var j: u8 = 0;
        var count: u64 = 0;
        while (try reader.interface.takeDelimiter('\n')) |line| {
            j += 1;
            const offset = (j % 3) * n;
            for (0..n) |i| {
                const tile = switch (line[i]) {
                    TILES.blank => Tile.blank,
                    TILES.paper => Tile.paper,
                    else => return error.InvalidTile,
                };
                window[offset + i] = tile;
            }

            // figure out the counts for the preceding, because it has all the context it needs.

            const prev = if (j == 1) null else sliceWindow(window, j - 2, n);
            const current = sliceWindow(window, j - 1, n);

            const next = sliceWindow(window, j, n);
            count += countRow(prev, current, next, n);
        }

        file.close(init.io);

        count += countRow(sliceWindow(window, j - 1, n), sliceWindow(window, j, n), null, n);
        return count;
    }
    return error.EmptyFile;
}

fn sliceWindow(window: Window, i: u8, n: usize) Window {
    const start = (i % 3) * n;
    return window[start .. start + n];
}

fn countRow(prev: ?Window, current: Window, next: ?Window, n: usize) u64 {
    var count: u64 = 0;
    for (0..n) |i| {
        var cellCount: u64 = 0;

        if (current[i] != Tile.paper) {
            std.debug.print(".", .{});
            continue;
        }

        if (prev) |row| {

            // safe to count preceding row
            if (i > 0 and row[i - 1] == Tile.paper) {
                cellCount += 1;
            }

            if (row[i] == Tile.paper) {
                cellCount += 1;
            }

            if (i < n - 1 and row[i + 1] == Tile.paper) {
                cellCount += 1;
            }
        }
        // count current row
        if (i > 0 and current[i - 1] == Tile.paper) {
            cellCount += 1;
        }

        if (i < n - 1 and current[i + 1] == Tile.paper) {
            cellCount += 1;
        }

        if (next) |row| {
            // safe to count following row

            // safe to count preceding row
            if (i > 0 and row[i - 1] == Tile.paper) {
                cellCount += 1;
            }

            if (row[i] == Tile.paper) {
                cellCount += 1;
            }

            if (i < n - 1 and row[i + 1] == Tile.paper) {
                cellCount += 1;
            }
        }
        if (cellCount < 4) {
            std.debug.print("x", .{});
            count += 1;
        } else {
            std.debug.print("@", .{});
        }
    }

    std.debug.print("\n", .{});
    return count;
}
