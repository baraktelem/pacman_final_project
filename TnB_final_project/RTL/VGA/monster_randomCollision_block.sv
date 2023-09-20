module monster_randomCollision_block (
    input logic clk, 
    input logic resetN, 
    input logic [10:0] topLeftX, // offset from top left position 
    input logic [10:0] topLeftY, 
    input logic [1:0] random_move,
    input logic [10:0] pixelX,
    input logic [10:0] pixelY,
    output logic [1:0] monsterRandomCollisionReq, 
	 output logic bool_monsterRandomCollision
);

parameter logic [1:0] RANDOM_DOWN = 2'b10;
parameter logic [1:0] RANDOM_UP = 2'b11;
parameter logic [1:0] RANDOM_LEFT = 2'b01;
parameter logic [1:0] RANDOM_RIGHT = 2'b00; 
parameter int object_width_x = 32;
parameter int object_height_y = 32;
parameter int space = 2;

logic insideY;
logic insideX; 
 
logic rightCollision;
logic leftCollision;
logic upCollision;
logic downCollision;
logic [1:0] temp_Random_Collision;

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


always_comb begin
    case (1'b1)
        rightCollision: temp_Random_Collision = RANDOM_RIGHT;
        leftCollision: temp_Random_Collision = RANDOM_LEFT;
        upCollision: temp_Random_Collision = RANDOM_UP;
        downCollision: temp_Random_Collision = RANDOM_DOWN;
        default: temp_Random_Collision = 2'b00; // Default value if no collision occurs
    endcase
end

assign monsterRandomCollisionReq = temp_Random_Collision;
assign bool_monsterRandomCollision = ((rightCollision) || (leftCollision) || (upCollision) || (downCollision));

endmodule
