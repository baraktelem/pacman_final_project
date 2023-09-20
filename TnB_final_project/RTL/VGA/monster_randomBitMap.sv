// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2021
// (c) Technion IIT, Department of Electrical Engineering 2021 



module	monster_randomBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket
					input logic shiftImage,	// changes how monster apears

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout,  //rgb value from the bitmap 
					output	logic	[3:0] HitEdgeCode //one bit per edge 
 ) ;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_NUMBER_OF_Y_BITS = 5;  // 2^5 = 32 
localparam  int OBJECT_NUMBER_OF_X_BITS = 5;  // 2^5 = 32 


localparam  int OBJECT_HEIGHT_Y = 1 <<  OBJECT_NUMBER_OF_Y_BITS ;
localparam  int OBJECT_WIDTH_X = 1 <<  OBJECT_NUMBER_OF_X_BITS;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_HEIGHT_Y_DIVIDER = OBJECT_NUMBER_OF_Y_BITS - 2; //how many pixel bits are in every collision pixel
localparam  int OBJECT_WIDTH_X_DIVIDER =  OBJECT_NUMBER_OF_X_BITS - 2;

// generating the monster bitmap

localparam logic [7:0] TRANSPARENT_ENCODING = 8'h00 ;// RGB value in the bitmap representing a transparent pixel 


logic [0:1] [0:OBJECT_HEIGHT_Y-1] [0:OBJECT_WIDTH_X-1] [7:0] object_colors = {
	{{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'hfe,8'hfe,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hfe,8'hfd,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'hfd,8'hfe,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hfc,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'hfc,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'hfd,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'hfd,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'hfc,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'hfc,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'hff,8'hff,8'hff,8'hff,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'hff,8'hff,8'hff,8'hff,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hfc,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h1c,8'hfc,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'hff,8'hff,8'hff,8'h06,8'h06,8'h06,8'hff,8'h1c,8'h1c,8'h1c,8'hfe,8'hff,8'hff,8'hff,8'h06,8'h06,8'h06,8'hfe,8'h1c,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'hfc,8'hff,8'hff,8'hff,8'h06,8'h06,8'h06,8'hff,8'h1c,8'h1c,8'h1c,8'hff,8'hff,8'hff,8'hff,8'h06,8'h06,8'h06,8'hff,8'h1c,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'hff,8'hff,8'hff,8'h06,8'h06,8'h06,8'hfd,8'h1c,8'h1c,8'h1c,8'h1c,8'hff,8'hff,8'hff,8'h06,8'h06,8'h06,8'hfd,8'h1c,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h1c,8'h1c,8'h1c,8'h1c,8'hfc,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h1c,8'h1c,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'hfd,8'hff,8'hff,8'hff,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'hff,8'hff,8'hff,8'hff,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'hd4,8'hfc,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'hf4,8'hf4,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'hf4,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'hd4,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'hda,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h1c,8'h1c,8'hd4,8'h00,8'h00,8'h00,8'h00,8'hd4,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'hd4,8'h1c,8'h1c,8'h1c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h1c,8'h1c,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hd5,8'hd4,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hd4,8'hf4,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hd5,8'hf4,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hda,8'hd4,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}
	},
	{{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h01,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h01,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h01,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h01,8'h02,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h01,8'h01,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h23,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h23,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h03,8'h03,8'h03,8'h03,8'h03,8'hff,8'hff,8'hff,8'hff,8'h03,8'h03,8'h03,8'h02,8'hff,8'hff,8'hff,8'h23,8'h03,8'h03,8'h03,8'h03,8'h03,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h03,8'h03,8'h03,8'h03,8'h03,8'hff,8'hff,8'hff,8'hff,8'h03,8'h03,8'h03,8'h03,8'hff,8'hff,8'hff,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'hff,8'hff,8'hff,8'hff,8'h03,8'h03,8'h03,8'h03,8'hff,8'hff,8'hff,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h02,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'hff,8'hff,8'hff,8'hff,8'h03,8'h03,8'h03,8'h03,8'hff,8'hff,8'hff,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h02,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h02,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h02,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h02,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h03,8'h03,8'h03,8'h03,8'hff,8'hff,8'hff,8'h02,8'h03,8'h03,8'h03,8'hff,8'hff,8'hff,8'hff,8'h03,8'h03,8'h03,8'hff,8'hff,8'hff,8'hff,8'h03,8'h03,8'h03,8'h02,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h03,8'h03,8'h03,8'h03,8'hff,8'hff,8'hff,8'h02,8'h03,8'h03,8'h03,8'hff,8'hff,8'hff,8'hff,8'h03,8'h03,8'h03,8'hff,8'hff,8'hff,8'hff,8'h03,8'h03,8'h03,8'h02,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h03,8'h03,8'hff,8'hff,8'h03,8'h03,8'h03,8'hff,8'hff,8'hff,8'hff,8'h03,8'h03,8'h03,8'h03,8'hff,8'hff,8'hff,8'h03,8'h03,8'h03,8'h03,8'hff,8'hff,8'h03,8'h02,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h03,8'h03,8'hff,8'hff,8'h03,8'h03,8'h03,8'hff,8'hff,8'hff,8'hff,8'h03,8'h03,8'h03,8'h03,8'hff,8'hff,8'hff,8'h03,8'h03,8'h03,8'h03,8'hff,8'hff,8'h03,8'h02,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h02,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h03,8'h02,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h03,8'h03,8'h03,8'h03,8'h00,8'h01,8'h03,8'h03,8'h03,8'h03,8'h03,8'h00,8'h00,8'h00,8'h00,8'h03,8'h03,8'h03,8'h03,8'h03,8'h00,8'h00,8'h03,8'h03,8'h03,8'h02,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h03,8'h03,8'h01,8'h01,8'h00,8'h00,8'h01,8'h03,8'h03,8'h03,8'h03,8'h00,8'h00,8'h00,8'h00,8'h03,8'h03,8'h03,8'h02,8'h01,8'h00,8'h00,8'h01,8'h02,8'h03,8'h02,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h03,8'h03,8'h00,8'h00,8'h00,8'h00,8'h00,8'h02,8'h03,8'h03,8'h03,8'h00,8'h00,8'h00,8'h00,8'h03,8'h03,8'h03,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h03,8'h02,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}
	}};


//////////--------------------------------------------------------------------------------------------------------------=
//hit bit map has one bit per edge:  hit_colors[3:0] =   {Left, Top, Right, Bottom}	
//there is one bit per edge, in the corner two bits are set  


logic [0:3] [0:3] [3:0] hit_colors = 
		  {16'hC446,     
			16'h8C62,    
			16'h8932,
			16'h9113};

 

// pipeline (ff) to get the pixel color from the array 	 

//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;
		HitEdgeCode <= 4'h0;

	end // reset

	else begin
		RGBout <= TRANSPARENT_ENCODING ; // default  
		HitEdgeCode <= 4'h0;

		if (InsideRectangle == 1'b1 ) 
		begin // inside an external bracket 
			HitEdgeCode <= hit_colors[offsetY >> OBJECT_HEIGHT_Y_DIVIDER][offsetX >> OBJECT_WIDTH_X_DIVIDER];	//get hitting edge from the colors table  
			RGBout <= object_colors[shiftImage][offsetY][offsetX];
		end // insideRectangle 	
	end // else
		
end // always_ff

//////////--------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = ( RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   

endmodule