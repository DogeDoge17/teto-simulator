const rl = @import("raylib");
const std = @import("std");
const tetoGm = @import("teto.zig");
const terr = @import("terrain.zig");
const main = @import("main.zig");

var teto : tetoGm.Teto = undefined;

pub fn Start() !void {
    teto = try tetoGm.Teto.Init();
    try terr.InitTerrain();
}

pub fn Cleanup() void {
}

pub fn Update() !void {
    teto.Update();
    _ = terr.TryAgainstFloor(&teto.rb);
}

pub fn UpdateCamera(camera: *rl.Camera2D) void {
    camera.target.x = @max(@max((teto.rb.position.x + (teto.rb.bounds.x / 2)) * main.renderScale, camera.target.x), @as(f32, @floatFromInt(@divExact(main.targetWidth, 2))) );
    terr.UpdateScroll(camera.target.x);
}

pub fn Draw() void {
    terr.DrawFloor();
    teto.Draw();
}

pub fn DrawUI() void {
    rl.drawText("TETO SIMULATOR 90 BILION", 10, 10, 20, .light_gray);
}
