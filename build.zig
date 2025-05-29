const std = @import("std");

const this = @This();

pub fn getQuickJS(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) *std.Build.Step.Compile {
    const libquickjs_dep = b.dependency("libquickjs", .{
        .target = target,
        .optimize = optimize,
    });

    const libquickjs = libquickjs_dep.artifact("libquickjs");
    b.installArtifact(libquickjs);
    return libquickjs;
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const quickjs_artifact = getQuickJS(b, target, optimize);

    const quickjs_module = b.addModule("quickjs-zig", .{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });
    quickjs_module.linkLibrary(quickjs_artifact);
    quickjs_module.addIncludePath(b.path("./quickjs/source/"));

    // Main Demo
    {
        const exe = b.addExecutable(.{
            .name = "quickjs-zig-demo",
            .root_module = b.createModule(.{
                .root_source_file = b.path("examples/main.zig"),
                .target = target,
                .optimize = optimize,
                .imports = &.{
                    .{ .name = "quickjs-zig", .module = quickjs_module },
                },
            }),
        });

        const demo_step = b.step("demo", "Build the demo executable");
        demo_step.dependOn(&b.addInstallArtifact(exe, .{}).step);

        const run_cmd = b.addRunArtifact(exe);

        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }

    const lib_unit_tests = b.addTest(.{
        .root_module = quickjs_module,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
