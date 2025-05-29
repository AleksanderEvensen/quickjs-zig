const std = @import("std");
const cApi = @import("c.zig");
const c = cApi.c;

const JSRuntime = @import("JSRuntime.zig");

pub fn evalJS(code: []const u8) !cApi.c.JSValue {
    const rt = try JSRuntime.init();
    defer rt.deinit();

    const ctx = try rt.newContext();
    defer c.JS_FreeContext(ctx);

    // Add console.log and other standard methods
    _ = c.js_init_module_std(ctx, "std");
    _ = c.js_init_module_os(ctx, "os");
    _ = c.js_std_add_helpers(ctx, -1, null);

    const result = c.JS_Eval(ctx, code.ptr, code.len, "file.js", c.JS_EVAL_FLAG_STRICT);

    return result;
}
