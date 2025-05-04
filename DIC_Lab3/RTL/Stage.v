module Stage(
    // input real
    input signed [15:0] y0_real_in,
    input signed [15:0] y1_real_in,
    input signed [15:0] y2_real_in,
    input signed [15:0] y3_real_in,
    input signed [15:0] y4_real_in,
    input signed [15:0] y5_real_in,
    input signed [15:0] y6_real_in,
    input signed [15:0] y7_real_in,
    input signed [15:0] y8_real_in,
    input signed [15:0] y9_real_in,
    input signed [15:0] y10_real_in,
    input signed [15:0] y11_real_in,
    input signed [15:0] y12_real_in,
    input signed [15:0] y13_real_in,
    input signed [15:0] y14_real_in,
    input signed [15:0] y15_real_in,

    // input image
    input signed [15:0] y0_imag_in,
    input signed [15:0] y1_imag_in,
    input signed [15:0] y2_imag_in,
    input signed [15:0] y3_imag_in,
    input signed [15:0] y4_imag_in,
    input signed [15:0] y5_imag_in,
    input signed [15:0] y6_imag_in,
    input signed [15:0] y7_imag_in,
    input signed [15:0] y8_imag_in,
    input signed [15:0] y9_imag_in,
    input signed [15:0] y10_imag_in,
    input signed [15:0] y11_imag_in,
    input signed [15:0] y12_imag_in,
    input signed [15:0] y13_imag_in,
    input signed [15:0] y14_imag_in,
    input signed [15:0] y15_imag_in,

    // input real coeficient
    input signed [31:0] W0_real,
    input signed [31:0] W1_real,
    input signed [31:0] W2_real,
    input signed [31:0] W3_real,
    input signed [31:0] W4_real,
    input signed [31:0] W5_real,
    input signed [31:0] W6_real,
    input signed [31:0] W7_real,

    // input imag coeficient
    input signed [31:0] W0_imag,
    input signed [31:0] W1_imag,
    input signed [31:0] W2_imag,
    input signed [31:0] W3_imag,
    input signed [31:0] W4_imag,
    input signed [31:0] W5_imag,
    input signed [31:0] W6_imag,
    input signed [31:0] W7_imag,

    // output real
    output reg signed [15:0] y0_real_out,
    output reg signed [15:0] y1_real_out,
    output reg signed [15:0] y2_real_out,
    output reg signed [15:0] y3_real_out,
    output reg signed [15:0] y4_real_out,
    output reg signed [15:0] y5_real_out,
    output reg signed [15:0] y6_real_out,
    output reg signed [15:0] y7_real_out,
    output reg signed [15:0] y8_real_out,
    output reg signed [15:0] y9_real_out,
    output reg signed [15:0] y10_real_out,
    output reg signed [15:0] y11_real_out,
    output reg signed [15:0] y12_real_out,
    output reg signed [15:0] y13_real_out,
    output reg signed [15:0] y14_real_out,
    output reg signed [15:0] y15_real_out,

    // output image
    output reg signed [15:0] y0_imag_out,
    output reg signed [15:0] y1_imag_out,
    output reg signed [15:0] y2_imag_out,
    output reg signed [15:0] y3_imag_out,
    output reg signed [15:0] y4_imag_out,
    output reg signed [15:0] y5_imag_out,
    output reg signed [15:0] y6_imag_out,
    output reg signed [15:0] y7_imag_out,
    output reg signed [15:0] y8_imag_out,
    output reg signed [15:0] y9_imag_out,
    output reg signed [15:0] y10_imag_out,
    output reg signed [15:0] y11_imag_out,
    output reg signed [15:0] y12_imag_out,
    output reg signed [15:0] y13_imag_out,
    output reg signed [15:0] y14_imag_out,
    output reg signed [15:0] y15_imag_out

);
    // overflow buffer
    reg [63:0] overflow_buf0;
    reg [63:0] overflow_buf1;
    reg [63:0] overflow_buf2;
    reg [63:0] overflow_buf3;
    reg [63:0] overflow_buf4;
    reg [63:0] overflow_buf5;
    reg [63:0] overflow_buf6;
    reg [63:0] overflow_buf7;
    reg [63:0] overflow_buf8;
    reg [63:0] overflow_buf9;
    reg [63:0] overflow_buf10;
    reg [63:0] overflow_buf11;
    reg [63:0] overflow_buf12;
    reg [63:0] overflow_buf13;
    reg [63:0] overflow_buf14;
    reg [63:0] overflow_buf15;

    // minus real buffer
    reg [15:0] minus_real_buf0;
    reg [15:0] minus_real_buf1;
    reg [15:0] minus_real_buf2;
    reg [15:0] minus_real_buf3;
    reg [15:0] minus_real_buf4;
    reg [15:0] minus_real_buf5;
    reg [15:0] minus_real_buf6;
    reg [15:0] minus_real_buf7;

    // minus imag buffer
    reg [15:0] minus_imag_buf0;
    reg [15:0] minus_imag_buf1;
    reg [15:0] minus_imag_buf2;
    reg [15:0] minus_imag_buf3;
    reg [15:0] minus_imag_buf4;
    reg [15:0] minus_imag_buf5;
    reg [15:0] minus_imag_buf6;
    reg [15:0] minus_imag_buf7;
    reg [15:0] minus_imag_buf8;
    reg [15:0] minus_imag_buf9;
    reg [15:0] minus_imag_buf10;
    reg [15:0] minus_imag_buf11;
    reg [15:0] minus_imag_buf12;
    reg [15:0] minus_imag_buf13;
    reg [15:0] minus_imag_buf14;
    reg [15:0] minus_imag_buf15;

    // first group
    always @(*) begin
        y0_real_out = y0_real_in + y1_real_in;
        y0_imag_out = y0_imag_in + y1_imag_in;
        minus_real_buf0 = y0_real_in - y1_real_in;
        minus_imag_buf0 = y1_imag_in - y0_imag_in;
        minus_imag_buf1 = y0_imag_in - y1_imag_in;
        overflow_buf0 = {{16{minus_real_buf0[15]}},minus_real_buf0} * W0_real + {{16{minus_imag_buf0[15]}},minus_imag_buf0} * W0_imag;
        y1_real_out = (overflow_buf0 + 64'h000000000008000) >> 16;
        overflow_buf1 = {{16{minus_real_buf0[15]}},minus_real_buf0} * W0_imag + {{16{minus_imag_buf1[15]}},minus_imag_buf1} * W0_real;
        y1_imag_out = (overflow_buf1 + 64'h000000000008000) >> 16;
    end

    // second group
    always @(*) begin
        y2_real_out = y2_real_in + y3_real_in;
        y2_imag_out = y2_imag_in + y3_imag_in;
        minus_real_buf1 = y2_real_in - y3_real_in;
        minus_imag_buf2 = y3_imag_in - y2_imag_in;
        minus_imag_buf3 = y2_imag_in - y3_imag_in;
        overflow_buf2 = {{16{minus_real_buf1[15]}},minus_real_buf1} * W1_real + {{16{minus_imag_buf2[15]}},minus_imag_buf2} * W1_imag;
        y3_real_out = (overflow_buf2 + 64'h000000000008000) >> 16;
        overflow_buf3 = {{16{minus_real_buf1[15]}},minus_real_buf1} * W1_imag + {{16{minus_imag_buf3[15]}},minus_imag_buf3} * W1_real;
        y3_imag_out = (overflow_buf3 + 64'h000000000008000) >> 16;
    end

    // third group
    always @(*) begin
        y4_real_out = y4_real_in + y5_real_in;
        y4_imag_out = y4_imag_in + y5_imag_in;
        minus_real_buf2 = y4_real_in - y5_real_in;
        minus_imag_buf4 = y5_imag_in - y4_imag_in;
        minus_imag_buf5 = y4_imag_in - y5_imag_in;
        overflow_buf4 = {{16{minus_real_buf2[15]}},minus_real_buf2} * W2_real + {{16{minus_imag_buf4[15]}},minus_imag_buf4} * W2_imag;
        y5_real_out = (overflow_buf4 + 64'h000000000008000) >> 16;
        overflow_buf5 = {{16{minus_real_buf2[15]}},minus_real_buf2} * W2_imag + {{16{minus_imag_buf5[15]}},minus_imag_buf5} * W2_real;
        y5_imag_out = (overflow_buf5 + 64'h000000000008000) >> 16;
    end

    // fourth group
    always @(*) begin
        y6_real_out = y6_real_in + y7_real_in;
        y6_imag_out = y6_imag_in + y7_imag_in;
        minus_real_buf3 = y6_real_in - y7_real_in;
        minus_imag_buf6 = y7_imag_in - y6_imag_in;
        minus_imag_buf7 = y6_imag_in - y7_imag_in;
        overflow_buf6 = {{16{minus_real_buf3[15]}},minus_real_buf3} * W3_real + {{16{minus_imag_buf6[15]}},minus_imag_buf6} * W3_imag;
        y7_real_out = (overflow_buf6 + 64'h000000000008000) >> 16;
        overflow_buf7 = {{16{minus_real_buf3[15]}},minus_real_buf3} * W3_imag + {{16{minus_imag_buf7[15]}},minus_imag_buf7} * W3_real;
        y7_imag_out = (overflow_buf7 + 64'h000000000008000) >> 16;
    end

    // fifth group
    always @(*) begin
        y8_real_out = y8_real_in + y9_real_in;
        y8_imag_out = y8_imag_in + y9_imag_in;
        minus_real_buf4 = y8_real_in - y9_real_in;
        minus_imag_buf8 = y9_imag_in - y8_imag_in;
        minus_imag_buf9 = y8_imag_in - y9_imag_in;
        overflow_buf8 = {{16{minus_real_buf4[15]}},minus_real_buf4} * W4_real + {{16{minus_imag_buf8[15]}},minus_imag_buf8} * W4_imag;
        y9_real_out = (overflow_buf8 + 64'h000000000008000) >> 16;
        overflow_buf9 = {{16{minus_real_buf4[15]}},minus_real_buf4} * W4_imag + {{16{minus_imag_buf9[15]}},minus_imag_buf9} * W4_real;
        y9_imag_out = (overflow_buf9 + 64'h000000000008000) >> 16;
    end

    // sixth group
    always @(*) begin
        y10_real_out = y10_real_in + y11_real_in;
        y10_imag_out = y10_imag_in + y11_imag_in;
        minus_real_buf5 = y10_real_in - y11_real_in;
        minus_imag_buf10 = y11_imag_in - y10_imag_in;
        minus_imag_buf11 = y10_imag_in - y11_imag_in;
        overflow_buf10 = {{16{minus_real_buf5[15]}},minus_real_buf5} * W5_real + {{16{minus_imag_buf10[15]}},minus_imag_buf10} * W5_imag;
        y11_real_out = (overflow_buf10 + 64'h000000000008000) >> 16;
        overflow_buf11 = {{16{minus_real_buf5[15]}},minus_real_buf5} * W5_imag + {{16{minus_imag_buf11[15]}},minus_imag_buf11} * W5_real;
        y11_imag_out = (overflow_buf11 + 64'h000000000008000) >> 16;
    end

    // seventh group
    always @(*) begin
        y12_real_out = y12_real_in + y13_real_in;
        y12_imag_out = y12_imag_in + y13_imag_in;
        minus_real_buf6 = y12_real_in - y13_real_in;
        minus_imag_buf12 = y13_imag_in - y12_imag_in;
        minus_imag_buf13 = y12_imag_in - y13_imag_in;
        overflow_buf12 = {{16{minus_real_buf6[15]}},minus_real_buf6} * W6_real + {{16{minus_imag_buf12[15]}},minus_imag_buf12} * W6_imag;
        y13_real_out = (overflow_buf12 + 64'h000000000008000) >> 16;
        overflow_buf13 = {{16{minus_real_buf6[15]}},minus_real_buf6} * W6_imag + {{16{minus_imag_buf13[15]}},minus_imag_buf13} * W6_real;
        y13_imag_out = (overflow_buf13 + 64'h000000000008000) >> 16;
    end

    // eighth group
    always @(*) begin
        y14_real_out = y14_real_in + y15_real_in;
        y14_imag_out = y14_imag_in + y15_imag_in;
        minus_real_buf7 = y14_real_in - y15_real_in;
        minus_imag_buf14 = y15_imag_in - y14_imag_in;
        minus_imag_buf15 = y14_imag_in - y15_imag_in;
        overflow_buf14 = {{16{minus_real_buf7[15]}},minus_real_buf7} * W7_real + {{16{minus_imag_buf14[15]}},minus_imag_buf14} * W7_imag;
        y15_real_out = (overflow_buf14 + 64'h000000000008000) >> 16;
        overflow_buf15 = {{16{minus_real_buf7[15]}},minus_real_buf7} * W7_imag + {{16{minus_imag_buf15[15]}},minus_imag_buf15} * W7_real;
        y15_imag_out = (overflow_buf15 + 64'h000000000008000) >> 16;
    end

endmodule