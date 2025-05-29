const quickjs = @import("quickjs-zig");
const std = @import("std");

pub fn main() !void {
    const js_code = "console.log('Hello World, from JS!');";

    const js_result = try quickjs.evalJS(js_code);
    std.debug.print("JS Result: {any}\n", .{js_result});
}
