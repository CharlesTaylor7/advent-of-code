const std = @import("std");

pub fn main() !void {
    // Initiate allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    // Read contents from file "./filename"
    const cwd = std.fs.cwd();
    const fileContents = try cwd.readFileAlloc(alloc, "input.txt", 100000);
    defer alloc.free(fileContents);

    const n = try part2(fileContents);
    std.debug.print("count: {d}\n", .{n});
}

pub fn part1(fileContents: []u8) !u8 {
    var rows = std.mem.splitScalar(u8, fileContents, '\n');
    const size = i32;
    var door: size = 50;
    var count: usize = 0;
    while (rows.next()) |line| {
        if (line.len == 0) break;
        if (line[0] == 'L') {

            const n = std.fmt.parseInt(size, line[1..], 10) catch |err| {

                std.debug.print("{s}\n", .{line});
                return err;
            };

            std.debug.print("left {d}\n", .{n});
            door -= n;
            while (door < 0) { door += 100; }
        }

        if (line[0] == 'R') {
            const n = try std.fmt.parseInt(size, line[1..], 10);
            std.debug.print("right {d}\n", .{n});

            door += n;
            while (door >= 100) { door -= 100; }
        }


        std.debug.print("door: {d}\n", .{door});
        if (door == 0) { count += 1; }

    }
    return count;
}
const InvalidFileError = error{ BadDirection };

pub fn part2(fileContents: []u8) !usize {
    var rows = std.mem.splitScalar(u8, fileContents, '\n');
    const size = i32;
    var door: size = 50;
    var count: usize = 0;

    std.debug.print("door: {d}\n", .{door});
    while (rows.next()) |line| {
        if (line.len == 0) break;

        std.debug.print("{s}\n", .{line});
        const n = try std.fmt.parseInt(size, line[1..], 10) ;
        const sign: size = if (line[0] == 'L' )  -1 else if (line[0] == 'R')  1  else return InvalidFileError.BadDirection;

        const startedAtZero = door == 0;
        if (sign == -1) {
            door -= n;
            while (door < 0) {
                door += 100;
                count += 1;
                std.debug.print("click\n", .{});
            }
            if (door == 0) {
                count += 1;
                std.debug.print("click\n", .{});
            }
            if (startedAtZero) {
                count -= 1;
                std.debug.print("unclick\n", .{});
            }
        }
        if (sign == 1) {
            door += n;
            while (door >= 100) {
                door -= 100;
                count += 1;
                std.debug.print("click\n", .{});
            }
        }

        std.debug.print("door: {d}\n", .{door});

    }
    return count;
}
