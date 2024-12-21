const std = @import("std");

pub fn run() void {
    const input_file = "resources/day_01_input.txt";

    const allocator = std.heap.page_allocator;
    const cwd = std.fs.cwd();

    const file_metadata = cwd.statFile(input_file) catch unreachable;
    const file_size = file_metadata.size;

    const file_content = cwd.readFileAlloc(allocator, input_file, file_size) catch unreachable;
    defer allocator.free(file_content);

    var leftSegment = std.ArrayList(u32).init(allocator);
    defer leftSegment.deinit();

    var rightSegment = std.ArrayList(u32).init(allocator);
    defer rightSegment.deinit();

    var start: usize = 0;

    // .. for loop!!
    for (file_content, 0..) |c, i| {
        if (c == '\n') {
            const line = file_content[start..i];
            var segments = std.mem.splitSequence(u8, line, "  ");
            const leftElement = segments.first();
            const rightElement = segments.next();

            if (leftElement.len > 0) {
                const trimmedLeft = std.mem.trim(u8, leftElement, " ");
                const leftValue = std.fmt.parseInt(u32, trimmedLeft, 10) catch unreachable;
                leftSegment.append(leftValue) catch unreachable;
            }

            if (rightElement != null) {
                const trimmedRight = std.mem.trim(u8, rightElement.?, " ");
                const rightValue = std.fmt.parseInt(u32, trimmedRight, 10) catch unreachable;
                rightSegment.append(rightValue) catch unreachable;
            }

            start = i + 1;
        }
    }

    std.mem.sort(u32, leftSegment.items[0..], {}, std.sort.asc(u32));
    std.mem.sort(u32, rightSegment.items[0..], {}, std.sort.asc(u32));

    const len = leftSegment.items.len;
    var total: u32 = 0;
    for (0..len) |idx| {
        const cl: i32 = @intCast(leftSegment.items[idx]);
        const cr: i32 = @intCast(rightSegment.items[idx]);

        const difference: u32 = @abs(cl - cr);
        total = total + difference;
        std.debug.print("{any} - {any} =  {any}\n", .{ cl, cr, difference });
    }

    std.debug.print("Total difference - {d}\n", .{total});

    // // std.debug.print("Total sum of subtracted smallest items: {d}\n", .{total});
    //
    // std.debug.print("{d}\n", .{leftSegment.items.len});
    // std.debug.print("{d}\n", .{rightSegment.items.len});
    //
    // // Print the first elements of leftSegment and rightSegment
    // if (leftSegment.items.len > 0 and rightSegment.items.len > 0) {
    //     std.debug.print("First left element: {d}\n", .{leftSegment.items[1]});
    //     std.debug.print("First right element: {d}\n", .{rightSegment.items[1]});
    // } else {
    //     std.debug.print("No segments found\n", .{});
    // }
    //
    // std.debug.print("File content - {any}", .{file_content[0]});
}
