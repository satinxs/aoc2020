const std = @import("std");
const maxInt = std.math.maxInt;

pub fn parse(comptime T: type, buf: []const u8, radix: u8) !T {
    var x: T = 0;

    for (buf) |c| {
        const digit = charToDigit(c);

        if (digit >= radix) {
            return error.InvalidChar;
        }

        // x *= radix
        if (@mulWithOverflow(T, x, radix, &x)) {
            return error.Overflow;
        }

        // x += digit
        if (@addWithOverflow(T, x, digit, &x)) {
            return error.Overflow;
        }
    }

    return x;
}

fn charToDigit(c: u8) u8 {
    return switch (c) {
        '0'...'9' => c - '0',
        'A'...'Z' => c - 'A' + 10,
        'a'...'z' => c - 'a' + 10,
        else => maxInt(u8),
    };
}
