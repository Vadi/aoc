// --- Day 3: Mull It Over ---
const std = @import("std");
const Regex = @import("regex").Regex;
const Errors = @import("main.zig").Errors;

pub fn run() void {
    var re = Regex.compile(std.heap.page_allocator, "mul\\(\\d+,\\d+\\)") catch |err| {
        std.debug.print("Regex compilation failed: {}\n", .{err});
        return;
    };
    defer re.deinit();

    const matched = re.partialMatch("mul(12,12)") catch |err| {
        std.debug.print("Regex matching failed: {}\n", .{err});
        return;
    };

    // if not matched ...
    if (!matched) {
        std.debug.print("No match found.\n", .{});
    } else {
        std.debug.print("{any}", .{matched});
    }

    return;
}
