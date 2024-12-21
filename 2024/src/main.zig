const std = @import("std");

const day01 = @import("day_01.zig");
const day02 = @import("day_02.zig");
const day03 = @import("day_03.zig");

const FunctionType = ?*const fn () void;

// Define a mapping from string to function
const DayEntry = struct {
    name: []const u8,
    func: FunctionType,
};

const day_table = [_]DayEntry{
    .{ .name = "day01", .func = &day01.run },
    .{ .name = "day02", .func = &day02.run },
    .{ .name = "day03", .func = &day03.run },
};

pub fn main() !void {
    const args = std.process.argsAlloc(std.heap.page_allocator) catch |err| {
        std.debug.print("Failed to allocate args: {any}\n", .{err});
        return;
    };
    defer std.process.argsFree(std.heap.page_allocator, args);

    // Check if the --day flag is provided
    var day_arg: ?[]const u8 = null;
    var i: usize = 0;
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--day")) {
            if (i + 1 < args.len) {
                day_arg = args[i + 1];
                break;
            }
        }
    }

    if (day_arg == null) {
        std.debug.print("Usage: zig build run --day <day_name>\n", .{});
        return;
    }

    const selected_day = day_arg.?;
    const func = lookup_day(selected_day);
    if (func == null) {
        // std.debug.print("Unknown day: {}\n", .{selected_day});
        return;
    }

    func.?();
}

// Helper function to find the appropriate day function
fn lookup_day(day_name: []const u8) FunctionType {
    for (day_table) |entry| {
        if (std.mem.eql(u8, entry.name, day_name)) {
            return entry.func;
        }
    }
    return null; // Day not found
}
