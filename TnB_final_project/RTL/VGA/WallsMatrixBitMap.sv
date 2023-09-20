// HartsMatrixBitMap File 
// A two level bitmap. dosplaying harts on the screen Apr  2023  
// (c) Technion IIT, Department of Electrical Engineering 2023 



module	WallsMatrixBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input	logic	[10:0] OffsetX, // offset from top left  position 
					input	logic	[10:0] OffsetY,
					input	logic	InsideRectangle, // input that the pixel is within a bracket
					input	logic	breakWall_pulse,
					input logic [10:0] breakWallOffsetX, // when using the hammer
					input logic [10:0] breakWallOffsetY,
					input	logic	breakWall_in_bound,
					input logic [4:0] randomMapLocationX,
					input logic [3:0] randomMapLocationY,
					input logic randomWallSetPulse,

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout  //rgb value from the bitmap 
 ) ;
 

// Size represented as Number of X and Y bits 
localparam logic [7:0] TRANSPARENT_ENCODING = 8'h00 ;// RGB value in the bitmap representing a transparent pixel
localparam  int MAZE_NUMBER_OF_X_LOGICS = 18;
localparam  int MAZE_NUMBER_OF_Y_LOGICS = 12;   


// generate a random value to decide to place a full wall or cracked wall
logic [1:0] randomWall ;	
assign randomWall = (randomMapLocationX[0]) ? 3'h02 : 3'h01 ;


logic pick_another_flag ; // goes up if the spot for the wall is already taken


// if the random map Y location is greater than 11, take only the 3 lower bits
logic [3:0] Y_adjustment ;
assign Y_adjustment = (randomMapLocationY[3] & randomMapLocationY[2]) ? {1'b0,randomMapLocationY[2:0]} : randomMapLocationY[3:0] ;


// the playing screen is 576*384  or  18 * 12 squares of 32*32 bits  
logic [0:MAZE_NUMBER_OF_Y_LOGICS-1] [0:MAZE_NUMBER_OF_X_LOGICS-1] [2:0] MazeBitMapMask ;

																																								 
// specifies the starting values needed for each square
// this bit map will load to the playing bit map on evrey reset
// 3'h003 marks a place where no wall could be placed
logic [0:MAZE_NUMBER_OF_Y_LOGICS-1] [0:MAZE_NUMBER_OF_X_LOGICS-1] [2:0]  starting_MazeBitMapMask= 
{{3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h03, 3'h03, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00},
 {3'h00, 3'h03, 3'h03, 3'h03, 3'h00, 3'h00, 3'h00, 3'h00, 3'h03, 3'h03, 3'h00, 3'h00, 3'h03, 3'h00, 3'h00, 3'h03, 3'h03, 3'h00},
 {3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00},
 {3'h03, 3'h03, 3'h03, 3'h03, 3'h00, 3'h00, 3'h03, 3'h03, 3'h00, 3'h00, 3'h03, 3'h03, 3'h00, 3'h00, 3'h03, 3'h03, 3'h03, 3'h03},
 {3'h00, 3'h00, 3'h00, 3'h03, 3'h00, 3'h00, 3'h03, 3'h00, 3'h00, 3'h00, 3'h00, 3'h03, 3'h00, 3'h00, 3'h03, 3'h00, 3'h02, 3'h00},
 {3'h00, 3'h03, 3'h00, 3'h03, 3'h00, 3'h00, 3'h00, 3'h00, 3'h03, 3'h03, 3'h00, 3'h00, 3'h00, 3'h00, 3'h03, 3'h00, 3'h03, 3'h00},
 {3'h00, 3'h00, 3'h00, 3'h03, 3'h00, 3'h00, 3'h03, 3'h00, 3'h00, 3'h00, 3'h00, 3'h03, 3'h00, 3'h00, 3'h03, 3'h03, 3'h03, 3'h00},
 {3'h00, 3'h03, 3'h00, 3'h03, 3'h00, 3'h00, 3'h03, 3'h03, 3'h00, 3'h00, 3'h03, 3'h03, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00},
 {3'h00, 3'h03, 3'h00, 3'h03, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00},
 {3'h00, 3'h00, 3'h00, 3'h01, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00},
 {3'h00, 3'h03, 3'h00, 3'h01, 3'h00, 3'h00, 3'h03, 3'h03, 3'h00, 3'h00, 3'h00, 3'h03, 3'h03, 3'h00, 3'h00, 3'h03, 3'h03, 3'h00},
 {3'h00, 3'h00, 3'h00, 3'h03, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00, 3'h00}
 };


 logic [0:1] [0:31] [0:31] [7:0]  object_colors  = {
// cracked wall bitmap
{{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h91,8'h91,8'h91,8'h91,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'h91,8'hb6,8'h91,8'h91,8'h91,8'h91,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hb6,8'hb6,8'hb6,8'h91,8'hb6,8'h91,8'hb6,8'hb6,8'h91,8'h00,8'hda,8'h91,8'hb6,8'h6d,8'hb6,8'h91,8'hb6,8'hb6,8'hb6,8'h91,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hb6,8'h91,8'h91,8'h91,8'hb6,8'hb6,8'hb6,8'hb6,8'h91,8'h00,8'h91,8'hb6,8'hb6,8'hb6,8'h6d,8'h91,8'hb6,8'hb6,8'h91,8'h91,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hb6,8'h6d,8'h6d,8'hb6,8'h91,8'hb6,8'hb6,8'h00,8'h91,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h91,8'hb6,8'h6d,8'h6d,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h6d,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hb6,8'h00,8'h00,8'h00,8'h00,8'hb6,8'hb6,8'hda,8'h91,8'hda,8'hb6,8'hb6,8'hda,8'hb6,8'hb6,8'hda,8'h91,8'h00,8'hda,8'hb6,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h91,8'h00,8'h00,8'h00,8'hb6,8'hb6,8'hb6,8'h91,8'h91,8'h6d,8'hb6,8'hb6,8'hb6,8'hb6,8'h91,8'hb6,8'h91,8'h00,8'h91,8'h91,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h91,8'hb6,8'hb6,8'hb6,8'h6d,8'hb6,8'h91,8'h6d,8'h00,8'hb6,8'hb6,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h91,8'h91,8'h91,8'h6d,8'h91,8'hb6,8'h91,8'hb6,8'hb6,8'h91,8'hb6,8'h00,8'h6d,8'hb6,8'hda,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h6d,8'h00,8'h00,8'h91,8'hda,8'h91,8'h91,8'h6d,8'hb6,8'hb6,8'h91,8'hb6,8'h91,8'h6d,8'h00,8'hb6,8'hb6,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h91,8'h91,8'hb6,8'h91,8'h91,8'h91,8'hb6,8'hb6,8'h6d,8'h91,8'h91,8'hb6,8'h00,8'hb6,8'hb6,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h6d,8'h6d,8'h6d,8'h00,8'h6d,8'h6d,8'h6d,8'h6d,8'h00,8'h00,8'h91,8'h6d,8'h6d,8'h00,8'h00,8'h91,8'h6d,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h91,8'hb6,8'hb6,8'hda,8'h00,8'h00,8'h00,8'h00,8'h00,8'h91,8'hb6,8'hda,8'hb6,8'hb6,8'hb6,8'hb6,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h91,8'hb6,8'hda,8'h91,8'hda,8'hda,8'h91,8'h6d,8'h00,8'hb6,8'hb6,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'hda,8'hb6,8'hb6,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h91,8'h91,8'h91,8'h91,8'h91,8'hb6,8'hb6,8'hb6,8'h00,8'h91,8'hb6,8'hb6,8'hb6,8'h91,8'hb6,8'hb6,8'h91,8'hb6,8'hb6,8'h91,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hb6,8'hb6,8'h91,8'hb6,8'h91,8'hb6,8'h91,8'hb6,8'h91,8'h91,8'hb6,8'hb6,8'hb6,8'hb6,8'h91,8'h00,8'hb6,8'h6d,8'hb6,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h91,8'h6d,8'hda,8'hb6,8'hb6,8'hb6,8'h91,8'hb6,8'h91,8'h91,8'hb6,8'h91,8'h91,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hb6,8'hb6,8'hb6,8'h91,8'hb6,8'hb6,8'hb6,8'h91,8'hb6,8'h91,8'hb6,8'h91,8'hb6,8'hb6,8'hb6,8'h91,8'hb6,8'h91,8'h6d,8'hb6,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hb6,8'hb6,8'hb6,8'h91,8'hb6,8'hb6,8'h00,8'h00,8'hb6,8'hb6,8'hb6,8'hb6,8'h91,8'h91,8'h00,8'h00,8'h00,8'h91,8'hb6,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hb6,8'h91,8'h91,8'h00,8'h00,8'hb6,8'h6d,8'h6d,8'h6d,8'h6d,8'h00,8'h6d,8'h6d,8'h6d,8'h6d,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hb6,8'hda,8'hda,8'hb6,8'hda,8'hb6,8'h6d,8'h00,8'h00,8'h6d,8'hda,8'hb6,8'hda,8'hda,8'hb6,8'h6d,8'h00,8'h00,8'hb6,8'hb6,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h91,8'hb6,8'hda,8'hb6,8'hb6,8'h91,8'h6d,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h6d,8'h00,8'hda,8'hda,8'hb6,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h91,8'hb6,8'h91,8'h91,8'h91,8'hda,8'hb6,8'hb6,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h00,8'hb6,8'hb6,8'h91,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hb6,8'h91,8'h91,8'h91,8'h91,8'h6d,8'h00,8'h00,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h91,8'h00,8'hb6,8'h91,8'hb6,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hb6,8'hb6,8'h91,8'h91,8'hb6,8'h91,8'hb6,8'hb6,8'h00,8'h6d,8'hb6,8'h91,8'hb6,8'h91,8'hb6,8'h91,8'h00,8'hda,8'hb6,8'hb6,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}
},

// full wall bitmap
{{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hb6,8'h91,8'h6d,8'h6d,8'hda,8'h91,8'h91,8'hb6,8'hb6,8'h24,8'hff,8'hda,8'hb6,8'hb6,8'hda,8'h24,8'hda,8'h91,8'h6d,8'h6d,8'hda,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hb6,8'h91,8'hb6,8'hda,8'h6d,8'hb6,8'h91,8'h6d,8'hda,8'h24,8'hff,8'hb6,8'hb6,8'h91,8'h91,8'h91,8'hb6,8'h91,8'hb6,8'h91,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hb6,8'hb6,8'h6d,8'hb6,8'h24,8'h91,8'hb6,8'h91,8'hb6,8'h24,8'hff,8'hb6,8'h91,8'hb6,8'hb6,8'h91,8'hb6,8'hb6,8'hb6,8'h91,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h91,8'hb6,8'hb6,8'hb6,8'hb6,8'h91,8'h91,8'hb6,8'hff,8'h24,8'hda,8'hb6,8'hda,8'h6d,8'h91,8'h91,8'hda,8'hb6,8'hda,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h6d,8'h24,8'hff,8'hda,8'hff,8'hb6,8'h91,8'h91,8'h91,8'hb6,8'hb6,8'h91,8'h91,8'hb6,8'hb6,8'h91,8'hff,8'h24,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h6d,8'hb6,8'h6d,8'hb6,8'hda,8'hda,8'hb6,8'hb6,8'hda,8'h91,8'hda,8'hda,8'hb6,8'hda,8'hb6,8'hda,8'h24,8'h91,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h6d,8'h6d,8'h6d,8'h91,8'h91,8'hb6,8'hb6,8'hb6,8'h91,8'h91,8'hb6,8'hb6,8'h91,8'hff,8'h6d,8'h91,8'hb6,8'h24,8'h91,8'hb6,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h6d,8'h6d,8'h24,8'h6d,8'h91,8'h91,8'h91,8'hb6,8'h91,8'h91,8'hb6,8'h6d,8'hb6,8'hb6,8'h6d,8'hb6,8'h6d,8'h6d,8'h91,8'hb6,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h6d,8'h6d,8'h24,8'hb6,8'hda,8'h91,8'h91,8'h91,8'h91,8'hb6,8'h91,8'hb6,8'hda,8'h6d,8'h6d,8'h91,8'h91,8'h24,8'h91,8'h91,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h6d,8'hb6,8'hb6,8'h91,8'h91,8'hb6,8'h91,8'h91,8'h6d,8'hb6,8'hb6,8'h6d,8'h91,8'h91,8'h91,8'h24,8'h91,8'hda,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h00,8'h91,8'h6d,8'h6d,8'h6d,8'h91,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'hda,8'h6d,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'h91,8'hb6,8'h6d,8'h00,8'h6d,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h91,8'h00,8'h24,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'h6d,8'hff,8'hda,8'hda,8'hb6,8'hda,8'hda,8'hda,8'hda,8'hda,8'hda,8'hb6,8'hb6,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hb6,8'hb6,8'h91,8'hb6,8'h91,8'hda,8'hb6,8'h6d,8'hff,8'h91,8'h91,8'hda,8'hda,8'h6d,8'h6d,8'hda,8'h6d,8'hb6,8'h6d,8'h91,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hb6,8'h91,8'hb6,8'h6d,8'hb6,8'h91,8'hb6,8'h6d,8'hff,8'h91,8'hb6,8'hb6,8'hb6,8'hda,8'hb6,8'hb6,8'hb6,8'h91,8'hb6,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hb6,8'hb6,8'hda,8'hb6,8'h91,8'h6d,8'hb6,8'h6d,8'hff,8'hb6,8'h91,8'hb6,8'hb6,8'h91,8'h91,8'hb6,8'hda,8'h91,8'h6d,8'hb6,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h91,8'h91,8'hb6,8'h91,8'hb6,8'hda,8'hb6,8'h6d,8'hff,8'h6d,8'h91,8'h91,8'hda,8'hb6,8'hb6,8'h91,8'h6d,8'hb6,8'h91,8'hb6,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hb6,8'h91,8'hb6,8'hda,8'h6d,8'h91,8'hda,8'h6d,8'hff,8'h91,8'h91,8'h6d,8'h91,8'hb6,8'hb6,8'h91,8'hb6,8'hb6,8'h91,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h24,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h91,8'h91,8'hda,8'h91,8'h6d,8'h6d,8'h6d,8'hda,8'hb6,8'h6d,8'h91,8'h91,8'h91,8'h6d,8'h6d,8'h91,8'h91,8'hff,8'hb6,8'h6d,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h91,8'h91,8'hda,8'h91,8'hb6,8'hb6,8'hb6,8'hb6,8'h6d,8'h91,8'h91,8'h91,8'hb6,8'h6d,8'h91,8'hb6,8'h91,8'hb6,8'hb6,8'h91,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h91,8'hb6,8'hb6,8'h91,8'h91,8'hb6,8'h91,8'hda,8'h91,8'h91,8'hb6,8'hb6,8'hb6,8'h24,8'hb6,8'hb6,8'h91,8'hb6,8'h24,8'hda,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hb6,8'h91,8'h91,8'h91,8'hb6,8'h91,8'hb6,8'hb6,8'h91,8'h91,8'h91,8'h91,8'h91,8'hda,8'hb6,8'h91,8'h91,8'hb6,8'h91,8'hb6,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}
}};
 
//////////--------------------------------------------------------------------------------------------------------------= 

// pipeline (ff) to get the pixel color from the array 	 

//----------------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00 ;
		MazeBitMapMask <= starting_MazeBitMapMask ;
		pick_another_flag <= 1'b0 ;
	end // resetN
	
	else begin
		// defaults
		RGBout <= TRANSPARENT_ENCODING ; 
		MazeBitMapMask <= MazeBitMapMask ;
		pick_another_flag <= 1'b0 ;
		// end of defaults
		
		// decide wich wall to place
		if (InsideRectangle == 1'b1 ) begin
			case (MazeBitMapMask[OffsetY[8:5]][OffsetX[9:5]])
				3'h02 : RGBout <= object_colors [1][OffsetY[4:0]][OffsetX[4:0]] ; // place a full wall
				3'h01 : RGBout <= object_colors [0][OffsetY[4:0]][OffsetX[4:0]] ;	// place a crakced wall
				default: RGBout <= TRANSPARENT_ENCODING ;
			endcase
		end
		
		// set the conditions to break walls
		if ( breakWall_pulse && breakWall_in_bound ) begin		// if pacman uses the hammer
				case (MazeBitMapMask[breakWallOffsetY[8:5]][breakWallOffsetX[9:5]])
					3'h02 : MazeBitMapMask[breakWallOffsetY[8:5]][breakWallOffsetX[9:5]] <= 3'h01 ;	// full wall becomes cracked wall
					3'h01 : MazeBitMapMask[breakWallOffsetY[8:5]][breakWallOffsetX[9:5]] <= 3'h00 ;	// cracked wall disapears
					default: MazeBitMapMask[breakWallOffsetY[8:5]][breakWallOffsetX[9:5]] <= 
											MazeBitMapMask[breakWallOffsetY[8:5]][breakWallOffsetX[9:5]] ;	// stays the same																														
				endcase
		end // breakWall pulse
		else  MazeBitMapMask[breakWallOffsetY[8:5]][breakWallOffsetX[9:5]] <= 
											MazeBitMapMask[breakWallOffsetY[8:5]][breakWallOffsetX[9:5]] ;	// stays the same
											
		
		// set the conditions to add a random wall to the game
		if ( randomWallSetPulse	|| pick_another_flag ) begin	
			if (MazeBitMapMask[Y_adjustment[3:0]][randomMapLocationX[4:0]] == 0) begin
				MazeBitMapMask[Y_adjustment[3:0]][randomMapLocationX[4:0]] <= randomWall;
				pick_another_flag <= 1'b0 ;
			end
			
			else pick_another_flag <= 1'b1;

		end // randomWallSetPulse || pick_another_flag
	
		
	end // resetN: else statement
end // always_ff

//==----------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 

assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   

endmodule
