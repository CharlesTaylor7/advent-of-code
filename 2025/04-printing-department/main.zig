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
    _ = part;

    const buffer = try init.gpa.alloc(u8, 1024);
    defer init.gpa.free(buffer);

    // stream a window of 3 lines at a time.
    var reader = file.reader(init.io, buffer);

    if (try reader.interface.takeDelimiter('\n')) |first| {
        const n = first.len;
        // insight: compress the window by parsing to an enum/bool first
        const window = try init.gpa.alloc(u8, 3 * n);
        defer init.gpa.free(window);

        @memcpy(window[0..n], first);

        var i: u8 = 0;
        var count: u64 = 0;
        while (try reader.interface.takeDelimiter('\n')) |line| {
            i += 1;
            const offset = (i % 3) * n;
            @memcpy(window[offset .. offset + n], line);

            // figure out the counts for the preceding, because it has all the context it needs.

            const prev = if (i == 1) null else sliceWindow(window, i - 2, n);
            const current = sliceWindow(window, i - 1, n);

            const next = sliceWindow(window, i, n);
            count += countRow(prev, current, next, n);
        }

        count += countRow(sliceWindow(window, i - 1, n), sliceWindow(window, i, n), null, n);
        return count;
    }
    return error.EmptyFile;
}

fn sliceWindow(window: []u8, i: u8, n: usize) []u8 {
    const start = (i % 3) * n;
    return window[start .. start + n];
}

const PAPER = '@';
const BLANK = '.';
const Location = enum { Initial, Middle, Final };
fn countRow(prev: ?[]u8, current: []u8, next: ?[]u8, n: usize) u64 {
    var count: u64 = 0;
    for (0..n) |i| {
        var cellCount: u64 = 0;

        if (current[i] != PAPER) {
            std.debug.print(".", .{});
            continue;
        }

        if (prev) |row| {

            // safe to count preceding row
            if (i > 0 and row[i - 1] == PAPER) {
                cellCount += 1;
            }

            if (row[i] == PAPER) {
                cellCount += 1;
            }

            if (i < n - 1 and row[i + 1] == PAPER) {
                cellCount += 1;
            }
        }
        // count current row
        if (i > 0 and current[i - 1] == PAPER) {
            cellCount += 1;
        }

        if (i < n - 1 and current[i + 1] == PAPER) {
            cellCount += 1;
        }

        if (next) |row| {
            // safe to count following row

            // safe to count preceding row
            if (i > 0 and row[i - 1] == PAPER) {
                cellCount += 1;
            }

            if (row[i] == PAPER) {
                cellCount += 1;
            }

            if (i < n - 1 and row[i + 1] == PAPER) {
                cellCount += 1;
            }
        }
        if (cellCount < 4) {
            std.debug.print("x", .{});
            count += 1;
        } else {
            std.debug.print("{c}", .{current[i]});
        }
    }

    std.debug.print("\n", .{});
    return count;
}
