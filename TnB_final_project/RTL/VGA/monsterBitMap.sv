// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2021
// (c) Technion IIT, Department of Electrical Engineering 2021 



module	monsterBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic shiftImage,	// changes how the monsters apears
					
					// tracker monster inputs
					input logic	[10:0] offsetX_tracker, // offset from top left position 
					input logic	[10:0] offsetY_tracker,
					input	logic	InsideRectangle_tracker, //input that the pixel is within a bracket
					
					// random straight lines monster inputs
					input logic	[10:0] offsetX_randomS, // offset from top left position 
					input logic	[10:0] offsetY_randomS,
					input	logic	InsideRectangle_randomS, //input that the pixel is within a bracket
					
					// random diagonal monster inputs
					input logic	[10:0] offsetX_randomD, // offset from top left position 
					input logic	[10:0] offsetY_randomD,
					input	logic	InsideRectangle_randomD, //input that the pixel is within a bracket	
					
					// tracker monster outputs
					output	logic	drawingRequest_tracker, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout_tracker,  //rgb value from the bitmap 
					output	logic	[3:0] HitEdgeCode_tracker, //one bit per edge 
					
					// random straight lines monster outputs
					output	logic	drawingRequest_randomS, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout_randomS,  //rgb value from the bitmap 
					
					// random diagonal monster outputs
					output	logic	drawingRequest_randomD, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout_randomD  //rgb value from the bitmap 
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

localparam logic [7:0] TRANSPARENT_ENCODING = 8'h00 ; // RGB value in the bitmap representing a transparent pixel 


logic [0:OBJECT_HEIGHT_Y-1] [0:OBJECT_WIDTH_X-1] [7:0] object_colors = {
	{{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfe,8'hfe,8'hfe,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfe,8'hfe,8'hfe,8'hfe,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hff,8'hff,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfe,8'hfe,8'hfe,8'h06,8'h06,8'h06,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hfe,8'hfe,8'hfe,8'h06,8'h06,8'h06,8'hfe,8'hff,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfe,8'hfe,8'hfe,8'hfe,8'h06,8'h06,8'h06,8'hfe,8'hff,8'hff,8'hff,8'hfe,8'hfe,8'hfe,8'hfe,8'h06,8'h06,8'h06,8'hfe,8'hff,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfe,8'hfe,8'hfe,8'hfe,8'h06,8'h06,8'h06,8'hfe,8'hff,8'hff,8'hff,8'hfe,8'hfe,8'hfe,8'hfe,8'h06,8'h06,8'h06,8'hfe,8'hff,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hff,8'hff,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfd,8'hfe,8'hfe,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfe,8'hfe,8'hfe,8'hfe,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'hff,8'hff,8'h00,8'h00,8'h00},
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
		HitEdgeCode_tracker <= 4'h0;
		RGBout_tracker <=	8'h00;
		RGBout_randomS <=	8'h00;
		RGBout_randomD <=	8'h00;

	end // reset

	else begin
		// defaults
		HitEdgeCode_tracker <= 4'h0;
		RGBout_tracker <= TRANSPARENT_ENCODING ;  
		RGBout_randomS <= TRANSPARENT_ENCODING ;
		RGBout_randomD <= TRANSPARENT_ENCODING ;
		// end of defaults
		
		if (InsideRectangle_tracker == 1'b1 ) begin  // inside an external bracket 
			HitEdgeCode_tracker <= hit_colors[offsetY_tracker >> OBJECT_HEIGHT_Y_DIVIDER][offsetX_tracker >> OBJECT_WIDTH_X_DIVIDER];	//get hitting edge from the colors table  
			if (shiftImage == 1'b1) begin
				RGBout_tracker <= ( object_colors[offsetY_tracker][offsetX_tracker] == 8'h06 ) ?		// if drawing the eyes
										object_colors[offsetY_tracker][offsetX_tracker] << 5 :				// make them red
										object_colors[offsetY_tracker][offsetX_tracker] ;
			end // shiftImage
			
			else RGBout_tracker <= ( object_colors[offsetY_tracker][offsetX_tracker] == 8'hff ) ?
										object_colors[offsetY_tracker][offsetX_tracker] << 3 :	// yellow color
										object_colors[offsetY_tracker][offsetX_tracker] ;
		end //InsideRectangle_tracker
		
		if (InsideRectangle_randomS == 1'b1) begin	// inside an external bracket
			if (shiftImage == 1'b1) begin
				RGBout_randomS <= ( object_colors[offsetY_randomS][offsetX_randomS] == 8'h06 ) ?		// if drawing the eyes
										object_colors[offsetY_randomS][offsetX_randomS] << 5 :				// make them red
										object_colors[offsetY_randomS][offsetX_randomS] ;
			end // shiftImage
			
			else RGBout_randomS <= ( object_colors[offsetY_randomS][offsetX_randomS] == 8'hff ) ?
										object_colors[offsetY_randomS][offsetX_randomS] << 5 :	// red color
										object_colors[offsetY_randomS][offsetX_randomS] ;	
		end //InsideRectangle_randomS
		
		if (InsideRectangle_randomD == 1'b1) begin	// inside an external bracket
			if (shiftImage == 1'b1) begin
				RGBout_randomD <= ( object_colors[offsetY_randomD][offsetX_randomD] == 8'h06 ) ?		// if drawing the eyes
										object_colors[offsetY_randomD][offsetX_randomD] << 5 :				// make them red
										object_colors[offsetY_randomD][offsetX_randomD] ;
			end // shiftImage
			
			else RGBout_randomD <= ( object_colors[offsetY_randomD][offsetX_randomD] == 8'hff ) ?
										object_colors[offsetY_randomD][offsetX_randomD] >> 4 :	// blue color
										object_colors[offsetY_randomD][offsetX_randomD] ;
		end //InsideRectangle_randomD
		
	end // else- resetN
		
end // always_ff

//////////--------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest_tracker = ( RGBout_tracker != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap  
assign drawingRequest_randomS = ( RGBout_randomS != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap 
assign drawingRequest_randomD = ( RGBout_randomD != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap  

endmodule