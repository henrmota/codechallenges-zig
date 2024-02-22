const std = @import("std");

pub fn getFileStats(path: []const u8) !struct { usize, usize, usize, usize } {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    var buffer: [1]u8 = [1]u8{0};

    var bytes: usize = 0;
    var chars: usize = 0;
    var lines: usize = 0;
    var words: usize = 0;

    var isWithinWord = false;

    while (true) {
        const size = try file.read(&buffer);
        if (size == 0) {
            break;
        }
        const byte = buffer[0];

        bytes += 1;

        if (byte >> 6 == 2) {
            continue;
        }

        if (byte == '\n') {
            lines += 1;
        }

        const isWhiteSpace = switch (byte) {
            '\t', '\n', '\r', ' ', 0x85, 0xA0 => true,
            else => false,
        };

        if (!isWhiteSpace) {
            isWithinWord = true;
        } else if (isWithinWord) {
            isWithinWord = false;
            words += 1;
        }

        chars += 1;
    }

    return .{ bytes, chars, lines, words };
}

pub fn main() !void {
    const stats = try getFileStats("./test.txt");
    std.debug.print("{d} {d} {d} {d}\n", stats);
}

test "simple test" {
    var filename = "test.txt";

    const stats = try getFileStats(filename);
    try std.testing.expectEqual(stats, .{ 51, 49, 4, 12 });
}
