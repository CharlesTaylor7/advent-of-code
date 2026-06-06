const std = @import("std");
const AocError = error{ NotImplemented, InvalidPart, MissingArg };
const Part = enum { one, two };
const Args = struct { part: Part, filename: []const u8 };

pub fn main() !void {
    const args = try parse_args();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    const cwd = std.fs.cwd();

    const fileContents = try cwd.readFileAlloc(alloc, args.filename, 100000);
    defer alloc.free(fileContents);

    const answer = try solve(fileContents, args.part);
    std.debug.print("{d}\n", .{answer});
}

fn parse_args() !Args {
    var args = std.process.args();
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

pub fn solve(fileContents: []const u8, part: Part) !usize {
    var total: u64 = 0;
    var rows = std.mem.splitScalar(u8, fileContents, '\n');
    while (rows.next()) |row| {
        std.debug.print("{s}\n", .{row});
        const joltage = maxJoltage(row, if (part == Part.one) 2 else 12);
        std.debug.print("{d}\n", .{joltage});
        total += joltage;
    }

    return total;
}

// use the largest digit in the first n-d, in the earliest position
// then the largest digit in a later position.
fn maxJoltage(battery: []const u8, digits: usize) u64 {
    if (battery.len == 0) return 0;
    var tally: u64 = 0;

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
        const exponent = digits - n - 1;
        tally += max_d * pow10(exponent);
        max_d = 0;
    }
    return tally;
}

fn pow10(n: usize) u64 {
    if (n == 0) return 1;
    if (n == 1) return 10;

    if (n % 2 == 0) {
        const m = pow10(n / 2);
        return m * m;
    }
    return 10 * pow10(n - 1);
}
