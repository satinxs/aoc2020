const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const numbers = @import("input01.zig").numbers;

fn part1() void {
    for (numbers) |number, i| {
        for (numbers[i + 1 ..]) |next| {
            if (number + next == 2020) {
                print("{} * {} = {}\n", .{ number, next, number * next });
            }
        }
    }
}

fn part2() void {
    for (numbers) |first, i| {
        for (numbers[i + 1 ..]) |second| {
            for (numbers[i + 2 ..]) |third| {
                if (first + second + third == 2020) {
                    print("{} * {} * {} = {}\n", .{ first, second, third, first * second * third });
                }
            }
        }
    }
}

pub fn main() !void {
    part1();
    part2();
}
