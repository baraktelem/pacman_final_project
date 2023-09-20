

module MIF_drawingRequest	(
									
									input [7:0] MIF_VGA,
									output MIF_DR
									
);

parameter TRANSPARENT_ENCODING = 8'hff ;// RGB value representing a transparent pixel

assign MIF_DR = ( MIF_VGA == TRANSPARENT_ENCODING ) ? 1'b0:1'b1;



endmodule

