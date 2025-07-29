const rl = @import("raylib");
const main = @import("main.zig");


const BlockTypes = enum{
    grass,
    dirt,
    stone,
    iron,
    coal,
    gold,
    diamond,
    air,
 };

//const
// 



var lastHeight: u8 = 4;
var scroll: f32 = 0.0;

var atlas: rl.Texture = undefined;

pub fn InitTerrain() !void {
    const image: rl.Image = try rl.loadImage("assets/terrain/terrain.png");
    defer rl.unloadImage(image);
    atlas = try rl.loadTextureFromImage(image);
}

pub fn DrawFloor() void {

    rl.drawTexturePro(
        atlas,
        rl.Rectangle{ .x = 0, .y = 0, .width = @as(f32, @floatFromInt(atlas.width)), .height = @as(f32, @floatFromInt(atlas.height)) },
        rl.Rectangle{ .x = 0 * main.renderScale, .y = 0 * main.renderScale , .width =  @as(f32, @floatFromInt(atlas.width)) * main.renderScale, .height = @as(f32, @floatFromInt(atlas.height)) * main.renderScale },
        rl.Vector2{ .x = 0.0, .y = 0.0 },
        0.0,
        .white);}

pub fn GenerateNext() u8 {
    return 4;
}
