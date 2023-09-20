//
// coding convention dudy December 2018
// (c) Technion IIT, Department of Electrical Engineering 2021
// generating a number bitmap 



module NumbersBitMap	(	
					input		logic	clk,
					input		logic	resetN,
					input 	logic	[10:0] offsetX_score_ones,// offset from top left position 
					input 	logic	[10:0] offsetY_score_ones,
					input		logic	InsideRectangle_score_ones, //input that the pixel is within a bracket 
					input 	logic	[10:0] offsetX_score_tens,// offset from top left position 
					input 	logic	[10:0] offsetY_score_tens,
					input		logic	InsideRectangle_score_tens, //input that the pixel is within a bracket 
					input 	logic	[10:0] offsetX_score_hundreds,// offset from top left position 
					input 	logic	[10:0] offsetY_score_hundreds,
					input		logic	InsideRectangle_score_hundreds, //input that the pixel is within a bracket 
					input 	logic	[3:0] digit_score_ones, // digit to display
					input 	logic	[3:0] digit_score_tens, // digit to display
					input 	logic	[3:0] digit_score_hundreds, // digit to display
					
					input 	logic	[10:0] offsetX_time_ones,// offset from top left position 
					input 	logic	[10:0] offsetY_time_ones,
					input		logic	InsideRectangle_time_ones, //input that the pixel is within a bracket 
					input 	logic	[10:0] offsetX_time_tens,// offset from top left position 
					input 	logic	[10:0] offsetY_time_tens,
					input		logic	InsideRectangle_time_tens, //input that the pixel is within a bracket 
					input 	logic	[10:0] offsetX_time_hundreds,// offset from top left position 
					input 	logic	[10:0] offsetY_time_hundreds,
					input		logic	InsideRectangle_time_hundreds, //input that the pixel is within a bracket 
					input 	logic	[3:0] digit_time_ones, // digit to display
					input 	logic	[3:0] digit_time_tens, // digit to display
					input 	logic	[3:0] digit_time_hundreds, // digit to display
					
					output	logic				drawingRequest_score_ones, //output that the pixel should be dispalyed 
					output	logic	[7:0]		RGBout_score_ones,
					output	logic				drawingRequest_score_tens, //output that the pixel should be dispalyed 
					output	logic	[7:0]		RGBout_score_tens,
					output	logic				drawingRequest_score_hundreds, //output that the pixel should be dispalyed 
					output	logic	[7:0]		RGBout_score_hundreds,
					
					output	logic				drawingRequest_time_ones, //output that the pixel should be dispalyed 
					output	logic	[7:0]		RGBout_time_ones,
					output	logic				drawingRequest_time_tens, //output that the pixel should be dispalyed 
					output	logic	[7:0]		RGBout_time_tens,
					output	logic				drawingRequest_time_hundreds, //output that the pixel should be dispalyed 
					output	logic	[7:0]		RGBout_time_hundreds
);
// generating a smily bitmap 

parameter  logic	[7:0] digit_color = 8'hff ; //set the color of the digit 


bit [0:9] [0:31] [0:15] number_bitmap  = {


{16'b	0000001111100000,
16'b	0000111111111000,
16'b	0000111111111000,
16'b	0001111111111100,
16'b	0011111001111100,
16'b	0011100000111110,
16'b	0111100000011110,
16'b	0111100000011110,
16'b	1111100000011111,
16'b	1111000000001111,
16'b	1111000000001111,
16'b	1111000000001111,
16'b	1111000000001111,
16'b	1111000000001111,
16'b	1111000000001111,
16'b	1111000000001111,
16'b	1111000000001111,
16'b	1111000000001111,
16'b	1111000000001111,
16'b	1111000000001111,
16'b	1111000000001111,
16'b	1111000000001111,
16'b	1111000000001111,
16'b	1111000000011110,
16'b	1111100000011110,
16'b	0111110000111110,
16'b	0111110000111100,
16'b	0011111001111100,
16'b	0011111111111000,
16'b	0001111111111000,
16'b	0000111111110000,
16'b	0000011111000000},


																	
{16'b	0000000011100000,
16'b	0000000111100000,
16'b	0000011111100000,
16'b	0000111111100000,
16'b	0001111111100000,
16'b	0011111111100000,
16'b	0111111011100000,
16'b	0111100011100000,
16'b	0111000011100000,
16'b	0010000011100000,
16'b	0000000011100000,
16'b	0000000011100000,
16'b	0000000011100000,
16'b	0000000011100000,
16'b	0000000011100000,
16'b	0000000011100000,
16'b	0000000011100000,
16'b	0000000011100000,
16'b	0000000011100000,
16'b	0000000011100000,
16'b	0000000011100000,
16'b	0000000011100000,
16'b	0000000011100000,
16'b	0000000011100000,
16'b	0000000011100000,
16'b	0000000011100000,
16'b	0000000011100000,
16'b	0000000011100000,
16'b	0111111111111111,
16'b	0111111111111111,
16'b	0111111111111111,
16'b	0111111111111111},
																	
{16'b	0000111111100000,
16'b	0001111111110000,
16'b	0111111111111000,
16'b	1111111111111000,
16'b	1111110011111100,
16'b	1111000011111100,
16'b	1110000001111110,
16'b	0000000000111110,
16'b	0000000000111110,
16'b	0000000000111110,
16'b	0000000000111100,
16'b	0000000001111100,
16'b	0000000001111100,
16'b	0000000001111000,
16'b	0000000011111000,
16'b	0000000011111000,
16'b	0000000011111000,
16'b	0000000011110000,
16'b	0000000011100000,
16'b	0000000111000000,
16'b	0000001111000000,
16'b	0000011110000000,
16'b	0000111100000000,
16'b	0001111100000000,
16'b	0001111100000000,
16'b	0011111000000000,
16'b	0111110000000001,
16'b	1111100000000011,
16'b	1111111111111111,
16'b	1111111111111111,
16'b	1111111111111111,
16'b	1111111111111111},
																	
{16'b	0000111111100000,
16'b	0001111111111000,
16'b	0111111111111000,
16'b	1111111111111000,
16'b	1111110011111100,
16'b	1111000001111100,
16'b	1110000001111100,
16'b	0000000000111110,
16'b	0000000000111100,
16'b	0000000000111100,
16'b	0000000000111100,
16'b	0000000001111100,
16'b	0000000011111000,
16'b	0000000011111000,
16'b	0001111111110000,
16'b	0001111111000000,
16'b	0001111111111000,
16'b	0001111111111000,
16'b	0000000011111100,
16'b	0000000001111110,
16'b	0000000000111111,
16'b	0000000000011111,
16'b	0000000000011111,
16'b	0000000000011111,
16'b	0000000000011111,
16'b	0000000000111111,
16'b	1110000001111110,
16'b	1111100011111110,
16'b	1111111111111100,
16'b	1111111111111000,
16'b	0111111111111000,
16'b	0001111111000000},
																	
{16'b	0000000011111000,
16'b	0000000011111000,
16'b	0000000011111000,
16'b	0000000011111000,
16'b	0000000111111000,
16'b	0000001111111000,
16'b	0000001101111000,
16'b	0000011101111000,
16'b	0000011101111000,
16'b	0000111101111000,
16'b	0001111101111000,
16'b	0001111101111000,
16'b	0001111001111000,
16'b	0011111001111000,
16'b	0011110001111000,
16'b	0111100001111000,
16'b	0111100001111000,
16'b	1111000001111000,
16'b	1110000001111000,
16'b	1110000001111000,
16'b	1110000001111000,
16'b	1111111111111111,
16'b	1111111111111111,
16'b	1111111111111111,
16'b	0000000001111000,
16'b	0000000001111000,
16'b	0000000001111000,
16'b	0000000001111000,
16'b	0000000001111000,
16'b	0000000001111000,
16'b	0000000001111000,
16'b	0000000011111100},
																	
{16'b	0111111111111111,
16'b	0111111111111111,
16'b	0111111111111110,
16'b	0111111111111100,
16'b	0111100000000000,
16'b	0111100000000000,
16'b	0111100000000000,
16'b	0111100000000000,
16'b	0111100000000000,
16'b	0111100000000000,
16'b	0111100000000000,
16'b	0111111111100000,
16'b	0111111111111000,
16'b	0111111111111000,
16'b	0111111111111100,
16'b	0010000011111110,
16'b	0000000001111110,
16'b	0000000000111111,
16'b	0000000000011111,
16'b	0000000000011111,
16'b	0000000000001111,
16'b	0000000000001111,
16'b	0000000000001111,
16'b	0000000000011111,
16'b	0000000000011111,
16'b	1000000000111110,
16'b	1100000001111110,
16'b	1111100011111100,
16'b	1111111111111000,
16'b	1111111111111000,
16'b	1111111111110000,
16'b	0001111111000000},
																	
{16'b	0000000111111100,
16'b	0000011111111110,
16'b	0000111111111110,
16'b	0001111111111111,
16'b	0001111100001111,
16'b	0011111100000001,
16'b	0011111000000000,
16'b	0111110000000000,
16'b	0111100000000000,
16'b	1111100000000000,
16'b	1111000000000000,
16'b	1111000000000000,
16'b	1111000000000000,
16'b	1111001111111000,
16'b	1111111111111100,
16'b	1111111111111110,
16'b	1111111111111111,
16'b	1111111101111111,
16'b	1111100000011111,
16'b	1111000000001111,
16'b	1111000000000111,
16'b	1111000000000111,
16'b	1111000000000111,
16'b	1111000000000111,
16'b	1111100000001111,
16'b	1111100000001111,
16'b	0111110000011111,
16'b	0111111101111110,
16'b	0011111111111110,
16'b	0001111111111100,
16'b	0001111111111000,
16'b	0000011111100000},
																	
{16'b	1111111111111111,
16'b	1111111111111111,
16'b	1111111111111111,
16'b	1111111111111111,
16'b	1100000000001111,
16'b	1000000000011111,
16'b	0000000000011111,
16'b	0000000000011110,
16'b	0000000000111110,
16'b	0000000000111100,
16'b	0000000001111100,
16'b	0000000001111000,
16'b	0000000011111000,
16'b	0000000011111000,
16'b	0000000011111000,
16'b	0000000011111000,
16'b	0000000011110000,
16'b	0000000011110000,
16'b	0000000011100000,
16'b	0000000011100000,
16'b	0000000111100000,
16'b	0000000111100000,
16'b	0000001111000000,
16'b	0000001111000000,
16'b	0000011110000000,
16'b	0000011110000000,
16'b	0000111110000000,
16'b	0000111100000000,
16'b	0000111100000000,
16'b	0001111100000000,
16'b	0001111100000000,
16'b	0001111100000000},
																	
{16'b	0000111111110000,
16'b	0001111111111000,
16'b	0011111111111100,
16'b	0111111111111110,
16'b	0111111011111110,
16'b	1111100000111111,
16'b	1111100000011111,
16'b	1111000000001111,
16'b	1111000000001111,
16'b	1111000000001111,
16'b	1111100000011110,
16'b	0111110000111110,
16'b	0111111001111100,
16'b	0011111111111000,
16'b	0001111111111000,
16'b	0000111111100000,
16'b	0000111111110000,
16'b	0001111111111000,
16'b	0011111111111100,
16'b	0111111001111110,
16'b	1111100000111111,
16'b	1111000000001111,
16'b	1110000000001111,
16'b	1110000000000111,
16'b	1110000000000111,
16'b	1111000000001111,
16'b	1111100000011111,
16'b	1111111001111111,
16'b	1111111111111110,
16'b	0111111111111110,
16'b	0011111111111000,
16'b	0001111111110000},
																	
{16'b	0000111111100000,
16'b	0001111111111000,
16'b	0011111111111000,
16'b	0111111111111100,
16'b	1111111011111100,
16'b	1111100000111110,
16'b	1111000000011110,
16'b	1111000000011111,
16'b	1110000000001111,
16'b	1110000000001111,
16'b	1110000000001111,
16'b	1110000000001111,
16'b	1111000000001111,
16'b	1111100000011111,
16'b	1111111011111111,
16'b	1111111111111111,
16'b	0111111111111111,
16'b	0011111111111111,
16'b	0001111111001111,
16'b	0000000000001111,
16'b	0000000000001111,
16'b	0000000000001111,
16'b	0000000000011110,
16'b	0000000000011110,
16'b	0000000000111110,
16'b	0000000001111100,
16'b	1000000011111100,
16'b	1111000011111000,
16'b	1111111111111000,
16'b	1111111111110000,
16'b	1111111111100000,
16'b	0011111100000000},

} ; 
																	
	


// pipeline (ff) to get the pixel color from the array 	 

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		drawingRequest_score_ones <=	1'b0;
		drawingRequest_score_tens <=	1'b0;
		drawingRequest_score_hundreds <=	1'b0;
		
		drawingRequest_time_ones <=	1'b0;
		drawingRequest_time_tens <=	1'b0;
		drawingRequest_time_hundreds <=	1'b0;
	end
	else begin
		drawingRequest_score_ones <=	1'b0;
		drawingRequest_score_tens <=	1'b0;
		drawingRequest_score_hundreds <=	1'b0;
		
		drawingRequest_time_ones <=	1'b0;
		drawingRequest_time_tens <=	1'b0;
		drawingRequest_time_hundreds <=	1'b0;
	
		// score display
		if (InsideRectangle_score_ones == 1'b1 )
			drawingRequest_score_ones <= (number_bitmap[digit_score_ones][offsetY_score_ones][offsetX_score_ones]);	//get value from bitmap 
		
		else if (InsideRectangle_score_tens == 1'b1)
			drawingRequest_score_tens <= (number_bitmap[digit_score_tens][offsetY_score_tens][offsetX_score_tens]);	//get value from bitmap
		
		else if (InsideRectangle_score_hundreds == 1'b1)
			drawingRequest_score_hundreds <= (number_bitmap[digit_score_hundreds][offsetY_score_hundreds][offsetX_score_hundreds]);	//get value from bitmap
		
		// time display
		else if (InsideRectangle_time_ones == 1'b1 )
			drawingRequest_time_ones <= (number_bitmap[digit_time_ones][offsetY_time_ones][offsetX_time_ones]);	//get value from bitmap 
		
		else if (InsideRectangle_time_tens == 1'b1)
			drawingRequest_time_tens <= (number_bitmap[digit_time_tens][offsetY_time_tens][offsetX_time_tens]);	//get value from bitmap
		
		else if (InsideRectangle_time_hundreds == 1'b1)
			drawingRequest_time_hundreds <= (number_bitmap[digit_time_hundreds][offsetY_time_hundreds][offsetX_time_hundreds]);	//get value from bitmap
		
	end // reset else
end // always_ff

assign RGBout_score_ones = digit_color ; // this is a fixed color 
assign RGBout_score_tens = digit_color ; // this is a fixed color 
assign RGBout_score_hundreds = digit_color ; // this is a fixed color 

assign RGBout_time_ones = digit_color ; // this is a fixed color 
assign RGBout_time_tens = digit_color ; // this is a fixed color 
assign RGBout_time_hundreds = digit_color ; // this is a fixed color 

endmodule