const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const slopes = @embedFile("input03.txt");

fn countTrees(right: u32, down: u32) u32 {
    var slopeIterator = std.mem.tokenize(slopes, "\n\r");

    var rightPosition: usize = 0;
    var downPosition: usize = 1;
    var treesFound: u32 = 0;

    while (slopeIterator.next()) |slope| {
        downPosition -= 1;

        if (downPosition > 0) {
            continue;
        } else
            downPosition = down;

        if (slope[rightPosition] == '#')
            treesFound += 1;

        rightPosition = (rightPosition + right) % slope.len;
    }

    return treesFound;
}

fn part1() !void {
    print("Part1:\n", .{});

    const treesFound = countTrees(3, 1);

    print("I found {} trees!\n", .{treesFound}); //234
}

fn part2() !void {
    print("\nPart2:\n", .{});

    const SlopeConfiguration = struct { right: u32, down: u32 };
    const slopeConfigurations = [_]SlopeConfiguration{
        SlopeConfiguration{ .right = 1, .down = 1 },
        SlopeConfiguration{ .right = 3, .down = 1 },
        SlopeConfiguration{ .right = 5, .down = 1 },
        SlopeConfiguration{ .right = 7, .down = 1 },
        SlopeConfiguration{ .right = 1, .down = 2 },
    };

    var multiplication: usize = 1;
    for (slopeConfigurations) |slopeConfig| {
        const treeCount = countTrees(slopeConfig.right, slopeConfig.down);

        multiplication *= treeCount;

        print("(r:{}, d:{}) => {}\n", .{ slopeConfig.right, slopeConfig.down, treeCount });
    }

    print("Final multiplication: {}\n", .{multiplication});
}

pub fn main() !void {
    try part1();
    try part2();
}
