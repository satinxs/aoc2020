const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const boardingPasses = @embedFile("input05.txt");

const BoardingPass = struct { row: u32, column: u32 };

fn getRow(pass: []const u8) u32 {
    var final: u32 = 0;

    for (pass) |c| {
        final <<= 1;

        if (c == 'B')
            final |= 1;
    }

    return final;
}

fn getColumn(pass: []const u8) u32 {
    var final: u32 = 0;

    for (pass) |c| {
        final <<= 1;

        if (c == 'R')
            final |= 1;
    }

    return final;
}

fn getRowAndColumn(pass: []const u8) BoardingPass {
    return BoardingPass{
        .row = getRow(pass[0..7]),
        .column = getColumn(pass[7..]),
    };
}

fn getSeatIds(allocator: *Allocator) !std.ArrayList(u32) {
    var seatIds = std.ArrayList(u32).init(allocator);
    var lines = std.mem.tokenize(boardingPasses, "\n\r");

    while (lines.next()) |pass| {
        var boardingPass = getRowAndColumn(pass);
        var seatId = boardingPass.row * 8 + boardingPass.column;
        try seatIds.append(seatId);
    }

    return seatIds;
}

fn part1() !void {
    print("Part 1:\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var seatIds = try getSeatIds(&gpa.allocator);
    defer seatIds.deinit();

    var maxSeatId: u32 = 0;
    for (seatIds.items) |seatId| {
        if (seatId > maxSeatId)
            maxSeatId = seatId;
    }

    print("Max Seat ID: {}\n", .{maxSeatId});
}

fn part2() !void {
    print("\nPart 2:\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var seatIds = try getSeatIds(&gpa.allocator);
    defer seatIds.deinit();

    var sortedSeatIds: []u32 = try gpa.allocator.alloc(u32, seatIds.items.len);
    defer gpa.allocator.free(sortedSeatIds);

    std.mem.copy(u32, sortedSeatIds, seatIds.items);
    std.sort.sort(u32, sortedSeatIds, {}, comptime std.sort.asc(u32));

    var i: u32 = 1;
    while (i < sortedSeatIds.len - 1) : (i += 1) {
        const previousSeatId = sortedSeatIds[i - 1];
        const seatId = sortedSeatIds[i];

        if (seatId != (previousSeatId + 1))
            print("My seat id is: {}\n", .{seatId - 1});
    }
}

pub fn main() !void {
    try part1();
    try part2();
}
