const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;

const customsDeclarations = @embedFile("input06.txt");

fn isSpace(line: []const u8) bool {
    for (line) |c| {
        if (!std.ascii.isSpace(c))
            return false;
    }

    return true;
}

const Declaration = struct { total: u32, fields: [27]u32 };

fn getAllDeclarations(allocator: *Allocator) !std.ArrayList(Declaration) {
    var declarations = std.ArrayList(Declaration).init(allocator);

    var lines = std.mem.split(customsDeclarations, "\n");

    var total: u32 = 0;
    var fields: [27]u32 = undefined;
    std.mem.secureZero(u32, fields[0..]);

    while (lines.next()) |line| {
        if (isSpace(line)) {
            try declarations.append(Declaration{
                .total = total,
                .fields = fields,
            });
            std.mem.secureZero(u32, fields[0..]);
            total = 0;
        } else {
            total += 1;
            for (line) |c| {
                if (std.ascii.isAlpha(c)) {
                    fields[c - 'a'] += 1;
                }
            }
        }
    }
    try declarations.append(Declaration{
        .total = total,
        .fields = fields,
    });

    return declarations;
}

fn printDeclaration(declaration: [27]u32) void {
    var index: u8 = 0;
    while (index < 27) : (index += 1) {
        if (declaration[index] > 0)
            print("{c}, ", .{index + 'a'});
    }
    print("\n", .{});
}

fn part1() !void {
    print("Part1:\n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var declarations = try getAllDeclarations(&gpa.allocator);
    defer declarations.deinit();

    var total: u32 = 0;
    for (declarations.items) |declaration| {
        for (declaration.fields) |c| {
            if (c > 0)
                total += 1;
        }
    }

    print("Total: {}\n", .{total});
}

fn part2() !void {
    print("\nPart2:\n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var declarations = try getAllDeclarations(&gpa.allocator);
    defer declarations.deinit();

    var total: u32 = 0;

    for (declarations.items) |declaration| {
        for (declaration.fields) |c| {
            if (c == declaration.total) {
                total += 1;
            }
        }
    }

    print("Total: {}\n", .{total});
}

pub fn main() !void {
    try part1();
    try part2();
}
