const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;
const parseInt = @import("parseInt.zig").parse;

const passwords = @embedFile("input02.txt");

fn validatePasswordPart1(min: u32, max: u32, char: u8, password: []const u8) bool {
    var count: u32 = 0;

    for (password) |passwordChar| {
        if (passwordChar == char)
            count += 1;
    }

    return min <= count and count <= max;
}

fn validatePasswordPart2(a: u32, b: u32, char: u8, password: []const u8) bool {
    var hasA = false;
    if (a <= password.len)
        hasA = password[a - 1] == char;

    var hasB = false;
    if (b <= password.len)
        hasB = password[b - 1] == char;

    return hasA != hasB;
}

fn countValidPasswords(validate: fn (u32, u32, u8, []const u8) bool) !u32 {
    var goodPasswords: u32 = 0;

    var linesTokenizer = std.mem.tokenize(passwords, "\n\r");
    while (linesTokenizer.next()) |line| {
        var parts = std.mem.tokenize(line, "-: ");

        var min: u32 = try parseInt(u32, parts.next().?, 10);
        var max: u32 = try parseInt(u32, parts.next().?, 10);
        var char = parts.next().?[0];
        var password = parts.next().?;
        var isValid = validate(min, max, char, password);

        if (isValid)
            goodPasswords += 1;
    }

    return goodPasswords;
}

fn part1() !void {
    const count = try countValidPasswords(validatePasswordPart1);

    print("Part1: Good passwords: {}\n", .{count});
}

fn part2() !void {
    const count = try countValidPasswords(validatePasswordPart2);

    print("Part2: Good passwords: {}\n", .{count});
}

pub fn main() !void {
    try part1();
    try part2();
}
