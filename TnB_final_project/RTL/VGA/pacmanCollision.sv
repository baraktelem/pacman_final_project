
 
 module pacmanCollision (

					input	logic	clk, 
					input	logic	resetN, 
					input logic	[10:0] topLeftX,// offset from top left  position 
					input logic	[10:0] topLeftY, 
					input	logic [1:0] face_direction,
					input logic [10:0] pixelX,
					input logic [10:0] pixelY,

					output 	logic pacmanCollisionReq

 ) ; 

localparam logic [1:0] FACE_LEFT = 2'b10;
localparam logic [1:0] FACE_UP = 2'b11;
localparam logic [1:0] FACE_RIGHT = 2'b01;
localparam logic [1:0] FACE_DOWN = 2'b00; 
parameter  int object_width_x = 30;
parameter  int object_height_y = 30;
parameter int space = 2;

// this unit is in charge to warn the control unit about incoming collisions
// it checks where pacman is going to be

logic insideY;
logic insideX; 
 
logic rightCollision;
logic leftCollision;
logic upCollision;
logic downCollision;

// checks if pacman is going to be in the current pixcel next start of frame 
assign insiderightY = (pixelY > topLeftY && (pixelY < topLeftY + object_height_y));
assign insiderightX = (pixelX == (topLeftX +space + object_width_x));

assign insideleftY = (pixelY > topLeftY && (pixelY < topLeftY + object_height_y));
assign insideleftX = (pixelX == (topLeftX - space));

assign insideupY =  (pixelY == (topLeftY - space));
assign insideupX = ((pixelX >topLeftX) && (pixelX < topLeftX + object_width_x));

assign insidedownY = (pixelY == (topLeftY + space + object_height_y));
assign insidedownX = ((pixelX >topLeftX) && (pixelX < topLeftX + object_width_x));


assign rightCollision = ((insiderightX)&& (insiderightY));
assign leftCollision = ((insideleftX)&& (insideleftY));
assign upCollision = ((insideupY)&& (insideupX));
assign downCollision = ((insidedownY)&& (insidedownX));

 
//////////--------------------------------------------------------------------------------------------------------------= 
 
// collect the check from all sides
assign pacmanCollisionReq = (rightCollision && (face_direction == FACE_RIGHT))||(leftCollision && (face_direction == FACE_LEFT))||(upCollision && (face_direction == FACE_UP))||(downCollision && (face_direction == FACE_DOWN));
 
endmodule 
