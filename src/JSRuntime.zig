const cApi = @import("c.zig");
const std = @import("std");

const Self = @This();

rt: *cApi.c.JSRuntime,

pub fn init() !Self {
    // TODO: Use NewRuntime2 function and implement custom allocation handlers.
    const runtime = cApi.c.JS_NewRuntime() orelse {
        return error.RuntimeInitializationFailed;
    };

    cApi.c.js_std_init_handlers(runtime);
    cApi.c.js_std_free_handlers(runtime);

    return Self{
        .rt = runtime,
    };
}

pub fn deinit(self: Self) void {
    cApi.c.JS_FreeRuntime(self.rt);
}

pub fn getRuntime(self: Self) *cApi.c.JSRuntime {
    return self.rt;
}

pub fn setRuntimeInfo(self: Self, info: []u8) void {
    cApi.c.JS_SetRuntimeInfo(self.rt, info.ptr);
}

pub fn setMemoryLimit(self: Self, limit: usize) void {
    cApi.c.JS_SetMemoryLimit(self.rt, limit);
}

pub fn setGCThreshold(self: Self, gc_threshold: usize) void {
    cApi.c.JS_SetGCThreshold(self.rt, gc_threshold);
}

pub fn setMaxStackSize(self: Self, stack_size: usize) void {
    cApi.c.JS_SetMaxStackSize(self.rt, stack_size);
}

pub fn updateStackTop(self: Self) void {
    cApi.c.JS_UpdateStackTop(self.rt);
}

// CHORE: These won't necessarily be used...
// pub fn getRuntimeOpaque(self: Self) *anyopaque {
//     return cApi.c.JS_GetRuntimeOpaque(self.rt);
// }

// pub fn setRuntimeOpaque(self: Self, opaq: *anyopaque) void {
//     cApi.c.JS_SetRuntimeOpaque(self.rt, opaq);
// }

// TODO: Implement this method if needed
pub fn markValue(self: Self, value: cApi.c.JSValueConst, mark_func: cApi.c.JS_MarkFunc) void {
    _ = self;
    _ = value;
    _ = mark_func;
    @panic("TODO: JSRuntime.markValue is not implemented");
}

pub fn runGC(self: Self) void {
    cApi.c.JS_RunGC(self.rt);
}

pub fn isLiveObject(self: Self, obj: cApi.c.JSValueConst) bool {
    return cApi.c.JS_IsLiveObject(self.er, obj) != 0;
}

pub fn newContext(self: Self) !*cApi.c.JSContext {
    // TODO: Use Custom Context wrapper when implemented.
    const ctx = cApi.c.JS_NewContext(self.rt) orelse {
        return error.ContextInitializationFailed;
    };
    return ctx;
}

pub fn newContextRaw(self: Self) !*cApi.c.JSContext {
    const ctx = cApi.c.JS_NewContextRaw(self.rt) orelse {
        return error.ContextInitializationFailed;
    };
    return ctx;
}

// TODO: Implement methods below if needed

// void *js_malloc_rt(JSRuntime *rt, size_t size);
// void js_free_rt(JSRuntime *rt, void *ptr);
// void *js_realloc_rt(JSRuntime *rt, void *ptr, size_t size);
// size_t js_malloc_usable_size_rt(JSRuntime *rt, const void *ptr);
// void *js_mallocz_rt(JSRuntime *rt, size_t size);
// void JS_ComputeMemoryUsage(JSRuntime *rt, JSMemoryUsage *s);
// void JS_DumpMemoryUsage(FILE *fp, const JSMemoryUsage *s, JSRuntime *rt);
// void JS_FreeAtomRT(JSRuntime *rt, JSAtom v);
// int JS_NewClass(JSRuntime *rt, JSClassID class_id, const JSClassDef *class_def);
// int JS_IsRegisteredClass(JSRuntime *rt, JSClassID class_id);
// static inline void JS_FreeValueRT(JSRuntime *rt, JSValue v)
// static inline JSValue JS_DupValueRT(JSRuntime *rt, JSValueConst v)
// void JS_SetSharedArrayBufferFunctions(JSRuntime *rt, const JSSharedArrayBufferFunctions *sf);
// void JS_SetHostPromiseRejectionTracker(JSRuntime *rt, JSHostPromiseRejectionTracker *cb, void *opaque);
// void JS_SetInterruptHandler(JSRuntime *rt, JSInterruptHandler *cb, void *opaque);
// void JS_SetCanBlock(JSRuntime *rt, JS_BOOL can_block);
// void JS_SetStripInfo(JSRuntime *rt, int flags);
// int JS_GetStripInfo(JSRuntime *rt);

// void JS_SetModuleLoaderFunc(JSRuntime *rt,
//                             JSModuleNormalizeFunc *module_normalize,
//                             JSModuleLoaderFunc *module_loader, void *opaque);

// void JS_SetModuleLoaderFunc2(JSRuntime *rt,
//                              JSModuleNormalizeFunc *module_normalize,
//                              JSModuleLoaderFunc2 *module_loader,
//                              JSModuleCheckSupportedImportAttributes *module_check_attrs,
//                              void *opaque);

// JS_BOOL JS_IsJobPending(JSRuntime *rt);
// int JS_ExecutePendingJob(JSRuntime *rt, JSContext **pctx);

// void JS_PrintValueRT(JSRuntime *rt, JSPrintValueWrite *write_func, void *write_opaque,
//                      JSValueConst val, const JSPrintValueOptions *options);

// void JS_PrintValue(JSContext *ctx, JSPrintValueWrite *write_func, void *write_opaque,
//                    JSValueConst val, const JSPrintValueOptions *options);
