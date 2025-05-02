module  FFT(
    input                      clk      , 
    input                      rst      , 
    input             [15:0]   fir_d    , 
    input                      fir_valid,
    output reg                 fft_valid, 
    output reg                 done     ,
    output reg signed [15:0]   fft_d1   , 
    output reg signed [15:0]   fft_d2   ,
    output reg signed [15:0]   fft_d3   , 
    output reg signed [15:0]   fft_d4   , 
    output reg signed [15:0]   fft_d5   , 
    output reg signed [15:0]   fft_d6   , 
    output reg signed [15:0]   fft_d7   , 
    output reg signed [15:0]   fft_d8   ,
    output reg signed [15:0]   fft_d9   , 
    output reg signed [15:0]   fft_d10  , 
    output reg signed [15:0]   fft_d11  , 
    output reg signed [15:0]   fft_d12  , 
    output reg signed [15:0]   fft_d13  , 
    output reg signed [15:0]   fft_d14  , 
    output reg signed [15:0]   fft_d15  , 
    output reg signed [15:0]   fft_d0
);

    // register
    reg signed [15:0] real_reg     [0:15];
    reg signed [15:0] real_reg1    [0:15];
    reg signed [15:0] imag_reg     [0:15];
    reg signed [15:0] imag_reg1     [0:15];
    reg signed [15:0] out_real_reg [0:15];
    reg signed [15:0] out_imag_reg [0:15];

    // load counter
    reg [6:0] load_counter;

    // real coefficients
    reg signed [31:0] W0_real = 32'h00010000;
    reg signed [31:0] W1_real = 32'h0000EC83;
    reg signed [31:0] W2_real = 32'h0000B504;
    reg signed [31:0] W3_real = 32'h000061F7;
    reg signed [31:0] W4_real = 32'h00000000;
    reg signed [31:0] W5_real = 32'hFFFF9E09;
    reg signed [31:0] W6_real = 32'hFFFF4AFC;
    reg signed [31:0] W7_real = 32'hFFFF137D;

    // imag coefficients
    reg signed [31:0] W0_imag = 32'h00000000;
    reg signed [31:0] W1_imag = 32'hFFFF9E09;
    reg signed [31:0] W2_imag = 32'hFFFF4AFC;
    reg signed [31:0] W3_imag = 32'hFFFF137D;
    reg signed [31:0] W4_imag = 32'hFFFF0000;
    reg signed [31:0] W5_imag = 32'hFFFF137D;
    reg signed [31:0] W6_imag = 32'hFFFF4AFC;
    reg signed [31:0] W7_imag = 32'hFFFF9E09;

    // loop variable
    integer i;

    // flag
    reg done_flag;
    reg first_flag;

    // stage0 real output wire
    wire [15:0] stage0_y0_real_out;
    wire [15:0] stage0_y1_real_out;
    wire [15:0] stage0_y2_real_out;
    wire [15:0] stage0_y3_real_out;
    wire [15:0] stage0_y4_real_out;
    wire [15:0] stage0_y5_real_out;
    wire [15:0] stage0_y6_real_out;
    wire [15:0] stage0_y7_real_out;
    wire [15:0] stage0_y8_real_out;
    wire [15:0] stage0_y9_real_out;
    wire [15:0] stage0_y10_real_out;
    wire [15:0] stage0_y11_real_out;
    wire [15:0] stage0_y12_real_out;
    wire [15:0] stage0_y13_real_out;
    wire [15:0] stage0_y14_real_out;
    wire [15:0] stage0_y15_real_out;

    // stage0 image output wire
    wire [15:0] stage0_y0_imag_out;
    wire [15:0] stage0_y1_imag_out;
    wire [15:0] stage0_y2_imag_out;
    wire [15:0] stage0_y3_imag_out;
    wire [15:0] stage0_y4_imag_out;
    wire [15:0] stage0_y5_imag_out;
    wire [15:0] stage0_y6_imag_out;
    wire [15:0] stage0_y7_imag_out;
    wire [15:0] stage0_y8_imag_out;
    wire [15:0] stage0_y9_imag_out;
    wire [15:0] stage0_y10_imag_out;
    wire [15:0] stage0_y11_imag_out;
    wire [15:0] stage0_y12_imag_out;
    wire [15:0] stage0_y13_imag_out;
    wire [15:0] stage0_y14_imag_out;
    wire [15:0] stage0_y15_imag_out;

    // stage1 real output wire
    wire [15:0] stage1_y0_real_out;
    wire [15:0] stage1_y1_real_out;
    wire [15:0] stage1_y2_real_out;
    wire [15:0] stage1_y3_real_out;
    wire [15:0] stage1_y4_real_out;
    wire [15:0] stage1_y5_real_out;
    wire [15:0] stage1_y6_real_out;
    wire [15:0] stage1_y7_real_out;
    wire [15:0] stage1_y8_real_out;
    wire [15:0] stage1_y9_real_out;
    wire [15:0] stage1_y10_real_out;
    wire [15:0] stage1_y11_real_out;
    wire [15:0] stage1_y12_real_out;
    wire [15:0] stage1_y13_real_out;
    wire [15:0] stage1_y14_real_out;
    wire [15:0] stage1_y15_real_out;

    // stage1 image output wire
    wire [15:0] stage1_y0_imag_out;
    wire [15:0] stage1_y1_imag_out;
    wire [15:0] stage1_y2_imag_out;
    wire [15:0] stage1_y3_imag_out;
    wire [15:0] stage1_y4_imag_out;
    wire [15:0] stage1_y5_imag_out;
    wire [15:0] stage1_y6_imag_out;
    wire [15:0] stage1_y7_imag_out;
    wire [15:0] stage1_y8_imag_out;
    wire [15:0] stage1_y9_imag_out;
    wire [15:0] stage1_y10_imag_out;
    wire [15:0] stage1_y11_imag_out;
    wire [15:0] stage1_y12_imag_out;
    wire [15:0] stage1_y13_imag_out;
    wire [15:0] stage1_y14_imag_out;
    wire [15:0] stage1_y15_imag_out;

    // stage2 real output wire
    wire [15:0] stage2_y0_real_out;
    wire [15:0] stage2_y1_real_out;
    wire [15:0] stage2_y2_real_out;
    wire [15:0] stage2_y3_real_out;
    wire [15:0] stage2_y4_real_out;
    wire [15:0] stage2_y5_real_out;
    wire [15:0] stage2_y6_real_out;
    wire [15:0] stage2_y7_real_out;
    wire [15:0] stage2_y8_real_out;
    wire [15:0] stage2_y9_real_out;
    wire [15:0] stage2_y10_real_out;
    wire [15:0] stage2_y11_real_out;
    wire [15:0] stage2_y12_real_out;
    wire [15:0] stage2_y13_real_out;
    wire [15:0] stage2_y14_real_out;
    wire [15:0] stage2_y15_real_out;

    // stage2 image output wire
    wire [15:0] stage2_y0_imag_out;
    wire [15:0] stage2_y1_imag_out;
    wire [15:0] stage2_y2_imag_out;
    wire [15:0] stage2_y3_imag_out;
    wire [15:0] stage2_y4_imag_out;
    wire [15:0] stage2_y5_imag_out;
    wire [15:0] stage2_y6_imag_out;
    wire [15:0] stage2_y7_imag_out;
    wire [15:0] stage2_y8_imag_out;
    wire [15:0] stage2_y9_imag_out;
    wire [15:0] stage2_y10_imag_out;
    wire [15:0] stage2_y11_imag_out;
    wire [15:0] stage2_y12_imag_out;
    wire [15:0] stage2_y13_imag_out;
    wire [15:0] stage2_y14_imag_out;
    wire [15:0] stage2_y15_imag_out;

    // stage3 real output wire
    wire [15:0] stage3_y0_real_out;
    wire [15:0] stage3_y1_real_out;
    wire [15:0] stage3_y2_real_out;
    wire [15:0] stage3_y3_real_out;
    wire [15:0] stage3_y4_real_out;
    wire [15:0] stage3_y5_real_out;
    wire [15:0] stage3_y6_real_out;
    wire [15:0] stage3_y7_real_out;
    wire [15:0] stage3_y8_real_out;
    wire [15:0] stage3_y9_real_out;
    wire [15:0] stage3_y10_real_out;
    wire [15:0] stage3_y11_real_out;
    wire [15:0] stage3_y12_real_out;
    wire [15:0] stage3_y13_real_out;
    wire [15:0] stage3_y14_real_out;
    wire [15:0] stage3_y15_real_out;

    // stage3 image output wire
    wire [15:0] stage3_y0_imag_out;
    wire [15:0] stage3_y1_imag_out;
    wire [15:0] stage3_y2_imag_out;
    wire [15:0] stage3_y3_imag_out;
    wire [15:0] stage3_y4_imag_out;
    wire [15:0] stage3_y5_imag_out;
    wire [15:0] stage3_y6_imag_out;
    wire [15:0] stage3_y7_imag_out;
    wire [15:0] stage3_y8_imag_out;
    wire [15:0] stage3_y9_imag_out;
    wire [15:0] stage3_y10_imag_out;
    wire [15:0] stage3_y11_imag_out;
    wire [15:0] stage3_y12_imag_out;
    wire [15:0] stage3_y13_imag_out;
    wire [15:0] stage3_y14_imag_out;
    wire [15:0] stage3_y15_imag_out;

    // load real register
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 16; i = i + 1)
                real_reg[i] <= 16'b0;
        end else if (fir_valid)
            real_reg[load_counter] <= fir_d;
        else
            for (i = 0; i < 16; i = i + 1)
                real_reg[i] <= real_reg[i];
    end

    // load image register
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 16; i = i + 1)
                imag_reg[i] <= 16'b0;
        end else if (fir_valid)
            imag_reg[load_counter] <= 16'b0;
        else
            for (i = 0; i < 16; i = i + 1)
                imag_reg[i] <= imag_reg[i];
    end

    // load real register1
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 16; i = i + 1)
                real_reg1[i] <= 16'b0;
        end else if (first_flag && !load_counter)
            for (i = 0; i < 16; i = i + 1)
                real_reg1[i] <= real_reg[i];
        else
            for (i = 0; i < 16; i = i + 1)
                real_reg1[i] <= real_reg1[i];
    end

    // load image register1
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 16; i = i + 1)
                imag_reg1[i] <= 16'b0;
        end else if (first_flag && !load_counter)
            for (i = 0; i < 16; i = i + 1)
                imag_reg1[i] <= imag_reg[i];
        else
            for (i = 0; i < 16; i = i + 1)
                imag_reg1[i] <= imag_reg1[i];
    end

    // load counter
    always @(posedge clk) begin
        if (rst)
            load_counter <= 5'b0;
        else if ((fir_valid || done_flag) && load_counter < 5'd15 )
            load_counter <= load_counter + 5'b1;
        else
            load_counter <= 5'b0;
    end

    // output real register
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0 ; i < 16 ; i = i + 1)
                out_real_reg[i] <= 16'b0;
        end else begin
            out_real_reg[0] <= stage3_y0_real_out;
            out_real_reg[1] <= stage3_y1_real_out;
            out_real_reg[2] <= stage3_y2_real_out;
            out_real_reg[3] <= stage3_y3_real_out;
            out_real_reg[4] <= stage3_y4_real_out;
            out_real_reg[5] <= stage3_y5_real_out;
            out_real_reg[6] <= stage3_y6_real_out;
            out_real_reg[7] <= stage3_y7_real_out;
            out_real_reg[8] <= stage3_y8_real_out;
            out_real_reg[9] <= stage3_y9_real_out;
            out_real_reg[10] <= stage3_y10_real_out;
            out_real_reg[11] <= stage3_y11_real_out;
            out_real_reg[12] <= stage3_y12_real_out;
            out_real_reg[13] <= stage3_y13_real_out;
            out_real_reg[14] <= stage3_y14_real_out;
            out_real_reg[15] <= stage3_y15_real_out;
        end
    end

    // output image register
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0 ; i < 16 ; i = i + 1)
                out_imag_reg[i] <= 16'b0;
        end else begin
            out_imag_reg[0] <= stage3_y0_imag_out;
            out_imag_reg[1] <= stage3_y1_imag_out;
            out_imag_reg[2] <= stage3_y2_imag_out;
            out_imag_reg[3] <= stage3_y3_imag_out;
            out_imag_reg[4] <= stage3_y4_imag_out;
            out_imag_reg[5] <= stage3_y5_imag_out;
            out_imag_reg[6] <= stage3_y6_imag_out;
            out_imag_reg[7] <= stage3_y7_imag_out;
            out_imag_reg[8] <= stage3_y8_imag_out;
            out_imag_reg[9] <= stage3_y9_imag_out;
            out_imag_reg[10] <= stage3_y10_imag_out;
            out_imag_reg[11] <= stage3_y11_imag_out;
            out_imag_reg[12] <= stage3_y12_imag_out;
            out_imag_reg[13] <= stage3_y13_imag_out;
            out_imag_reg[14] <= stage3_y14_imag_out;
            out_imag_reg[15] <= stage3_y15_imag_out;
        end
    end

    // output logic
    always @(posedge clk) begin
        if (rst) begin
            fft_d1  <= 0;
            fft_d2  <= 0;
            fft_d3  <= 0;
            fft_d4  <= 0;
            fft_d5  <= 0;
            fft_d6  <= 0;
            fft_d7  <= 0;
            fft_d8  <= 0;
            fft_d9  <= 0;
            fft_d10 <= 0;
            fft_d11 <= 0;
            fft_d12 <= 0;
            fft_d13 <= 0;
            fft_d14 <= 0;
            fft_d15 <= 0;
            fft_d0  <= 0;
        end else if(fft_valid) begin
            fft_d0  <= out_imag_reg[0];
            fft_d8  <= out_imag_reg[1];
            fft_d4  <= out_imag_reg[2];
            fft_d12 <= out_imag_reg[3];
            fft_d2  <= out_imag_reg[4];
            fft_d10 <= out_imag_reg[5];
            fft_d6  <= out_imag_reg[6];
            fft_d14 <= out_imag_reg[7];
            fft_d1  <= out_imag_reg[8];
            fft_d9  <= out_imag_reg[9];
            fft_d5  <= out_imag_reg[10];
            fft_d13 <= out_imag_reg[11];
            fft_d3  <= out_imag_reg[12];
            fft_d11 <= out_imag_reg[13];
            fft_d7  <= out_imag_reg[14];
            fft_d15 <= out_imag_reg[15];
        end else begin
            fft_d0  <= out_real_reg[0];
            fft_d8  <= out_real_reg[1];
            fft_d4  <= out_real_reg[2];
            fft_d12 <= out_real_reg[3];
            fft_d2  <= out_real_reg[4];
            fft_d10 <= out_real_reg[5];
            fft_d6  <= out_real_reg[6];
            fft_d14 <= out_real_reg[7];
            fft_d1  <= out_real_reg[8];
            fft_d9  <= out_real_reg[9];
            fft_d5  <= out_real_reg[10];
            fft_d13 <= out_real_reg[11];
            fft_d3  <= out_real_reg[12];
            fft_d11 <= out_real_reg[13];
            fft_d7  <= out_real_reg[14];
            fft_d15 <= out_real_reg[15];
        end
    end

    // fft_valid
    always @(posedge clk) begin
        if(rst)
            fft_valid <= 1'b0;
        else if (first_flag && (load_counter == 5'd4 || load_counter == 5'd5))
            fft_valid <= 1'b1;
        else
            fft_valid <= 1'b0;
    end

    // first flag
    always @(posedge clk) begin
        if(rst)
            first_flag <= 1'b0;
        else if (load_counter == 5'd15)
            first_flag <= 1'b1;
        else
            first_flag <= first_flag;
    end

    // done flag
    always @(posedge clk) begin
        if(rst)
            done_flag <= 1'b0;
        else if (fir_valid == 1)
            done_flag <= 1'b1;
        else
            done_flag <= done_flag;
    end

    // done signal
    always @(posedge clk) begin
        if(rst)
            done <= 1'b0;
        else if (!fir_valid && done_flag && load_counter == 5'd15) 
            done <= 1'b1;
        else
            done <= done;
    end

    // butterfly stage begin
    Stage stage0(
        // input real
        .y0_real_in(real_reg1[0]),
        .y1_real_in(real_reg1[8]),
        .y2_real_in(real_reg1[1]),
        .y3_real_in(real_reg1[9]),
        .y4_real_in(real_reg1[2]),
        .y5_real_in(real_reg1[10]),
        .y6_real_in(real_reg1[3]),
        .y7_real_in(real_reg1[11]),
        .y8_real_in(real_reg1[4]),
        .y9_real_in(real_reg1[12]),
        .y10_real_in(real_reg1[5]),
        .y11_real_in(real_reg1[13]),
        .y12_real_in(real_reg1[6]),
        .y13_real_in(real_reg1[14]),
        .y14_real_in(real_reg1[7]),
        .y15_real_in(real_reg1[15]),

        // input image
        .y0_imag_in(imag_reg1[0]),
        .y1_imag_in(imag_reg1[8]),
        .y2_imag_in(imag_reg1[1]),
        .y3_imag_in(imag_reg1[9]),
        .y4_imag_in(imag_reg1[2]),
        .y5_imag_in(imag_reg1[10]),
        .y6_imag_in(imag_reg1[3]),
        .y7_imag_in(imag_reg1[11]),
        .y8_imag_in(imag_reg1[4]),
        .y9_imag_in(imag_reg1[12]),
        .y10_imag_in(imag_reg1[5]),
        .y11_imag_in(imag_reg1[13]),
        .y12_imag_in(imag_reg1[6]),
        .y13_imag_in(imag_reg1[14]),
        .y14_imag_in(imag_reg1[7]),
        .y15_imag_in(imag_reg1[15]),

        // input real coeficient
        .W0_real(W0_real),
        .W1_real(W1_real),
        .W2_real(W2_real),
        .W3_real(W3_real),
        .W4_real(W4_real),
        .W5_real(W5_real),
        .W6_real(W6_real),
        .W7_real(W7_real),

        // input imag coeficient
        .W0_imag(W0_imag),
        .W1_imag(W1_imag),
        .W2_imag(W2_imag),
        .W3_imag(W3_imag),
        .W4_imag(W4_imag),
        .W5_imag(W5_imag),
        .W6_imag(W6_imag),
        .W7_imag(W7_imag),

        // output real
        .y0_real_out(stage0_y0_real_out),
        .y1_real_out(stage0_y1_real_out),
        .y2_real_out(stage0_y2_real_out),
        .y3_real_out(stage0_y3_real_out),
        .y4_real_out(stage0_y4_real_out),
        .y5_real_out(stage0_y5_real_out),
        .y6_real_out(stage0_y6_real_out),
        .y7_real_out(stage0_y7_real_out),
        .y8_real_out(stage0_y8_real_out),
        .y9_real_out(stage0_y9_real_out),
        .y10_real_out(stage0_y10_real_out),
        .y11_real_out(stage0_y11_real_out),
        .y12_real_out(stage0_y12_real_out),
        .y13_real_out(stage0_y13_real_out),
        .y14_real_out(stage0_y14_real_out),
        .y15_real_out(stage0_y15_real_out),

        // output image
        .y0_imag_out(stage0_y0_imag_out),
        .y1_imag_out(stage0_y1_imag_out),
        .y2_imag_out(stage0_y2_imag_out),
        .y3_imag_out(stage0_y3_imag_out),
        .y4_imag_out(stage0_y4_imag_out),
        .y5_imag_out(stage0_y5_imag_out),
        .y6_imag_out(stage0_y6_imag_out),
        .y7_imag_out(stage0_y7_imag_out),
        .y8_imag_out(stage0_y8_imag_out),
        .y9_imag_out(stage0_y9_imag_out),
        .y10_imag_out(stage0_y10_imag_out),
        .y11_imag_out(stage0_y11_imag_out),
        .y12_imag_out(stage0_y12_imag_out),
        .y13_imag_out(stage0_y13_imag_out),
        .y14_imag_out(stage0_y14_imag_out),
        .y15_imag_out(stage0_y15_imag_out)
    );

    Stage stage1(
        // input real
        .y0_real_in(stage0_y0_real_out),
        .y1_real_in(stage0_y8_real_out),
        .y2_real_in(stage0_y2_real_out),
        .y3_real_in(stage0_y10_real_out),
        .y4_real_in(stage0_y4_real_out),
        .y5_real_in(stage0_y12_real_out),
        .y6_real_in(stage0_y6_real_out),
        .y7_real_in(stage0_y14_real_out),
        .y8_real_in(stage0_y1_real_out),
        .y9_real_in(stage0_y9_real_out),
        .y10_real_in(stage0_y3_real_out),
        .y11_real_in(stage0_y11_real_out),
        .y12_real_in(stage0_y5_real_out),
        .y13_real_in(stage0_y13_real_out),
        .y14_real_in(stage0_y7_real_out),
        .y15_real_in(stage0_y15_real_out),

        // input image
        .y0_imag_in(stage0_y0_imag_out),
        .y1_imag_in(stage0_y8_imag_out),
        .y2_imag_in(stage0_y2_imag_out),
        .y3_imag_in(stage0_y10_imag_out),
        .y4_imag_in(stage0_y4_imag_out),
        .y5_imag_in(stage0_y12_imag_out),
        .y6_imag_in(stage0_y6_imag_out),
        .y7_imag_in(stage0_y14_imag_out),
        .y8_imag_in(stage0_y1_imag_out),
        .y9_imag_in(stage0_y9_imag_out),
        .y10_imag_in(stage0_y3_imag_out),
        .y11_imag_in(stage0_y11_imag_out),
        .y12_imag_in(stage0_y5_imag_out),
        .y13_imag_in(stage0_y13_imag_out),
        .y14_imag_in(stage0_y7_imag_out),
        .y15_imag_in(stage0_y15_imag_out),

        // input real coeficient
        .W0_real(W0_real),
        .W1_real(W2_real),
        .W2_real(W4_real),
        .W3_real(W6_real),
        .W4_real(W0_real),
        .W5_real(W2_real),
        .W6_real(W4_real),
        .W7_real(W6_real),

        // input imag coeficient
        .W0_imag(W0_imag),
        .W1_imag(W2_imag),
        .W2_imag(W4_imag),
        .W3_imag(W6_imag),
        .W4_imag(W0_imag),
        .W5_imag(W2_imag),
        .W6_imag(W4_imag),
        .W7_imag(W6_imag),

        // output real
        .y0_real_out(stage1_y0_real_out),
        .y1_real_out(stage1_y1_real_out),
        .y2_real_out(stage1_y2_real_out),
        .y3_real_out(stage1_y3_real_out),
        .y4_real_out(stage1_y4_real_out),
        .y5_real_out(stage1_y5_real_out),
        .y6_real_out(stage1_y6_real_out),
        .y7_real_out(stage1_y7_real_out),
        .y8_real_out(stage1_y8_real_out),
        .y9_real_out(stage1_y9_real_out),
        .y10_real_out(stage1_y10_real_out),
        .y11_real_out(stage1_y11_real_out),
        .y12_real_out(stage1_y12_real_out),
        .y13_real_out(stage1_y13_real_out),
        .y14_real_out(stage1_y14_real_out),
        .y15_real_out(stage1_y15_real_out),

        // output image
        .y0_imag_out(stage1_y0_imag_out),
        .y1_imag_out(stage1_y1_imag_out),
        .y2_imag_out(stage1_y2_imag_out),
        .y3_imag_out(stage1_y3_imag_out),
        .y4_imag_out(stage1_y4_imag_out),
        .y5_imag_out(stage1_y5_imag_out),
        .y6_imag_out(stage1_y6_imag_out),
        .y7_imag_out(stage1_y7_imag_out),
        .y8_imag_out(stage1_y8_imag_out),
        .y9_imag_out(stage1_y9_imag_out),
        .y10_imag_out(stage1_y10_imag_out),
        .y11_imag_out(stage1_y11_imag_out),
        .y12_imag_out(stage1_y12_imag_out),
        .y13_imag_out(stage1_y13_imag_out),
        .y14_imag_out(stage1_y14_imag_out),
        .y15_imag_out(stage1_y15_imag_out)
    );

    Stage stage2(
        // input real
        .y0_real_in(stage1_y0_real_out),
        .y1_real_in(stage1_y4_real_out),
        .y2_real_in(stage1_y2_real_out),
        .y3_real_in(stage1_y6_real_out),
        .y4_real_in(stage1_y1_real_out),
        .y5_real_in(stage1_y5_real_out),
        .y6_real_in(stage1_y3_real_out),
        .y7_real_in(stage1_y7_real_out),
        .y8_real_in(stage1_y8_real_out),
        .y9_real_in(stage1_y12_real_out),
        .y10_real_in(stage1_y10_real_out),
        .y11_real_in(stage1_y14_real_out),
        .y12_real_in(stage1_y9_real_out),
        .y13_real_in(stage1_y13_real_out),
        .y14_real_in(stage1_y11_real_out),
        .y15_real_in(stage1_y15_real_out),

        // input image
        .y0_imag_in(stage1_y0_imag_out),
        .y1_imag_in(stage1_y4_imag_out),
        .y2_imag_in(stage1_y2_imag_out),
        .y3_imag_in(stage1_y6_imag_out),
        .y4_imag_in(stage1_y1_imag_out),
        .y5_imag_in(stage1_y5_imag_out),
        .y6_imag_in(stage1_y3_imag_out),
        .y7_imag_in(stage1_y7_imag_out),
        .y8_imag_in(stage1_y8_imag_out),
        .y9_imag_in(stage1_y12_imag_out),
        .y10_imag_in(stage1_y10_imag_out),
        .y11_imag_in(stage1_y14_imag_out),
        .y12_imag_in(stage1_y9_imag_out),
        .y13_imag_in(stage1_y13_imag_out),
        .y14_imag_in(stage1_y11_imag_out),
        .y15_imag_in(stage1_y15_imag_out),

        // input real coeficient
        .W0_real(W0_real),
        .W1_real(W4_real),
        .W2_real(W0_real),
        .W3_real(W4_real),
        .W4_real(W0_real),
        .W5_real(W4_real),
        .W6_real(W0_real),
        .W7_real(W4_real),

        // input imag coeficient
        .W0_imag(W0_imag),
        .W1_imag(W4_imag),
        .W2_imag(W0_imag),
        .W3_imag(W4_imag),
        .W4_imag(W0_imag),
        .W5_imag(W4_imag),
        .W6_imag(W0_imag),
        .W7_imag(W4_imag),

        // output real
        .y0_real_out(stage2_y0_real_out),
        .y1_real_out(stage2_y1_real_out),
        .y2_real_out(stage2_y2_real_out),
        .y3_real_out(stage2_y3_real_out),
        .y4_real_out(stage2_y4_real_out),
        .y5_real_out(stage2_y5_real_out),
        .y6_real_out(stage2_y6_real_out),
        .y7_real_out(stage2_y7_real_out),
        .y8_real_out(stage2_y8_real_out),
        .y9_real_out(stage2_y9_real_out),
        .y10_real_out(stage2_y10_real_out),
        .y11_real_out(stage2_y11_real_out),
        .y12_real_out(stage2_y12_real_out),
        .y13_real_out(stage2_y13_real_out),
        .y14_real_out(stage2_y14_real_out),
        .y15_real_out(stage2_y15_real_out),

        // output image
        .y0_imag_out(stage2_y0_imag_out),
        .y1_imag_out(stage2_y1_imag_out),
        .y2_imag_out(stage2_y2_imag_out),
        .y3_imag_out(stage2_y3_imag_out),
        .y4_imag_out(stage2_y4_imag_out),
        .y5_imag_out(stage2_y5_imag_out),
        .y6_imag_out(stage2_y6_imag_out),
        .y7_imag_out(stage2_y7_imag_out),
        .y8_imag_out(stage2_y8_imag_out),
        .y9_imag_out(stage2_y9_imag_out),
        .y10_imag_out(stage2_y10_imag_out),
        .y11_imag_out(stage2_y11_imag_out),
        .y12_imag_out(stage2_y12_imag_out),
        .y13_imag_out(stage2_y13_imag_out),
        .y14_imag_out(stage2_y14_imag_out),
        .y15_imag_out(stage2_y15_imag_out)
    );


    Stage stage3(
        // input real
        .y0_real_in(stage2_y0_real_out),
        .y1_real_in(stage2_y2_real_out),
        .y2_real_in(stage2_y1_real_out),
        .y3_real_in(stage2_y3_real_out),
        .y4_real_in(stage2_y4_real_out),
        .y5_real_in(stage2_y6_real_out),
        .y6_real_in(stage2_y5_real_out),
        .y7_real_in(stage2_y7_real_out),
        .y8_real_in(stage2_y8_real_out),
        .y9_real_in(stage2_y10_real_out),
        .y10_real_in(stage2_y9_real_out),
        .y11_real_in(stage2_y11_real_out),
        .y12_real_in(stage2_y12_real_out),
        .y13_real_in(stage2_y14_real_out),
        .y14_real_in(stage2_y13_real_out),
        .y15_real_in(stage2_y15_real_out),

        // input image
        .y0_imag_in(stage2_y0_imag_out),
        .y1_imag_in(stage2_y2_imag_out),
        .y2_imag_in(stage2_y1_imag_out),
        .y3_imag_in(stage2_y3_imag_out),
        .y4_imag_in(stage2_y4_imag_out),
        .y5_imag_in(stage2_y6_imag_out),
        .y6_imag_in(stage2_y5_imag_out),
        .y7_imag_in(stage2_y7_imag_out),
        .y8_imag_in(stage2_y8_imag_out),
        .y9_imag_in(stage2_y10_imag_out),
        .y10_imag_in(stage2_y9_imag_out),
        .y11_imag_in(stage2_y11_imag_out),
        .y12_imag_in(stage2_y12_imag_out),
        .y13_imag_in(stage2_y14_imag_out),
        .y14_imag_in(stage2_y13_imag_out),
        .y15_imag_in(stage2_y15_imag_out),

        // input real coeficient
        .W0_real(W0_real),
        .W1_real(W0_real),
        .W2_real(W0_real),
        .W3_real(W0_real),
        .W4_real(W0_real),
        .W5_real(W0_real),
        .W6_real(W0_real),
        .W7_real(W0_real),

        // input imag coeficient
        .W0_imag(W0_imag),
        .W1_imag(W0_imag),
        .W2_imag(W0_imag),
        .W3_imag(W0_imag),
        .W4_imag(W0_imag),
        .W5_imag(W0_imag),
        .W6_imag(W0_imag),
        .W7_imag(W0_imag),

        // output real
        .y0_real_out(stage3_y0_real_out),
        .y1_real_out(stage3_y1_real_out),
        .y2_real_out(stage3_y2_real_out),
        .y3_real_out(stage3_y3_real_out),
        .y4_real_out(stage3_y4_real_out),
        .y5_real_out(stage3_y5_real_out),
        .y6_real_out(stage3_y6_real_out),
        .y7_real_out(stage3_y7_real_out),
        .y8_real_out(stage3_y8_real_out),
        .y9_real_out(stage3_y9_real_out),
        .y10_real_out(stage3_y10_real_out),
        .y11_real_out(stage3_y11_real_out),
        .y12_real_out(stage3_y12_real_out),
        .y13_real_out(stage3_y13_real_out),
        .y14_real_out(stage3_y14_real_out),
        .y15_real_out(stage3_y15_real_out),

        // output image
        .y0_imag_out(stage3_y0_imag_out),
        .y1_imag_out(stage3_y1_imag_out),
        .y2_imag_out(stage3_y2_imag_out),
        .y3_imag_out(stage3_y3_imag_out),
        .y4_imag_out(stage3_y4_imag_out),
        .y5_imag_out(stage3_y5_imag_out),
        .y6_imag_out(stage3_y6_imag_out),
        .y7_imag_out(stage3_y7_imag_out),
        .y8_imag_out(stage3_y8_imag_out),
        .y9_imag_out(stage3_y9_imag_out),
        .y10_imag_out(stage3_y10_imag_out),
        .y11_imag_out(stage3_y11_imag_out),
        .y12_imag_out(stage3_y12_imag_out),
        .y13_imag_out(stage3_y13_imag_out),
        .y14_imag_out(stage3_y14_imag_out),
        .y15_imag_out(stage3_y15_imag_out)
    );

endmodule