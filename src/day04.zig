const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const print = std.debug.print;
const parseInt = @import("parseInt.zig").parse;

const passports = @embedFile("input04.txt");

fn isSpace(string: []const u8) bool {
    for (string) |c| {
        if (!std.ascii.isSpace(c))
            return false;
    }

    return true;
}

const Field = struct {
    key: []const u8,
    value: []const u8,
};

fn isBetween(n: u32, min: u32, max: u32) bool {
    return n >= min and n <= max;
}

fn validateYear(string: []const u8, min: u32, max: u32) !bool {
    if (string.len != 4)
        return false;

    for (string) |char|
        if (!std.ascii.isDigit(char))
            return false;

    const n = try parseInt(u32, string, 10);

    return isBetween(n, min, max);
}

const Passport = struct {
    byr: ?[]const u8,
    iyr: ?[]const u8,
    eyr: ?[]const u8,
    hgt: ?[]const u8,
    hcl: ?[]const u8,
    ecl: ?[]const u8,
    pid: ?[]const u8,
    cid: ?[]const u8,

    pub fn hasAllRequiredFields(p: *const Passport) bool {
        return p.byr != null and p.iyr != null and p.eyr != null and p.hgt != null and p.hcl != null and p.ecl != null and p.pid != null;
    }

    pub fn validateBirthdayYear(p: *const Passport) !bool {
        return try validateYear(p.byr.?, 1920, 2002);
    }

    pub fn validateIssueYear(p: *const Passport) !bool {
        return try validateYear(p.iyr.?, 2010, 2020);
    }

    pub fn validateExpirationYear(p: *const Passport) !bool {
        return try validateYear(p.eyr.?, 2020, 2030);
    }

    pub fn validateHeight(p: *const Passport) !bool {
        const height = p.hgt.?;

        if (height.len > 5) //we support '\d\d\dcm' or '\d\din'
            return false;

        if (std.mem.endsWith(u8, height, "cm")) {
            return (std.mem.order(u8, height, "149cm") == .gt) and (std.mem.order(u8, height, "194cm") == .lt);
        } else if (std.mem.endsWith(u8, height, "in")) {
            return (std.mem.order(u8, height, "58in") == .gt) and (std.mem.order(u8, height, "77in") == .lt);
        } else return false;

        return true;
    }

    pub fn validateHairColor(p: *const Passport) !bool {
        const hairColor = p.hcl.?;

        if (hairColor.len != 7)
            return false;

        for (hairColor[1..]) |char| {
            switch (char) {
                '0'...'9' => continue,
                'a'...'f' => continue,
                else => return false,
            }
        }

        return true;
    }

    pub fn validateEyeColor(p: *const Passport) !bool {
        const eyeColor = p.ecl.?;

        const validColors = [_][]const u8{ "amb", "blu", "brn", "gry", "grn", "hzl", "oth" };

        inline for (validColors) |color| {
            if (std.mem.eql(u8, eyeColor, color))
                return true;
        }

        return false;
    }

    pub fn validatePassportId(p: *const Passport) !bool {
        const pid = p.pid.?;

        if (pid.len != 9)
            return false;

        for (pid) |char| {
            if (!std.ascii.isDigit(char))
                return false;
        }

        return true;
    }

    pub fn isValid(p: *const Passport) !bool {
        if (!p.hasAllRequiredFields()) {
            return false;
        }
        if (!try p.validateBirthdayYear()) {
            return false;
        }

        if (!try p.validateIssueYear()) {
            return false;
        }

        if (!try p.validateExpirationYear()) {
            return false;
        }

        if (!try p.validateHeight()) {
            return false;
        }

        if (!try p.validateHairColor()) {
            return false;
        }

        if (!try p.validateEyeColor()) {
            return false;
        }

        if (!try p.validatePassportId()) {
            return false;
        }

        return true;
    }
};

fn stringEqual(stringA: []const u8, stringB: []const u8) bool {
    return std.mem.eql(u8, stringA, stringB);
}

fn setField(passport: *Passport, field: Field) void {
    if (stringEqual(field.key, "byr")) {
        passport.byr = field.value;
    } else if (stringEqual(field.key, "iyr")) {
        passport.iyr = field.value;
    } else if (stringEqual(field.key, "eyr")) {
        passport.eyr = field.value;
    } else if (stringEqual(field.key, "hgt")) {
        passport.hgt = field.value;
    } else if (stringEqual(field.key, "hcl")) {
        passport.hcl = field.value;
    } else if (stringEqual(field.key, "ecl")) {
        passport.ecl = field.value;
    } else if (stringEqual(field.key, "pid")) {
        passport.pid = field.value;
    } else if (stringEqual(field.key, "cid")) {
        passport.cid = field.value;
    }
}

fn parseField(field: []const u8) Field {
    var tokens = std.mem.tokenize(field, ":");

    var fieldKey = tokens.next().?;
    var fieldValue = tokens.next().?;

    return Field{ .key = fieldKey, .value = fieldValue };
}

fn parseLine(passport: *Passport, line: []const u8) void {
    var fields = std.mem.tokenize(line, " \n\r");

    while (fields.next()) |field| {
        var parsedField = parseField(field);
        setField(passport, parsedField);
    }
}

fn parseAllPassports(allocator: *Allocator) !std.ArrayList(Passport) {
    var passportList = std.ArrayList(Passport).init(allocator);

    var iterator = std.mem.split(passports, "\n");
    var passport: Passport = undefined;
    while (iterator.next()) |line| {
        if (isSpace(line)) {
            try passportList.append(passport);
            passport = undefined;
        } else {
            parseLine(&passport, line);
        }
    }

    try passportList.append(passport);

    return passportList;
}

fn part1() !void {
    print("Part1:\n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var passportList = try parseAllPassports(&gpa.allocator);
    defer passportList.deinit();

    var validPassports: u32 = 0;
    for (passportList.items) |passport| {
        if (passport.hasAllRequiredFields())
            validPassports += 1;
    }
    print("Valid passports: {}\n", .{validPassports});
}

fn part2() !void {
    print("\nPart2:\n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var passportList = try parseAllPassports(&gpa.allocator);
    defer passportList.deinit();

    var validPassports: u32 = 0;
    for (passportList.items) |passport| {
        if (try passport.isValid()) {
            validPassports += 1;
        }
    }
    print("Valid passports: {}\n", .{validPassports});
}

pub fn main() !void {
    try part1();
    try part2();
}
