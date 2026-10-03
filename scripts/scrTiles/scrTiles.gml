globalvar TileTypes;
globalvar TileDim, HalfTile;
TileDim  = 32;
HalfTile = TileDim / 2;

enum TileTypes {
	NULL,
	WALL,
	TREE,
	GRASS,
	PATH,
	TALLGRASS,
	FAIRYCIRCLE,
	MOUNTAIN
}