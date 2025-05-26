`timescale 1ns/10ps
`include "./include/define.v"
`include "./ATCONV.v"

module ATCONV_Wrapper(
    // clk
    input		                        bus_clk  ,
    input		                        bus_rst  ,
    // bus
    input         [`BUS_DATA_BITS-1:0]  RDATA_M  ,
    input 	      					 	RLAST_M  ,
    input 	      					 	WREADY_M ,
    input 	      					 	RREADY_M ,
    output reg    [`BUS_ID_BITS  -1:0]  ID_M	 ,
    output reg    [`BUS_ADDR_BITS-1:0]  ADDR_M	 ,
    output reg    [`BUS_DATA_BITS-1:0]  WDATA_M  ,
    output        [`BUS_LEN_BITS -1:0]  BLEN_M   ,
    output    	         		 	    WLAST_M  ,
    output      		        	    WVALID_M ,
    output      			            RVALID_M ,
    // ATCONV
    output                              done   
);

    //================================================================
    //  ATCONV
    //================================================================

    wire           at_ROM_rd;
    wire  [11:0]   at_iaddr;
    wire           at_layer0_ceb;
    wire           at_layer0_web;   
    wire  [11:0]   at_layer0_A;
    wire  [15:0]   at_layer0_D;
    wire           at_layer1_ceb;
    wire           at_layer1_web;
    wire  [11:0]   at_layer1_A;
    wire  [15:0]   at_layer1_D;
    wire           at_done;

    ATCONV atconv(
        // clk
        .clk         (bus_clk),
        .rst         (bus_rst),
        // ROM
        .ROM_rd      (at_ROM_rd),
        .iaddr       (at_iaddr),
        .idata       (RDATA_M),
        // SRAM1
        .layer0_ceb  (at_layer0_ceb),
        .layer0_web  (at_layer0_web),
        .layer0_A    (at_layer0_A),
        .layer0_D    (at_layer0_D),
        .layer0_Q    (RDATA_M),
        // SRAM2
        .layer1_ceb  (at_layer1_ceb),
        .layer1_web  (at_layer1_web),
        .layer1_A    (at_layer1_A),
        .layer1_D    (at_layer1_D),
        .layer1_Q    (RDATA_M),
        .done        (at_done)
    );

    assign done = at_done;


    //================================================================
    //  Output logic
    //================================================================

    // ID 
    always @(*) begin
        if (at_ROM_rd)
            ID_M = 0;
        else if (at_layer0_ceb)
            ID_M = 1;
        else if (at_layer1_ceb)
            ID_M = 2;
        else
            ID_M = 3;
    end
    
    // Adress
    always @(*) begin
        if (at_ROM_rd)
            ADDR_M = at_iaddr;
        else if (at_layer0_ceb)
            ADDR_M = at_layer0_A;
        else if (at_layer1_ceb)
            ADDR_M = at_layer1_A;
        else
            ADDR_M = 12'b0;
    end

    // Write data
    always @(*) begin
        if (at_layer0_ceb)
            WDATA_M = at_layer0_D;
        else if (at_layer1_ceb)
            WDATA_M = at_layer1_D;
        else
            WDATA_M = 16'b0;
    end

    assign BLEN_M   = 0;
    assign WLAST_M  = 0;
    assign WVALID_M = (!at_layer0_web && at_layer0_ceb) || (!at_layer1_web && at_layer1_ceb);
    assign RVALID_M = at_ROM_rd || (at_layer0_ceb & at_layer0_web);

endmodule
