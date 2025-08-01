const std = @import("std");


var state: u64 = 4;

pub fn gen_seed() void{
    const time = std.time.milliTimestamp();
    state = @as(u64, @bitCast(time));
}

pub fn set_seed(seed: u64) void {
    state = seed;
}

pub fn rand_lcg() u32 {
    const a: u64 = 6364136223846793005;
    const c: u64 = 1013904223;
    state = (a *% state +% c) & 0xFFFFFFFFFFFFFFFF;
    return @intCast(state >> 32);
}

pub fn rand_range(min: i32, max: i32) i32 {
    const range = max - min;
    if (range == 0) return min;
    return min + @as(i32, @bitCast(rand_lcg() %  @as(u32, @intCast(range))));
}
