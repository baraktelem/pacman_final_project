// (c) Technion IIT, Department of Electrical Engineering 2023 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updated Eyal Lev April 2023
// updated to state machine Dudy March 2023 

module audio_choose_block (

	 input logic clk,
	 input logic resetN,
    input logic coinCollision,	 
	 input logic Wall_Break, 
	 
	 output logic Enable_Sound,
	 output logic Enable_Eat,
	 output logic [3:0] frequency
	);

	
	logic flag;
	logic oneSecPulse;
	logic Enable_Counter;
	localparam VCC = 1;
	
	sound_sec_counter ( 
	
	.clk(clk),
	.resetN(!Enable_Counter),
	.turbo(VCC),
	.one_sec(oneSecPulse)
	
	
	);
	
always_ff@(posedge clk or negedge resetN)
begin
		if(!resetN)begin 
			frequency <= 4'b0000;
			Enable_Sound  <= 0;
			Enable_Eat  <= 0;
			Enable_Counter <= 1'b0;
			flag <= 1'b0;
			
		end 
		
		
		else begin
				Enable_Counter <= 1'b0;
				
				if(coinCollision && flag == 1'b0) begin
					Enable_Sound <= 1'b1;
					frequency<= 4'b1010;
					flag <= 1'b1;
					Enable_Counter <= 1'b1;
					Enable_Eat  <= 1'b1;
				end
		
				if(Wall_Break && flag == 1'b0) begin
					Enable_Sound <= 1'b1;
					frequency <= 4'b1001;
					flag <= 1'b1;
					Enable_Counter <= 1'b1;
				end
				
				else begin 
					
					if ( flag == 1'b1 && oneSecPulse ) begin
						flag <= 1'b0;	
						Enable_Sound <= 1'b0;	// disable sound after 1 second has passed
						Enable_Eat <= 1'b0;
					end
				end

			end
			
end //always_ff



endmodule 