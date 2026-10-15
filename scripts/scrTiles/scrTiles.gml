globalvar TileDim, HalfTile;
TileDim  = 32;
HalfTile = TileDim / 2;

enum CollisionTypes {
	NON_BLOCKING,
	BLOCKING,
	ILLUSORY,
	HALF_HEIGHT
}

enum TileTypes {
	NULL,
	WALL,
	TREE,
	GRASS,
	PATH,
	TALLGRASS,
	FAIRYCIRCLE,
	MOUNTAIN,
	WATER
}