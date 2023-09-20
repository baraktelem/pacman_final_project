
// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2021 
//updated --Eyal Lev 2021


module	game_controller_update	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input	logic	drawing_request_Pacman,
			input	logic	drawing_request_Borders,
			input	logic	drawing_request_MIF,
			input	logic	drawing_request_Coins,
			input logic pacman_wall_collision,
			input	logic	drawing_request_Monster,
			
			output logic collision, // active in case of collision between player and MIF or background
			output logic coinCollision, // active in case of collision between a coin and non ghost object
			output logic SingleHitPulse,// critical code, generating A single pulse in a frame
			output logic monsterCollisionion	
);

// drawing_request_Pacman   -->  smiley
// drawing_request_Borders  -->  brackets
// drawing_request_MIF      -->  walls 

assign collision = (	pacman_wall_collision && 
							(drawing_request_Borders || drawing_request_MIF) );// between player and walls
assign coinCollision = ( drawing_request_Coins && (drawing_request_Pacman || drawing_request_Borders || drawing_request_MIF) );
						// active in case of collision between a coin and non ghost object
assign monsterCollisionion = drawing_request_Monster && (drawing_request_Borders || drawing_request_MIF) ;




logic flag ; // a semaphore to set the output only once per frame / regardless of the number of collisions 

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		flag	<= 1'b0;
		SingleHitPulse <= 1'b0 ; 
	end 
	else begin 

			SingleHitPulse <= 1'b0 ; // default 
			if(startOfFrame) 
				flag <= 1'b0 ; // reset for next time 


if ( (collision)  && (flag == 1'b0)) begin 
			flag	<= 1'b1; // to enter only once
			SingleHitPulse <= 1'b1 ; 
		end ; 
	end 
end

endmodule
