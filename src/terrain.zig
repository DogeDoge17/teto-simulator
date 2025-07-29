const rl = @import("raylib");
const main = @import("main.zig");


const BlockTypes = enum{
    grass,
    dirt,
    stone,
    iron,
    coal,
    gold,
    redstone,
    diamond,
    air,
 };

const blockSource = [_]rl.Rectangle{
    // grass
    .{ .x = 3 * 16, .y = 0 * 16, .width = 16, .height = 16 },
    // dirt
    .{ .x = 2 * 16, .y = 0 * 16, .width = 16, .height = 16 },
    // stone
    .{ .x = 1 * 16, .y = 0 * 16, .width = 16, .height = 16 },
    // iron
    .{ .x = 1 * 16, .y = 2 * 16, .width = 16, .height = 16 },
    // coal
    .{ .x = 2 * 16, .y = 2 * 16, .width = 16, .height = 16 },
    // gold
    .{ .x = 0 * 16, .y = 2 * 16, .width = 16, .height = 16 },
    // redstone
    .{ .x = 3 * 16, .y = 3 * 16, .width = 16, .height = 16 },
    // diamond
    .{ .x = 2 * 16, .y = 3 * 16, .width = 16, .height = 16 },
    // air
    .{ .x = 1 * 16, .y = 3 * 16, .width = 16, .height = 16 }, };


var lastHeight: u8 = 4;
var scroll: f32 = 0.0;

var atlas: rl.Texture = undefined;

pub fn InitTerrain() !void {
    const image: rl.Image = try rl.loadImage("assets/terrain/terrain.png");
    defer rl.unloadImage(image);
    atlas = try rl.loadTextureFromImage(image);
}

pub fn DrawFloor() void {

    const upScale:f32 = 6;

    var i:usize = 0;
    while(i <= @intFromEnum(BlockTypes.air)) : (i += 1) {
       rl.drawTexturePro(
           atlas,
           blockSource[i],
           rl.Rectangle{
               .x = @as(f32, @floatFromInt(i * 16)) * upScale * main.renderScale,
               .y = @as(f32, 240 - 16) * main.renderScale + scroll ,
               .width = 16 * main.renderScale * upScale,
               .height = 16 * main.renderScale * upScale
           },
           rl.Vector2{ .x = 0.0, .y = 0.0 },
           0.0,
           .white);
    }


    //rl.drawTexturePro(
    //    atlas,
    //    rl.Rectangle{ .x = 0, .y = 0, .width = @as(f32, @floatFromInt(atlas.width)), .height = @as(f32, @floatFromInt(atlas.height)) },
    //    rl.Rectangle{ .x = 0 * main.renderScale, .y = 0 * main.renderScale , .width =  @as(f32, @floatFromInt(atlas.width)) * main.renderScale, .height = @as(f32, @floatFromInt(atlas.height)) * main.renderScale },
    //    rl.Vector2{ .x = 0.0, .y = 0.0 },
    //    0.0,
    //    .white);

}

pub fn GenerateNext() u8 {
    return 4;
}
