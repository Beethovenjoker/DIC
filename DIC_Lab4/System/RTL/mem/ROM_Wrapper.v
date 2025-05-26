`timescale 1ns/10ps
`include "../include/define.v"

module ROM_Wrapper(
    // clk
	input     						bus_clk ,
	input     						bus_rst ,
    // bus
	input      [`BUS_ADDR_BITS-1:0] ADDR_S  ,
	input      [`BUS_LEN_BITS -1:0] BLEN_S  ,
	input     						RVALID_S,
	output     [`BUS_DATA_BITS-1:0] RDATA_S ,
	output     						RLAST_S ,
	output    						RREADY_S,
    // ROM
	output    						ROM_rd  ,
	output     [`BUS_ADDR_BITS-1:0] ROM_A  	,
	input 	   [`BUS_DATA_BITS-1:0] ROM_Q 
);

	//================================================================
    //  Output logic
    //================================================================
    
    assign ROM_A    = ADDR_S;
    assign ROM_rd   = RVALID_S;
    assign RREADY_S = RVALID_S;
    assign RDATA_S  = ROM_Q;
    assign RLAST_S  = 0;

endmodule