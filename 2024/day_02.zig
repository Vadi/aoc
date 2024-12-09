// Day 2: Red-nosed Reports
//
// Important facts:
//
// - Each report is a list of numbers called **levels** that are separated by spaces.
// - The engineers are trying to figure out which reports are safe.
// - The safety systems can only tolerate levels that are either gradually increasing or decreasing.
// - A report only counts as SAFE if both of the following are true -
//      a) levels are either all increasing or all decreasing
//      b) Any two adjacent levels differ by at least one and at most three.
//
//
// There's also part two in this one after submitting answer for the first one
//
// - What is the SAFE reports count if atleast one UNSAFE level is removed.
//
const std = @import("std");

// We will use an enum to count safe and unsafe outcomes, not sure
// we need neither. We will keep it for now.
const Outcome = enum { safe, unsafe, neither };

fn readFile(allocator: std.mem.Allocator, filename: []const u8) ![]const u8 {
    const cwd = std.fs.cwd();
    const file_metadata = try cwd.statFile(filename);
    const file_size = file_metadata.size;

    return try cwd.readFileAlloc(allocator, filename, file_size);
}

pub fn main() !void {
    const input_file = "day_02_input.txt";
    const allocator = std.heap.page_allocator;

    var safeCounter: u32 = 0;

    const content = try readFile(allocator, input_file);
    defer allocator.free(content);

    var start: usize = 0;
    for (content, 0..) |c, i| {
        if (c == '\n') {
            const line = content[start..i];
            var levelsList = std.ArrayList(u32).init(allocator);
            defer levelsList.deinit();
            var levelsString = std.mem.splitSequence(u8, line, " ");
            while (levelsString.next()) |level| {
                const trimmedValue = std.mem.trim(u8, level, " ");
                const value = try std.fmt.parseInt(u32, trimmedValue, 10);
                try levelsList.append(value);
            }

            var increasing = true;
            var decreasing = true;

            for (levelsList.items[0 .. levelsList.items.len - 1], levelsList.items[1..]) |curr, next| {
                std.debug.print("{d} - {d}\n", .{ curr, next });
                const diff = if (next > curr) next - curr else curr - next;
                const valid_diff = diff >= 1 and diff <= 3;

                if (curr >= next or !valid_diff) increasing = false;
                if (curr <= next or !valid_diff) decreasing = false;

                if (!increasing and !decreasing) break;
            }

            var outcome = "S";

            if (increasing or decreasing) outcome = "S" else outcome = "U";

            for (levelsList.items) |item| {
                std.debug.print("{d} ", .{item});
            }
            std.debug.print("= {s} \n", .{outcome});
            start = i + 1;

            if (std.mem.eql(u8, outcome, "S")) safeCounter = safeCounter + 1;
        }
    }

    std.debug.print("Safe levels are {d}", .{safeCounter});
}
