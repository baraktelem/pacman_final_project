// (c) Technion IIT, Department of Electrical Engineering 2018 
// Updated by Mor Dahan - January 2022
// 
// Implements the state machine of the gameTimer mini-project
// FSM, with present and next states

module timer
	(
	input logic clk, 
	input logic resetN, 
	input logic startN,  
	input logic OneSecPulse, 
	input logic timerEnd,
	input logic upTime,
	
	output logic countLoadN,
	output logic countEnable, 
	output logic add_thirtySecN
   );

//-------------------------------------------------------------------------------------------

// state machine decleration 
	enum logic [1:0] {s_idle, s_run} gameTimer_ps, gameTimer_ns;
	logic [2:0] timer_ns, timer_ps; 


 	
//--------------------------------------------------------------------------------------------
//  1.  syncronous code:  executed once every clock to update the current state 
always @(posedge clk or negedge resetN)
   begin
			
		if ( !resetN ) begin  // Asynchronic reset
			gameTimer_ps <= s_idle;
			timer_ps <= 3'b0; // ADDED CODE
		end
		
		else begin		// Synchronic logic FSM
			gameTimer_ps <= gameTimer_ns;
			timer_ps <= timer_ns; // ADDED CODE
		end	
	end // always sync
	
//--------------------------------------------------------------------------------------------
//  2.  asynchornous code: logically defining what is the next state, and the ouptput 
//      							(not seperating to two different always sections)  	
always_comb // Update next state and outputs
	begin
	// set all default values 
		gameTimer_ns = gameTimer_ps; 
		timer_ns = timer_ps;
		countEnable = 1'b0;
		countLoadN = 1'b1;
		add_thirtySecN = 1'b1;		
			
		case (gameTimer_ps)
		
			s_idle: begin
				
				if (startN == 1'b0) begin
					countLoadN = 1'b0;
					gameTimer_ns = s_run;
				end
			end // idle
						

			s_run: begin
				
				countEnable = 1'b1;
				
				if (upTime) begin
					add_thirtySecN = 1'b0;
				end // upTime	
				
				if (timerEnd == 1'b1)
					gameTimer_ns = s_idle;
				
			end // run						
						
		endcase
	end // always comb
	
endmodule
