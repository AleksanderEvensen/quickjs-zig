const std = @import("std");

pub fn build(b: *std.Build) void {
    // Read version from VERSION file at compile time
    const VERSION = std.mem.trim(u8, @embedFile("./source/VERSION"), " \t\n\r");

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Build options
    const enable_lto = b.option(bool, "lto", "Enable Link Time Optimization") orelse false;
    const enable_asan = b.option(bool, "asan", "Enable AddressSanitizer") orelse false;
    const enable_msan = b.option(bool, "msan", "Enable MemorySanitizer") orelse false;
    const enable_ubsan = b.option(bool, "ubsan", "Enable UndefinedBehaviorSanitizer") orelse false;

    // Core source files for libquickjs
    const lib_sources = [_][]const u8{
        "./source/quickjs.c",
        "./source/dtoa.c",
        "./source/libregexp.c",
        "./source/libunicode.c",
        "./source/cutils.c",
        "./source/quickjs-libc.c",
    };

    const libquickjs = b.addStaticLibrary(.{
        .name = "libquickjs",
        .target = target,
        .optimize = optimize,
    });

    libquickjs.root_module.addCSourceFiles(.{
        .files = &lib_sources,
        .flags = getCompilerFlags(
            b,
            target,
            VERSION,
            enable_lto,
            enable_asan,
            enable_msan,
            enable_ubsan,
        ),
    });

    libquickjs.addIncludePath(b.path("./source/"));
    libquickjs.linkLibC();
    addSystemLibraries(libquickjs, target);
    b.installArtifact(libquickjs);

    // First build qjsc compiler for generating repl.c
    const qjsc = b.addExecutable(.{
        .name = "qjsc",
        .target = target,
        .optimize = optimize,
    });

    qjsc.addCSourceFiles(.{
        .files = &lib_sources ++ .{"./source/qjsc.c"},
        .flags = getCompilerFlags(
            b,
            target,
            VERSION,
            enable_lto,
            enable_asan,
            enable_msan,
            enable_ubsan,
        ),
    });

    qjsc.addIncludePath(b.path("./source/"));
    qjsc.linkLibC();
    addSystemLibraries(qjsc, target);
    b.installArtifact(qjsc);

    // Generate repl.c from repl.js using qjsc
    const repl_gen = b.addRunArtifact(qjsc);
    repl_gen.addArgs(&.{ "-s", "-c", "-o", "-m", "./source/repl.c" });

    const repl_c = repl_gen.addOutputFileArg("./source/repl.c");

    // QJS interpreter executable (depends on generated repl.c)
    const qjs = b.addExecutable(.{
        .name = "qjs",
        .target = target,
        .optimize = optimize,
    });

    qjs.addIncludePath(b.path("./source/"));
    qjs.addCSourceFiles(.{
        .files = &lib_sources ++ .{"./source/qjs.c"},
        .flags = getCompilerFlags(b, target, VERSION, enable_lto, enable_asan, enable_msan, enable_ubsan),
    });

    qjs.addCSourceFile(.{
        .file = repl_c,
        .flags = getCompilerFlags(b, target, VERSION, enable_lto, enable_asan, enable_msan, enable_ubsan),
    });

    qjs.linkLibC();
    addSystemLibraries(qjs, target);
    b.installArtifact(qjs);
}

fn getCompilerFlags(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    version: []const u8,
    enable_lto: bool,
    enable_asan: bool,
    enable_msan: bool,
    enable_ubsan: bool,
) []const []const u8 {
    var flags = std.ArrayList([]const u8).init(b.allocator);

    // Base flags
    flags.appendSlice(&.{
        "-std=c11",
        "-Wall",
        "-Wextra",
        "-Wno-sign-compare",
        "-Wno-missing-field-initializers",
        "-Wundef",
        "-Wuninitialized",
        "-Wunused",
        "-Wno-unused-parameter",
        "-Wwrite-strings",
        "-Wchar-subscripts",
        "-funsigned-char",
        "-fwrapv", // ensure signed overflows behave as expected
        "-D_GNU_SOURCE",
    }) catch unreachable;

    // Version define
    const version_define = std.fmt.allocPrint(b.allocator, "-DCONFIG_VERSION=\"{s}\"", .{version}) catch unreachable;
    flags.append(version_define) catch unreachable;

    // Platform-specific flags
    switch (target.result.os.tag) {
        .windows => {
            flags.append("-D__USE_MINGW_ANSI_STDIO") catch unreachable;
        },
        .linux => {
            // Check for closefrom support could be added here
        },
        else => {},
    }

    // LTO
    if (enable_lto) {
        flags.append("-flto") catch unreachable;
    }

    // Sanitizers
    if (enable_asan) {
        flags.appendSlice(&.{ "-fsanitize=address", "-fno-omit-frame-pointer" }) catch unreachable;
    }
    if (enable_msan) {
        flags.appendSlice(&.{ "-fsanitize=memory", "-fno-omit-frame-pointer" }) catch unreachable;
    }
    if (enable_ubsan) {
        flags.appendSlice(&.{ "-fsanitize=undefined", "-fno-omit-frame-pointer" }) catch unreachable;
    }

    return flags.toOwnedSlice() catch unreachable;
}

fn addSystemLibraries(artifact: *std.Build.Step.Compile, target: std.Build.ResolvedTarget) void {
    artifact.linkSystemLibrary("m");
    artifact.linkSystemLibrary("pthread");

    // Windows doesn't need -ldl
    if (target.result.os.tag != .windows) {
        artifact.linkSystemLibrary("dl");
    }
}
