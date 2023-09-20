
// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018

//-- Eyal Lev 31 Jan 2021

module	objects_mux	(	 	
					input		logic	clk,
					input		logic	resetN, 
					
					//------------- pacman --------------//
					input		logic	smileyDrawingRequest, 
					input		logic	[7:0] smileyRGB,  
					
					//------------- coins & powerups --------------//
					input    logic CoinDrawingRequest,
					input		logic	[7:0] CoinRGB,   
					
					//------------- random walls --------------//
					input		logic	[7:0] randomWallRGB, 
					input		logic	randomWallDrawingRequest, 
					
					//------------- MIF --------------//
					input		logic	[7:0] RGB_MIF, 
					
					//------------- monsters --------------//
					input		logic	MonsterDrawingRequest, 
					input		logic	[7:0] MonsterRGB,
					
					input		logic	Monster_randomDrawingRequest, 
					input		logic	[7:0] Monster_randomRGB,
					
					input		logic	MonsterDiagonal_randomDrawingRequest, 
					input		logic	[7:0] MonsterDiagonal_randomRGB,
					
					//------------- score --------------//
					input 	logic NumdrawingRequest, 
					input 	logic [7:0] NumRGB,
					
					input 	logic Num_tensdrawingRequest, 
					input 	logic [7:0] Num_tensRGB,
					
					input 	logic Num_hundredsdrawingRequest, 
					input 	logic [7:0] Num_hundredsRGB,
					
					//------------- time --------------//
					input		logic countH_DrawingRequest,
					input		logic	[7:0] countH_RGB,
					
					input		logic countM_DrawingRequest,
					input		logic	[7:0] countM_RGB,
					
					input		logic countL_DrawingRequest,
					input		logic	[7:0] countL_RGB,
					
					//------------- screens --------------//
					input		logic	OpeningScreenDrawingRequest, 
					input		logic	[7:0] OpeningScreenRGB,
					
					input		logic	EndingScreenDrawingRequest, 
					input		logic	[7:0] EndingScreenRGB,
					
					//------------- output --------------//
				   output	logic	[7:0] RGBOut
);


/*----------------------

priority order:
	1. opening screen
	2. ending screen
	3. score
	4. timer
	5. monsters
	6. pacman
	7. random walls
	8. coins & powerups
	9. MIF

----------------------*/

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
		
		else begin
			// 1. opening screen
			if (OpeningScreenDrawingRequest == 1'b1)
				RGBOut <= OpeningScreenRGB;
			
			// 2. ending screen
			else if (EndingScreenDrawingRequest == 1'b1)
				RGBOut <= EndingScreenRGB;
			
			// 3. score
			else if (Num_tensdrawingRequest == 1'b1)
				RGBOut <= Num_tensRGB;
			else if (Num_hundredsdrawingRequest == 1'b1)
				RGBOut <= Num_hundredsRGB;
			else if (NumdrawingRequest == 1'b1)
				RGBOut <= NumRGB;
			
			// 4. timer
			else if (countH_DrawingRequest == 1'b1 )   
				RGBOut <= countH_RGB; 
			
			else if (countM_DrawingRequest == 1'b1 )   
				RGBOut <= countM_RGB;
			
			else if (countL_DrawingRequest == 1'b1 )
				RGBOut <= countL_RGB;
			
			// 5. monsters
			else if (MonsterDrawingRequest == 1'b1 )   
				RGBOut <= MonsterRGB;  
			else if (Monster_randomDrawingRequest == 1'b1 )   
				RGBOut <= Monster_randomRGB;   
			else if (MonsterDiagonal_randomDrawingRequest == 1'b1 )   
				RGBOut <= MonsterDiagonal_randomRGB;

			// 6. pacman
			else if (smileyDrawingRequest == 1'b1 )   
				RGBOut <= smileyRGB; 
				
			// 7. random walls
			else if (randomWallDrawingRequest == 1'b1)
					RGBOut <= randomWallRGB ;
			
			// 8. coins & powerups
			else if (CoinDrawingRequest == 1'b1)
					RGBOut <= CoinRGB;	
			
			else RGBOut <= RGB_MIF ;// 9. MIF
		end ;
end // always_ff

endmodule
