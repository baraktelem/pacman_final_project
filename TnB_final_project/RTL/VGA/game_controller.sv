
// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2021 
//updated --Eyal Lev 2021


module	game_controller	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startGame,	// pressed for starting the game
			input	logic	timeout,	// ends the game if the time runs out
			input logic monster_pacmanCollision,


			output logic startDisplay, // display the start screen writing
			output logic endDisplay, // display the end screen writing
			output logic playGame // actvie while game is running 
);


enum  logic [2:0] {START_GAME_ST, 
					PLAY_GAME_ST, // the state when the game is running 
					END_GAME_ST    
					}  SM_PS, 
						SM_NS ;

//---------

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		SM_PS <= START_GAME_ST ; 
	end // resetN
	else begin 
		SM_PS <= SM_NS ;
	end // else
end // always_ff

//---------

always_comb
begin
	// set deafault values
	startDisplay = 1'b0 ;
	endDisplay = 1'b0 ;
	playGame = 1'b0;
	SM_NS = SM_PS ;
	
	case(SM_PS)
//------------
		START_GAME_ST: begin
//------------
		 startDisplay = 1 ;

		 if (startGame) begin
				SM_NS = PLAY_GAME_ST ; 
		end
 	
	end // START_GAME_ST
	
//------------
		PLAY_GAME_ST: begin
//------------
			playGame = 1;
			
			if (timeout || monster_pacmanCollision) begin
				SM_NS = END_GAME_ST ;
			end
		end // PLAY_GAME_ST
		
//------------
		END_GAME_ST: begin
//------------
		 endDisplay = 1 ;

	end // END_GAME_ST
	
	endcase
	
	
end // always_comb



endmodule
