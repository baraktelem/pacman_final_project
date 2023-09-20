// (c) Technion IIT, Department of Electrical Engineering 2023 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updated Eyal Lev April 2023
// updated to state machine Dudy March 2023 


module	smiley_move	(	
 
					input	logic	clk,
					input	logic	resetN,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
					input	logic	Y_up_key,  //move Up   
					input	logic	Y_down_key,  //move down   
					input	logic	X_right_key,  //move right   
					input	logic	X_left_key,  //move left     
					input logic collision,  //collision if smiley hits an object
					input logic playGame,

					output	 logic signed 	[10:0]	topLeftX, // output the top left corner 
					output	 logic signed	[10:0]	topLeftY,  // can be negative , if the object is partliy outside
					output	logic [1:0] face_direction
					
					
);


// a module used to generate the  ball trajectory.  
localparam logic [1:0] FACE_LEFT = 2'b10;
localparam logic [1:0] FACE_UP = 2'b11;
localparam logic [1:0] FACE_RIGHT = 2'b01;
localparam logic [1:0] FACE_DOWN = 2'b00;
parameter int INITIAL_X = 280;
parameter int INITIAL_Y = 185;
parameter int INITIAL_X_SPEED = 0;
parameter int INITIAL_Y_SPEED = 0;
parameter int Y_ACCEL = 0;
localparam int MAX_Y_speed = 150;
const int	FIXED_POINT_MULTIPLIER	=	64; // note it must be 2^n 
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions


// movement limits 
const int   OBJECT_WIDTH_X = 32;//64;
const int   OBJECT_HIGHT_Y = 32;//64;
const int	SafetyMargin =	2;

const int	x_FRAME_LEFT	=	(SafetyMargin)* FIXED_POINT_MULTIPLIER; 
const int	x_FRAME_RIGHT	=	(639 - SafetyMargin - OBJECT_WIDTH_X)* FIXED_POINT_MULTIPLIER; 
const int	y_FRAME_TOP		=	(SafetyMargin) * FIXED_POINT_MULTIPLIER;
const int	y_FRAME_BOTTOM	=	(479 -SafetyMargin - OBJECT_HIGHT_Y /*+ 62*/ ) * FIXED_POINT_MULTIPLIER; //- OBJECT_HIGHT_Y

enum  logic [2:0] {IDLE_ST, // initial state
					MOVE_ST, // moving no colision 
					WAIT_FOR_EOF_ST, // change speed done, wait for startOfFrame  
					POSITION_CHANGE_ST// position interpolate 
					/*POSITION_LIMITS_ST*/ //check if inside the frame  
					}  SM_PS, 
						SM_NS ;

 int Xspeed_PS,  Xspeed_NS  ; // speed    
 int Yspeed_PS,  Yspeed_NS  ; 
 int Xposition_PS, Xposition_NS ; //position   
 int Yposition_PS, Yposition_NS ;  
 int face_direction_NS , face_direction_PS ;

 //---------
 
 always_ff @(posedge clk or negedge resetN)
		begin : fsm_sync_proc
			if (resetN == 1'b0) begin 
				SM_PS <= IDLE_ST ; 
				Xspeed_PS <= 0   ; 
				Yspeed_PS <= 0  ; 
				Xposition_PS <= 0  ; 
				Yposition_PS <= 0   ;  
				face_direction_PS <= FACE_RIGHT;				
			
			end 	
			else begin 
				SM_PS  <= SM_NS ;
				Xspeed_PS   <= Xspeed_NS    ; 
				Yspeed_PS    <=   Yspeed_NS  ; 
				Xposition_PS <=  Xposition_NS    ; 
				Yposition_PS <=  Yposition_NS    ; 
				face_direction_PS <= face_direction_NS	;

			end ; 
		end // end fsm_sync

 
 ///-----------------
 
 
always_comb 
begin
	// set default values 
		 SM_NS = SM_PS  ;
		 Xspeed_NS  = Xspeed_PS ; 
		 Yspeed_NS  = Yspeed_PS  ; 
		 Xposition_NS =  Xposition_PS ; 
		 Yposition_NS  = Yposition_PS  ; 
		 face_direction_NS = face_direction_PS ;

	case(SM_PS)
//------------
		IDLE_ST: begin
//------------
		 Xspeed_NS  = INITIAL_X_SPEED ; 
		 Yspeed_NS  = INITIAL_Y_SPEED  ; 
		 Xposition_NS = INITIAL_X * FIXED_POINT_MULTIPLIER; 
		 Yposition_NS = INITIAL_Y * FIXED_POINT_MULTIPLIER; 
		 face_direction_NS = FACE_RIGHT;

		 if (playGame) 
				SM_NS = MOVE_ST ;
 	
	end
	
//------------
		MOVE_ST:  begin     // moving no colision 
//------------
		
		
			if (Y_up_key) begin 
						Yspeed_NS = -MAX_Y_speed ;
						Xspeed_NS = 0;
						face_direction_NS = FACE_UP;

			end
			else if (Y_down_key) begin 
						Yspeed_NS = MAX_Y_speed ; 
						Xspeed_NS = 0;
						face_direction_NS = FACE_DOWN;
			end
			else if (X_right_key) begin 
						Xspeed_NS = MAX_Y_speed ;
						Yspeed_NS = 0;
						face_direction_NS = FACE_RIGHT;
			end
			else if (X_left_key) begin 
						Xspeed_NS = -MAX_Y_speed ;
						Yspeed_NS = 0;
						face_direction_NS = FACE_LEFT;					
			end

			if (collision) begin  //any colisin was detected 	
				Xspeed_NS = 0  ;     
				Yspeed_NS = 0 ; 			
				SM_NS = WAIT_FOR_EOF_ST ; 
			end 	
			
			if (startOfFrame) 
						SM_NS = POSITION_CHANGE_ST ; 
			
			if (!playGame) begin		// if the games stops pacman stops moving
				Xspeed_NS = 0  ;     
				Yspeed_NS = 0 ;
			end // !playGame
			
		end 
				
//--------------------
		WAIT_FOR_EOF_ST: begin  // change speed already done once, now wait for EOF 
//--------------------
									
			if (startOfFrame) 
				SM_NS = POSITION_CHANGE_ST ; 
		end 

//------------------------
 		POSITION_CHANGE_ST : begin  // position interpolate 
//------------------------
	
			 Xposition_NS =  Xposition_PS + Xspeed_PS; 
			 Yposition_NS  = Yposition_PS + Yspeed_PS ; 
				SM_NS = MOVE_ST /*POSITION_LIMITS_ST*/ ; 
		end
		
endcase  // case 
end		
//return from FIXED point  trunc back to prame size parameters 
  
assign 	topLeftX = Xposition_PS / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = Yposition_PS / FIXED_POINT_MULTIPLIER ;  
assign 	face_direction = face_direction_NS ; 


	

endmodule	
//---------------
 
