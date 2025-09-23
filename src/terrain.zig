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

const FloorColumn =  struct {
    offset: f32,
    blocks: [floorHeight]BlockTypes 
};

var lastHeight: u8 = 6;

var atlas: rl.Texture = undefined;

const floorColumns: usize = 23; // Number of columns in the floor
const floorHeight: usize = 7; // Number of blocks in each column
//var floor: [floorColumns][floorHeight]BlockTypes = .{.{.air} ** floorHeight} ** floorColumns; //@memset(floor[0..], BlockTypes.air, @sizeOf(BlockTypes) * 7);
//var floor: [floorColumns]FloorColumn = .{.{ .offset = 0, .blocks = .{.air} ** floorHeight }} ** floorColumns;
var floor: [floorColumns]FloorColumn = [_]FloorColumn{
    .{ .offset = 0, .blocks = [_]BlockTypes{.air} ** floorHeight }
} ** floorColumns;

var backColumn: usize = 0;
var frontColumn: usize = floorColumns - 1; 

const fullBlock = 6 * 16;

pub fn InitTerrain() !void {
    const image: rl.Image = try rl.loadImage("assets/terrain/terrain.png");
    defer rl.unloadImage(image);
    atlas = try rl.loadTextureFromImage(image);

    for (0..floor.len) |i| {
        generateColumn(i);
        floor[i].offset = @as(f32, @floatFromInt(i)) * fullBlock; 
    }

    for (0..floor.len) |i| {
        const column = floor[i];
        for (0..column.blocks.len) |j| {
            std.debug.print("{s}, ", .{ @tagName(column.blocks[j]) } );
        }
        std.debug.print("\n", .{});
    }
}

/// x is the target position of which the camera is focused on
pub fn UpdateScroll(x: f32) void {
    const l = floor[backColumn].offset + fullBlock;
    const r = x / main.renderScale - main.baseWidth / 2;
    if(l >= r)
        return;

    floor[backColumn].offset = floor[frontColumn].offset + fullBlock;
    frontColumn = backColumn;
    backColumn = @mod(backColumn + 1, floorColumns);

    generateColumn(frontColumn);
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

    if (column >= floor.len or nextHeight > floor[column].blocks.len) {
        std.debug.print("Invalid column {d} or height {d}\n", .{column, nextHeight});
        return;
    }

    floor[column].blocks = .{ .air } ** floorHeight;

    floor[column].blocks[@max(0, nextHeight - 2)] = BlockTypes.dirt;
    floor[column].blocks[@max(0, nextHeight - 1)] = BlockTypes.grass;

    for (0..@max(0, nextHeight - 2)) |i| {

        floor[column].blocks[i] = genOre();

        //floor[column][i] = switch (i) {
        //    nextHeight => BlockTypes.grass,
        //    nextHeight - 1  => BlockTypes.dirt,
        //    nextHeight - 2 => BlockTypes.stone,
        //    else => genOre(),
        //};
    }
    lastHeight = @as(u8, @intCast(nextHeight));
}

pub fn DrawFloor() void {
    for (0..floor.len) |jay| {
//        const j: usize = @mod(jay + zeroth, floor.len);
        const column = floor[jay];
        for (0..column.blocks.len) |i| {
            const blockType = column.blocks[i];
            if (blockType == BlockTypes.air) continue;

            const source: rl.Rectangle = blockSource[@intFromEnum(blockType)];
            const dest: rl.Rectangle = .{
                //.x = ((@as(f32, @floatFromInt(j  * 16))) * upScale * main.renderScale) - @as(f32, @floatFromInt(main.baseWidth)),
                .x = column.offset * main.renderScale, 
                .y = (main.baseHeight - @as(f32, @floatFromInt(((i + 1) * fullBlock))) ) * main.renderScale,
                .width = fullBlock * main.renderScale, 
                .height = fullBlock * main.renderScale,
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

    if (newHeight < 1) newHeight = 1 else if (newHeight > floorHeight) newHeight = floorHeight - 2;

    return @intCast(@min(@as(u16, @intCast(newHeight)), floor[lastHeight].blocks.len));
    //return 6;
}
