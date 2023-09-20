// (c) Technion IIT, Department of Electrical Engineering 2018 

// Implements an up-counter that has also control inputs,
// loadN, enable_cnt and enable to control the count
// and data input - init[3:0] for the load functionality


module up_counter
	(
   // Input, Output Ports
   input logic clk, 
   input logic resetN,
   input logic enable_cnt,
	input logic up_trigger,

   output logic [3:0] count, 
	output logic tc_pulse
   );

 	 logic tc_flag; // for creating a pulse
 
   always_ff @( posedge clk , negedge resetN )
   begin
      
	if ( !resetN ) begin // Asynchronic reset
		count <= 0;
		tc_flag <= 0;
	end
	else
		tc_flag <= 0 ; // default
		if(enable_cnt && up_trigger) begin 
			if (count == 4'h9) begin
				count <= 4'h0;
			end
			else begin
				count <= count + 1;
			end	
		
		if (count == 4'h0) begin
			tc_flag <= 1;
		end
	end // resetN else
end	
	 assign tc = (count == 4'h0 ? 1 : 0);
	 
endmodule

