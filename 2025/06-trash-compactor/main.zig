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
    var total: u64 = 0;
    var numbers = try std.array_list.Aligned(u32, null).initCapacity(init.gpa, 100);
    defer numbers.deinit(init.gpa);

    {
        const buffer = try init.gpa.alloc(u8, 1024);
        defer init.gpa.free(buffer);
        defer file.close(init.io);

        var reader = file.reader(init.io, buffer);
        var cols: usize = 0;
        var rows: usize = 0;
        var first = true;

        while (try reader.interface.takeDelimiter('\n')) |line| {
            if (line[0] == '*' or line[0] == '+') {
                var i = 0;
                for (std.mem.splitScalar(u8, line, ' ')) |op| {
                    switch (op) {
                        '+' => {
                            for (0..rows) |j| {
                                total += numbers.items[i + j * cols];
                            }
                        },
                        '*' => {
                            var product: u64 = 1;
                            for (0..rows) |j| {
                                product *= numbers.items[i + j * cols];
                            }
                            total += product;
                        },
                        else => return error.InvalidOperator,
                    }
                    i += 1;
                }
            } else {
                rows += 1;

                for (std.mem.splitScalar(u8, line, ' ')) |num| {
                    numbers.append(init.gpa, try std.fmt.parseInt(num));
                    if (first) cols += 1;
                }
                first = false;
            }
        }
    }
    return total;
}
