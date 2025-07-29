const rl = @import("raylib");
const std = @import("std");
const tetoGm = @import("teto.zig");
const terr = @import("terrain.zig");

var teto : tetoGm.Teto = undefined;

pub fn Start() !void {
    teto = try tetoGm.Teto.Init();
    try terr.InitTerrain();
}

pub fn Cleanup() void {
}

pub fn Update() !void {
    teto.Update();
}

pub fn Draw() void {
    rl.drawText("TETO SIMULATOR 90 BILION", 10, 10, 20, .light_gray);
    //rl.drawTexture(miku, 100, 100, .white);
    terr.DrawFloor();
    teto.Draw();
}