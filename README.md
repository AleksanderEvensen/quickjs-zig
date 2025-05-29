# QuickJS wrapper in Zig
> [!WARNING]
> **Under development.**
> 
> This package is under heavy development and may be very unstable

A zig wrapper for the minimal JS engine [quickjs](https://bellard.org/quickjs/)

## Install

```
zig fetch --save git+https://github.com/AleksanderEvensen/quickjs-zig.git
```

## UNDER DEVELOPMENT

The C methods is fully usable under the cApi object.

```zig
const quickjs = @import("quickjs");

pub fn main() !void {
    const runtime = quickjs.cApi.JS_NewRuntime();
    defer quickjs.cApi.JS_FreeRuntime(runtime);

    // ...
}
```

## Wrappers

The library will provide wrappers over the C methods to work more seamlessly with the zig coding style and ecosystem

```zig
const quickjs = @import("quickjs");
const JSRuntime = quickjs.JSRuntime;

pub fn main() !void {
    const runtime = try JSRuntime.init();
    defer runtime.deinit();

    const ctx = try runtime.newContext();
    defer ctx.deinit();

    _ = try ctx.evaluate("console.log('Hello World')");

    const result = try ctx.evaluate("4 + 5");

    std.debug.print("4 + 5 = {d}\n", .{ result.Int });
}
```
