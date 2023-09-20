
// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2021 
//updated --Eyal Lev 2021


module	collision_unit	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input	logic	drawing_request_Pacman,
			input	logic	drawing_request_RandomWall,
			input	logic	drawing_request_MIF,
			input	logic	drawing_request_Coins,
			input logic pacman_wall_collision_allert,
			input	logic	drawing_request_Monster,
			input	logic	drawing_request_Monster_random,
			input	logic	drawing_request_Monster_Diagonal_random,
			input logic breakWall_req,
			input logic [10:0] pacmanTopLeftX,
			input logic [10:0] pacmanTopLeftY,
			input logic [1:0] pacmanFaceDirection,
			input logic upScore,
			input logic playGame,
			
			output logic pacmanCollision, // active in case of collision between player and MIF or background
			output logic coinCollisionPulse,
			output logic monsterCollision,
			output logic monster_randomCollision,
			output logic monsterDiagonal_randomCollision,
			output logic monster_pacmanCollision,
			output logic breakWall_pulse_command,
			output logic [10:0] destroyWallPixelX,
			output logic [10:0] destroyWallPixelY,
			output logic [3:0] counter_ones,
			output logic [3:0] counter_tens,	
			output logic [3:0] counter_hundreds
);

// parameters used for hammer
localparam logic [1:0] PACMAN_FACE_LEFT = 2'b10;	// the direction pacman is facing
localparam logic [1:0] PACMAN_FACE_UP = 2'b11;
localparam logic [1:0] PACMAN_FACE_RIGHT = 2'b01;
localparam logic [1:0] PACMAN_FACE_DOWN = 2'b00;
localparam int REACH = 16;		// used to reach allign the loaction of break wall command

localparam int PACMAN_WIDTH_x = 32;
localparam int PACMAN_HEIGHT_Y = 32;


//-------------------------------------------------------
/* COLLISIONS SECTION */

assign pacmanCollision = (pacman_wall_collision_allert && 
							(drawing_request_RandomWall || drawing_request_MIF) ); // between pacman and walls
							
assign coinCollision = drawing_request_Coins && drawing_request_Pacman ;
						// between a coins, money bags, time boosts and pacman
						
assign monsterCollision = drawing_request_Monster && (drawing_request_RandomWall || drawing_request_MIF) ; // between monster and walls

assign monster_randomCollision = drawing_request_Monster_random && (drawing_request_RandomWall || drawing_request_MIF) ;

assign monsterDiagonal_randomCollision = drawing_request_Monster_Diagonal_random && (drawing_request_RandomWall || drawing_request_MIF) ;

assign monster_pacmanCollision = drawing_request_Pacman && ( drawing_request_Monster || 
												drawing_request_Monster_random || drawing_request_Monster_Diagonal_random ) ;


//-------------------------------------------------------
/* BREAK WALL SECTION */

// the purpose of this section is to decide which wall the pacman will break

logic breakWall_flag = 1'b1 ; // a flag with a default value to set a break wall pulse once per hammer use

always_ff @(posedge clk or negedge resetN) begin
		if (!resetN) begin
			breakWall_flag <= 1'b1 ;
		end // resetN
		
		else begin
			// defaults
			breakWall_pulse_command <= 1'b0 ;
			destroyWallPixelX = pacmanTopLeftX ;	
			destroyWallPixelY = pacmanTopLeftY ;		
			// end of defaults
			
			
			// creates a command to destroy a wall once per hammer use
			
			if (breakWall_req == 1'b1	&&			  		// if the player is using the hammer
				breakWall_flag == 1'b1) begin		 		// and no wall has been already broken in this use	
					breakWall_flag <= 1'b0 ;				// lower flag to meake sure you can only break a wall once per key press
					breakWall_pulse_command <= 1'b1 ;
			end // breakWall conditions
			
			if (!breakWall_req) begin		// after realeasing the key breakWall_flag goes up
				breakWall_flag <= 1'b1 ;
			end // breakwall_req	
			
		
			// aim the wall break from the center of pacman to the center of the wall
			
			case (pacmanFaceDirection)	
			
				PACMAN_FACE_UP: begin		
					destroyWallPixelX <= pacmanTopLeftX + REACH ;	
					destroyWallPixelY <= pacmanTopLeftY - REACH ;
				end
											
				PACMAN_FACE_DOWN:	begin	
					destroyWallPixelX <= pacmanTopLeftX + REACH ;	
					destroyWallPixelY <= pacmanTopLeftY + PACMAN_HEIGHT_Y + REACH ;
				end
											
				PACMAN_FACE_LEFT: begin		
					destroyWallPixelX <= pacmanTopLeftX - REACH ;	
					destroyWallPixelY <= pacmanTopLeftY + REACH ;
				 end
											
				default: begin			// PACMAN_FACE_RIGHT
					destroyWallPixelX <= pacmanTopLeftX + PACMAN_WIDTH_x + REACH ;	
					destroyWallPixelY <= pacmanTopLeftY + REACH ;
				end

			endcase

		end // resetN else
		
end // always_ff		


//-------------------------------------------------------
/* CONTROLLING SCORE COUNTER */

logic [3:0] temp = 8'h00;
logic coinCollision_flag;

always_ff @(posedge clk or negedge resetN) begin
		if (!resetN) begin
			counter_ones <= 8'h00;
			counter_tens<= 8'h00;
			counter_hundreds <= 8'h00;
			temp <= 8'h00;
			coinCollision_flag <= 0;
			coinCollisionPulse <= 0;
		end // resetN
		
		else begin
			
			coinCollisionPulse <= 0; // default
			counter_ones <= counter_ones;
			counter_tens <= counter_tens;
			counter_hundreds <= counter_hundreds;
			// end of defaults
			
			if(startOfFrame) 
				coinCollision_flag <= 1'b0 ; // reset for next time
			
			if (coinCollision_flag == 1'b0 && coinCollision) begin 
			coinCollision_flag	<= 1'b1; // to enter only once
			coinCollisionPulse <= 1'b1 ; 
			end  // coinCollision_flag == 1'b0 && coinCollision
		
		
		
		if (upScore) begin		
			if (counter_tens < 4'h9) begin 
				counter_tens <= counter_tens + 4'h1;
			end
			
			else if (counter_hundreds < 4'h9) begin 	
				counter_tens <= 4'h0;	
				counter_hundreds <= counter_hundreds + 4'h1;
			end		
		end // upScore

		else if (coinCollisionPulse == 1'b1 && playGame == 1'b1) begin
				
			if ( counter_ones < 4'h9 ) begin 
				counter_ones <= counter_ones + 4'h1;
			end
			
			else if (counter_ones == 4'h9 && counter_tens < 4'h9) begin 
				counter_ones <= 4'h0;
				counter_tens <= counter_tens + 4'h1;
			end
			
			else if (counter_ones == 4'h9 && counter_tens == 4'h9 && counter_hundreds < 4'h9) begin 
				counter_ones <= 4'h0;	
				counter_tens <= 4'h0;	
				counter_hundreds <= counter_hundreds + 4'h1;
			end
			
		end // coinCollisionPulse	
		
	end // resetN else
	
end // always_ff		
		
	
endmodule
