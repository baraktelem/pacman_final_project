// (c) Technion IIT, Department of Electrical Engineering 2021 


module randomWalls_and_Objects_control 	
 ( 
	input	logic  clk,
	input	logic  resetN, 
	input logic [3:0] countL,
	input logic [3:0] countM,
	input logic oneSecPulse,	
	
	output logic two_secPulse,		// for coins
	output logic four_secPulse,		// for big coins
	output logic eight_secPulse, 		// for the random walls
	output logic thirtyTwo_secPulse		// for time boosts
	
  ) ;
  

// derivatives logics to spot a change in the signals
logic two_sec_d ;
logic four_sec_d ;	
logic eight_sec_d ;
logic thirtyTwo_sec_d ;	

// ensures the 20 sec pulse can only accure only once every second	
//logic twenty_sec_flag ; 	


logic [5:0] counter ;

always_ff @(posedge clk or negedge resetN) begin
		if (!resetN) begin
			two_secPulse <= 1'b0;
			four_secPulse <= 1'b0;
			eight_secPulse <= 1'b0;
			thirtyTwo_secPulse <= 1'b0;
			
			two_sec_d <= 1'b0;
			four_sec_d <= 1'b0;
			eight_sec_d <= 1'b0;
			thirtyTwo_sec_d <= 1'b0;
			
			counter <= 0;
		end // resetN
		
		else begin 
			// defaults
			two_secPulse <= 1'b0 ;
			four_secPulse <= 1'b0 ;
			eight_secPulse <= 1'b0 ;
			thirtyTwo_secPulse <= 1'b0 ;
			counter <= counter ;
			two_sec_d <= counter[1] ;
			four_sec_d <= counter[2] ;
			eight_sec_d <= counter[3] ;
			thirtyTwo_sec_d <= counter[5] ;
			// end of defaults
			
			if (oneSecPulse)
				counter <= counter + 1 ;

			if ( (counter[1] && !two_sec_d) || (!counter[1] && two_sec_d) ) // 2 sec edge detector
				two_secPulse <= 1'b1;
				
			if ( (counter[2] && !four_sec_d) || (!counter[2] && four_sec_d) ) // 4 sec edge detector
				four_secPulse <= 1'b1;
			
			if ( (counter[3] && !eight_sec_d) || (!counter[3] && eight_sec_d) ) // 10 sec edge detector
				eight_secPulse <= 1'b1;
			
			if ( (counter[5] && !thirtyTwo_sec_d) || (!counter[5] && thirtyTwo_sec_d) ) // 30 sec edge detector
				thirtyTwo_secPulse <= 1'b1;
			
		end // resetN else
	
end // always_ff

endmodule

