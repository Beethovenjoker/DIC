`timescale 1ns/10ps

module  ATCONV(
        input		    clk       ,
        input		    rst       ,
        output          ROM_rd    ,
        output [11:0]	iaddr     ,
        input  [15:0]	idata     ,
        output          layer0_ceb,
        output          layer0_web,   
        output [11:0]   layer0_A  ,
        output [15:0]   layer0_D  ,
        input  [15:0]   layer0_Q  ,
        output          layer1_ceb,
        output          layer1_web,
        output [11:0]   layer1_A  ,
        output [15:0]   layer1_D  ,
        input  [15:0]   layer1_Q  ,
        output          done
);

    //================================================================
    //  Parameters
    //================================================================

    // store counter
    reg [11:0] store_counter;

    // data counter
    reg [4:0] data_counter;

    // maxpool counter
    reg [1:0] maxpool_counter;

    // maxpool buffer
    reg [15:0] maxpool_buffer [3:0];

    // accumulation
    reg signed [31:0] acc;

    // relu
    wire signed [15:0] relu_result;
    
    // convolution center
    reg [6:0] center_row;
    reg [6:0] center_col;

    // maxpool center
    reg [5:0] pool_row;
    reg [5:0] pool_col;

    // address
    reg [6:0] addr_x;
    reg [6:0] addr_y;
    wire [11:0] pool_addr;

    // clamped
    wire [6:0] clamped_y;
    wire [6:0] clamped_x;

    // idate temp
    reg signed [15:0] idata_tmp;

    // mult result
    wire signed [31:0] mult_result;
    
    // max
    wire signed [15:0] max1;
    wire signed [15:0] max2;
    wire signed [15:0] max_val;

    //================================================================
    //  Filter Kernel
    //================================================================

    // kernel & bias
    wire signed [15:0] kernel [0:8];
    wire signed [15:0] bias;

    // Bias: -0.75
    assign  bias = 16'hFFF4;

    // Kernel 3x3 (row-major)
    assign  kernel[0] = 16'hFFFF;  // -0.0625
    assign  kernel[1] = 16'hFFFE;  // -0.125
    assign  kernel[2] = 16'hFFFF;  // -0.0625
    assign  kernel[3] = 16'hFFFC;  // -0.25
    assign  kernel[4] = 16'h0010;  // +1.0
    assign  kernel[5] = 16'hFFFC;  // -0.25
    assign  kernel[6] = 16'hFFFF;  // -0.0625
    assign  kernel[7] = 16'hFFFE;  // -0.125
    assign  kernel[8] = 16'hFFFF;  // -0.0625

    //================================================================
    //  FSM
    //================================================================

    // state
    reg [3:0] cur_state;
    reg [3:0] next_state;

    // stage parameters
    parameter IDLE          = 4'b0000;
    parameter FETCH         = 4'b0001;
    parameter WRITE_L0      = 4'b0010;
    parameter READ_L0       = 4'b0011;
    parameter WRITE_L1      = 4'b0100;
    parameter DONE          = 4'b0101;
    

    // state register
    always @(posedge clk) begin
        if (rst)
            cur_state <= IDLE;
        else
            cur_state <= next_state;
    end

    // next state logic 
    always @(*) begin 
        case (cur_state)
            IDLE: begin
                next_state = FETCH;
            end
            FETCH: begin
                next_state = (data_counter == 4'd9) ? WRITE_L0 : FETCH;
            end
            WRITE_L0: begin
                next_state = (center_row == 7'd63 && center_col == 7'd63) ? READ_L0 : FETCH;
            end
            READ_L0: begin
                next_state = (maxpool_counter == 2'd3) ? WRITE_L1 : READ_L0;
            end
            WRITE_L1: begin
                next_state = (pool_row == 6'd31 && pool_col == 6'd31) ? DONE : READ_L0;
            end
            DONE: begin
                next_state = DONE;
            end
            default: next_state = IDLE;
        endcase
    end


    //================================================================
    //  Layer0
    //================================================================

    // data counter
    always @(posedge clk) begin
        if (rst)
            data_counter <= 4'd0;
        else if (cur_state == FETCH)
            data_counter <= data_counter + 4'd1;
        else if (cur_state == WRITE_L0)
            data_counter <= 4'd0;
        else
            data_counter <= data_counter;
    end

    // store counter
    always @(posedge clk) begin
        if (rst)
            store_counter <= 12'd0;
        else if (cur_state == WRITE_L0)
            store_counter <= store_counter + 12'd1;
        else if (cur_state == DONE)
            store_counter <= 12'd0;
        else
            store_counter <= store_counter;
    end

    // convolution kernel center
    always @(posedge clk) begin
        if (rst) begin
            center_row <= 7'd0;
            center_col <= 7'd0;
        end else if (cur_state == WRITE_L0) begin
            if (center_col == 7'd63) begin
                center_col <= 7'd0;
                center_row <= center_row + 7'd1;
            end else begin
                center_col <= center_col + 7'd1;
            end
        end else begin
            center_row <= center_row;
            center_col <= center_col;
        end
    end

    // padding
    always @(*) begin
        case (data_counter)
            4'b0000: begin
                addr_y = (center_row < 7'd2)   ? 7'd0 : center_row - 7'd2;
                addr_x = (center_col < 7'd2)   ? 7'd0 : center_col - 7'd2;
            end
            4'b0001: begin
                addr_y = (center_row < 7'd2)   ? 7'd0 : center_row - 7'd2;
                addr_x = center_col;
            end
            4'b0010: begin
                addr_y = (center_row < 7'd2)   ? 7'd0 : center_row - 7'd2;
                addr_x = (center_col > 7'd64) ? 7'd67 : center_col + 7'd2;
            end
            4'b0011: begin
                addr_y = center_row;
                addr_x = (center_col < 7'd2)   ? 7'd0 : center_col - 7'd2;
            end
            4'b0100: begin
                addr_y = center_row;
                addr_x = center_col;
            end
            4'b0101: begin
                addr_y = center_row;
                addr_x = (center_col > 7'd64) ? 7'd67 : center_col + 7'd2;
            end
            4'b0110: begin
                addr_y = (center_row > 7'd64) ? 7'd67 : center_row + 7'd2;
                addr_x = (center_col < 7'd2)   ? 7'd0 : center_col - 7'd2;
            end
            4'b0111: begin
                addr_y = (center_row > 7'd64) ? 7'd67 : center_row + 7'd2;
                addr_x = center_col;
            end
            4'b1000: begin
                addr_y = (center_row > 7'd64) ? 7'd67 : center_row + 7'd2;
                addr_x = (center_col > 7'd64) ? 7'd67 : center_col + 7'd2;
            end
            default: begin addr_y = center_row; addr_x = center_col; end
        endcase
    end

    // clamp
    assign clamped_y = (addr_y > 7'd63) ? 7'd63 : addr_y;
    assign clamped_x = (addr_x > 7'd63) ? 7'd63 : addr_x;

    // idata temp
    always @(posedge clk) begin
        if (rst)
            idata_tmp <= 16'b0;
        else if (cur_state == FETCH)
            idata_tmp <= idata;
        else
            idata_tmp <= idata_tmp;
    end

    // convolution result
    assign mult_result = $signed(idata_tmp) * $signed(kernel[data_counter - 1]);

    // accumulation
    always @(posedge clk) begin
        if (rst)
            acc <= ($signed(bias) <<< 4);
        else if (cur_state == FETCH && data_counter)
            acc <= acc + mult_result;
        else if (data_counter == 0)
            acc <= ($signed(bias) <<< 4);
        else
            acc <= acc;
    end

    // relu
    assign relu_result = acc[31] ? 16'd0 : (|acc[3:0]) ? (acc[19:4] + 1) : acc[19:4];

    //================================================================
    //  Layer1
    //================================================================

    // maxpool counter
    always @(posedge clk) begin
        if (rst)
            maxpool_counter <= 2'd0;
        else if (cur_state == READ_L0)
            maxpool_counter <= maxpool_counter + 2'd1;
        else
            maxpool_counter <= 2'd0;
    end

    // maxpool address calculation
    always @(posedge clk) begin
        if (rst) begin
            pool_row <= 6'd0;
            pool_col <= 6'd0;
        end else if (cur_state == WRITE_L1) begin
            if (pool_col == 6'd31) begin
                pool_col <= 6'd0;
                pool_row <= pool_row + 6'd1;
            end else begin
                pool_col <= pool_col + 6'd1;
            end
        end
    end

    // maxpool address
    assign pool_addr = pool_row * 6'd32 + pool_col;

    // maxpool buffer
    always @(posedge clk) begin
        if (rst) begin
            maxpool_buffer[0] <= 16'd0;
            maxpool_buffer[1] <= 16'd0;
            maxpool_buffer[2] <= 16'd0;
            maxpool_buffer[3] <= 16'd0;
        end else if (cur_state == READ_L0)
            maxpool_buffer[maxpool_counter] <= layer0_Q;
        else begin
            maxpool_buffer[0] <= maxpool_buffer[0];
            maxpool_buffer[1] <= maxpool_buffer[1];
            maxpool_buffer[2] <= maxpool_buffer[2];
            maxpool_buffer[3] <= maxpool_buffer[3];
        end
    end

    // maxpool
    assign max1    = (maxpool_buffer[0] > maxpool_buffer[1]) ? maxpool_buffer[0] : maxpool_buffer[1];
    assign max2    = (maxpool_buffer[2] > maxpool_buffer[3]) ? maxpool_buffer[2] : maxpool_buffer[3];
    assign max_val = (max1 > max2) ? max1 : max2;

    //================================================================
    //  Control signal
    //================================================================

    // layer0 control signal
    assign ROM_rd     = (cur_state == FETCH);
    assign layer0_ceb = (cur_state == WRITE_L0 || cur_state == READ_L0);
    assign layer0_web = (cur_state == WRITE_L0) ? 1'b0 : 1'b1;
    assign layer0_A   = (cur_state == READ_L0) ? ((pool_row << 7) + (pool_col << 1) + (maxpool_counter[1] << 6) + maxpool_counter[0]) : store_counter;
    assign layer0_D   = relu_result;
    assign iaddr      = clamped_y * 7'd64 + clamped_x;

    // layer1 control signal
    assign layer1_ceb = (cur_state == WRITE_L1);
    assign layer1_web = (cur_state == WRITE_L1) ? 1'b0 : 1'b1;
    assign layer1_A   = pool_addr;
    assign layer1_D   = ((max_val[3:0] != 4'b0000) ? (max_val[15:4] + 1) : max_val[15:4]) << 4;
    assign done       = (cur_state == DONE);

endmodule

