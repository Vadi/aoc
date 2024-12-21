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

fn hasNotIncreasingAndDescreasing(levelsList: *std.ArrayList(u32)) bool {
    var increasing = true;
    var decreasing = true;

    for (levelsList.items[0 .. levelsList.items.len - 1], levelsList.items[1..]) |curr, next| {
        const diff = if (next > curr) next - curr else curr - next;
        const valid_diff = diff >= 1 and diff <= 3;

        if (curr >= next or !valid_diff) increasing = false;
        if (curr <= next or !valid_diff) decreasing = false;

        if (!increasing and !decreasing) {
            return true;
        }
    }

    return false;
}

pub fn run() void {
    // const input_file = "unsafe.txt";
    const input_file = "resources/day_02_input.txt";
    const allocator = std.heap.page_allocator;

    var safeCounter: u32 = 0;
    var unsafeCounter: u32 = 0;
    // var partTwoSafeCounter: u32 = 0;

    const content = readFile(allocator, input_file) catch |err| {
        std.debug.print("Error while reading the file - {any}", .{err});
        return;
    };
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
                const value = std.fmt.parseInt(u32, trimmedValue, 10) catch unreachable;
                levelsList.append(value) catch unreachable;
            }

            const res0 = hasNotIncreasingAndDescreasing(&levelsList);
            const outcome = if (res0) "U" else "S";

            for (levelsList.items) |item| {
                std.debug.print("{d} ", .{item});
            }
            std.debug.print("= {s} \n", .{outcome});

            start = i + 1;

            if (std.mem.eql(u8, outcome, "S")) {
                safeCounter = safeCounter + 1;
            }

            if (std.mem.eql(u8, outcome, "U")) {
                const original_items = levelsList.items;
                for (original_items, 0..) |_, remove_index| {
                    std.debug.print("running for {d}\n", .{remove_index});
                    var filtered_list = std.ArrayList(u32).init(allocator);
                    defer filtered_list.deinit();
                    for (original_items, 0..) |item, original_index| {
                        std.debug.print("running for {d} and {d}\n", .{ remove_index, original_index });
                        if (original_index != remove_index) {
                            filtered_list.append(item) catch unreachable;
                        }
                    }

                    const res = hasNotIncreasingAndDescreasing(&filtered_list);
                    const second_attempt = if (res) "U" else "S";

                    for (filtered_list.items) |f| {
                        std.debug.print("{d}", .{f});
                    }

                    std.debug.print("= {s}\n", .{second_attempt});

                    if (std.mem.eql(u8, second_attempt, "S")) {
                        safeCounter = safeCounter + 1;
                        std.debug.print("Counting second time\n", .{});
                        break;
                    }
                }
                unsafeCounter = unsafeCounter + 1;
            }
        }
    }

    std.debug.print("Safe levels are {d}\n", .{safeCounter});
    std.debug.print("Unsafe levels are {d}\n", .{unsafeCounter});
}
