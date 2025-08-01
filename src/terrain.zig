const rl = @import("raylib");
const main = @import("main.zig");
const std = @import("std");
const rand = @import("random.zig");


const BlockTypes = enum {
    grass,
    dirt,
    stone,
    iron,
    coal,
    gold,
    redstone,
    diamond,
    poo,
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
    // poo
    .{ .x = 2 * 16, .y = 7 * 16, .width = 16, .height = 16 },
    // air
    .{ .x = 1 * 16, .y = 7 * 16, .width = 16, .height = 16 },
};

var lastHeight: u8 = 6;
pub var scroll: f32 = 0.0;

var zeroth: usize = 0;

var atlas: rl.Texture = undefined;

const floorColumns: usize = 48; // Number of columns in the floor
const scrollMid = floorColumns / 2;
const floorHeight: usize = 7; // Number of blocks in each column
var floor: [floorColumns][floorHeight]BlockTypes = .{.{.air} ** floorHeight} ** floorColumns; //@memset(floor[0..], BlockTypes.air, @sizeOf(BlockTypes) * 7);


pub fn InitTerrain() !void {
    const image: rl.Image = try rl.loadImage("assets/terrain/terrain.png");
    defer rl.unloadImage(image);
    atlas = try rl.loadTextureFromImage(image);

    for (0..floor.len) |i| {
        generateColumn(i);
    }

    for (0..floor.len) |i| {
        const column = floor[i];
        for (0..column.len) |j| {
            std.debug.print("{s}, ", .{ @tagName(column[j]) } );
        }
        std.debug.print("\n", .{});
    }
    zeroth = scrollMid;
}


pub fn UpdateScroll(x: f32) void {
    const column: usize = @mod(@as(usize, @intFromFloat(@divExact(x, 16 * upScale * main.renderScale))), floor.len);

    if (column != zeroth) {
        zeroth = column;
        generateColumn(column);
        scroll += 16;
    }
//    scroll = @as(f32, @floatFromInt( @mod(column, floor.len) ));
}

fn genOre() BlockTypes {
    const randNum: i32 = rand.rand_range(0, 20);
    return switch (randNum) {
        0 => BlockTypes.iron,
        1 => BlockTypes.coal,
        2 => BlockTypes.gold,
        3 => BlockTypes.redstone,
        4 => BlockTypes.diamond,
        else => BlockTypes.stone,
    };
}

pub fn generateColumn(column: usize) void {
    const nextHeight: i16 = genNextHeight();

    if (column >= floor.len or nextHeight >= floor[column].len) {
        std.debug.print("Invalid column {d} or height {d}\n", .{column, nextHeight});
        return;
    }

    floor[column] = .{ .air } ** floorHeight;

    floor[column][@max(0, nextHeight - 2)] = BlockTypes.dirt;
    floor[column][@max(0, nextHeight - 1)] = BlockTypes.grass;

    for (0..@max(0, nextHeight - 2)) |i| {

        floor[column][i] = genOre();

        //floor[column][i] = switch (i) {
        //    nextHeight => BlockTypes.grass,
        //    nextHeight - 1  => BlockTypes.dirt,
        //    nextHeight - 2 => BlockTypes.stone,
        //    else => genOre(),
        //};
    }
    lastHeight = @as(u8, @intCast(nextHeight));
}

    const upScale: f32 = 6;
pub fn DrawFloor() void {

    for (0..floor.len) |jay| {
        const j: usize = @mod(jay + zeroth, floor.len);
        const column = floor[j];
        for (0..column.len) |i| {
            const blockType = column[i];
            if (blockType == BlockTypes.air) continue;

            const source: rl.Rectangle = blockSource[@intFromEnum(blockType)];
            const dest: rl.Rectangle = .{
                .x = ((@as(f32, @floatFromInt(j  * 16)) + scroll ) * upScale * main.renderScale) - @as(f32, @floatFromInt(main.baseWidth)),
                .y = (main.baseHeight - (@as(f32, @floatFromInt(((i + 1) * 16))) * upScale)) * main.renderScale,
                .width = 16 * main.renderScale * upScale,
                .height = 16 * main.renderScale * upScale
            };

            rl.drawTexturePro(atlas, source, dest, .{.x = 0, .y = 0 }, 0.0, .white);
        }
    }
}

pub fn genNextHeight() u8 {

    var newHeight: i32 = 0;
    if(rand.rand_range(0, 2) != 0){
        newHeight = lastHeight + rand.rand_range(0, 2);
    } else {
        newHeight = lastHeight - rand.rand_range(0, 2);
    }

    if (newHeight < 1) newHeight = 1 else if (newHeight > 9) newHeight = 8;

    return @intCast(@min(@as(u16, @intCast(newHeight)), floor[lastHeight].len));
    //return 6;
}
