module LCD_CTRL(
    input           clk,
    input           rst,
    input   [3:0]   cmd,
    input           cmd_valid,
    input   [7:0]   IROM_Q,
    output  reg     IROM_rd,
    output  reg [5:0] IROM_A,
    output  reg     IRAM_ceb,
    output  reg     IRAM_web,
    output  reg [7:0] IRAM_D,
    output  reg [5:0] IRAM_A,
    input   [7:0]   IRAM_Q,
    output  reg     busy,
    output  reg     done
);

    parameter READ       = 3'b000;
    parameter IDLE       = 3'b001;
    parameter OPERATION  = 3'b010;
    parameter WRITE      = 3'b011;
    parameter DONE       = 3'b100;
    parameter READ_RD    = 3'b101;
    parameter WRITE_RD   = 3'b110;
    parameter SCAN_END   = 6'd63;

    parameter WRITE_COMMAND = 4'b0000;
    parameter SHIFT_UP      = 4'b0001;
    parameter SHIFT_DOWN    = 4'b0010;
    parameter SHIFT_LEFT    = 4'b0011;
    parameter SHIFT_RIGHT   = 4'b0100;
    parameter MAX           = 4'b0101;
    parameter MIN           = 4'b0110;
    parameter AVERAGE       = 4'b0111;

    parameter UP_BOUND      = 3'd2;
    parameter LEFT_BOUND    = 3'd2;
    parameter DOWN_BOUND    = 3'd6;
    parameter RIGHT_BOUND   = 3'd6;

    reg [2:0] cur_state, next_state;
    reg [5:0] counter;
    reg [2:0] pos_x, pos_y;
    reg [7:0] max, min;
    reg [11:0] sum;
    reg [7:0] ImageBuffer [63:0];
    reg [5:0] p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16;

    // state logic
    always @(posedge clk) begin
        if (rst)
            cur_state <= READ;
        else
            cur_state <= next_state;
    end

    // next state logic
    always @(*) begin
        case (cur_state)
            READ: begin
                if (IROM_A == SCAN_END)
                    next_state = READ_RD;
                else
                    next_state = READ;
            end
            READ_RD: begin
                next_state = IDLE;
            end
            IDLE: begin
                if (cmd_valid && cmd != WRITE_COMMAND)
                    next_state = OPERATION;
                else if (cmd_valid)
                    next_state = WRITE;
                else
                    next_state = IDLE;
            end
            OPERATION: begin
                next_state = IDLE;
            end
            WRITE: begin
                if (IRAM_A == SCAN_END)
                    next_state = WRITE_RD;
                else
                    next_state = WRITE;
            end
            WRITE_RD: begin
                next_state = DONE;
            end
            DONE: begin
                next_state = DONE;
            end
        endcase
    end

    // control signal
    always @(*) begin
        case (cur_state)
            READ,
            READ_RD: begin
                IROM_rd   <= 1;
                IRAM_ceb  <= 0;
                IRAM_web  <= 1;
                busy      <= 1;
                done      <= 0;
            end
            IDLE: begin
                IROM_rd   <= 0;
                IRAM_ceb  <= 0;
                IRAM_web  <= 1;
                busy      <= 0;
                done      <= 0;
            end
            OPERATION: begin
                IROM_rd   <= 0;
                IRAM_ceb  <= 0;
                IRAM_web  <= 1;
                busy      <= 1;
                done      <= 0;
            end
            WRITE,
            WRITE_RD: begin
                IROM_rd   <= 0;
                IRAM_ceb  <= 1;
                IRAM_web  <= 0;
                busy      <= 1;
                done      <= 0;
            end
            DONE: begin
                IROM_rd   <= 0;
                IRAM_ceb  <= 0;
                IRAM_web  <= 1;
                busy      <= 0;
                done      <= 1;
            end
        endcase
    end

    // IROM Counter
    always @(posedge clk) begin
        if (rst)
            IROM_A <= 0;
        else if (cur_state == READ) begin
            if (IROM_rd && IROM_A < SCAN_END)
                IROM_A <= IROM_A + 1;
        end else begin
            IROM_A <= IROM_A;
        end
    end

    // IROM Read
    always @(posedge clk) begin
        if (cur_state == READ && IROM_rd)
            ImageBuffer[IROM_A] <= IROM_Q;
    end

    // IRAM Counter
    always @(posedge clk) begin
        if (rst)
            counter <= 0;
        else if (cur_state == WRITE) begin
            if (IRAM_ceb && counter != SCAN_END)
                counter <= counter + 1;
        end else begin
            counter <= counter;
        end
    end

    // IRAM_A delay 1 clk
    always @(posedge clk) begin
        IRAM_A <= counter;
    end

    // Point Move
    always @(posedge clk) begin
        if (rst) begin
            pos_x <= 4;
            pos_y <= 4;
        end else if (cur_state == OPERATION) begin
            case (cmd)
                SHIFT_UP:    if (pos_y > UP_BOUND)    pos_y <= pos_y - 1;
                SHIFT_DOWN:  if (pos_y < DOWN_BOUND)  pos_y <= pos_y + 1;
                SHIFT_LEFT:  if (pos_x > LEFT_BOUND)  pos_x <= pos_x - 1;
                SHIFT_RIGHT: if (pos_x < RIGHT_BOUND) pos_x <= pos_x + 1;
            endcase
        end
    end

    // image position
    always @(*) begin
        p1  = (pos_y - 2) * 6'd8 + (pos_x - 2);
        p2  = (pos_y - 2) * 6'd8 + (pos_x - 1);
        p3  = (pos_y - 2) * 6'd8 + (pos_x);
        p4  = (pos_y - 2) * 6'd8 + (pos_x + 1);
        p5  = (pos_y - 1) * 6'd8 + (pos_x - 2);
        p6  = (pos_y - 1) * 6'd8 + (pos_x - 1);
        p7  = (pos_y - 1) * 6'd8 + (pos_x);
        p8  = (pos_y - 1) * 6'd8 + (pos_x + 1);
        p9  = pos_y * 6'd8 + (pos_x - 2);
        p10 = pos_y * 6'd8 + (pos_x - 1);
        p11 = pos_y * 6'd8 + (pos_x);
        p12 = pos_y * 6'd8 + (pos_x + 1);
        p13 = (pos_y + 1) * 6'd8 + (pos_x - 2);
        p14 = (pos_y + 1) * 6'd8 + (pos_x - 1);
        p15 = (pos_y + 1) * 6'd8 + (pos_x);
        p16 = (pos_y + 1) * 6'd8 + (pos_x + 1);
    end

    // Max & Min & Average
    always @(*) begin
        max = ImageBuffer[p1];
        min = ImageBuffer[p1];
        sum = ImageBuffer[p1] + ImageBuffer[p2] + ImageBuffer[p3] + ImageBuffer[p4] +
              ImageBuffer[p5] + ImageBuffer[p6] + ImageBuffer[p7] + ImageBuffer[p8] +
              ImageBuffer[p9] + ImageBuffer[p10] + ImageBuffer[p11] + ImageBuffer[p12] +
              ImageBuffer[p13] + ImageBuffer[p14] + ImageBuffer[p15] + ImageBuffer[p16];

        // max
        if (ImageBuffer[p2]  > max) max = ImageBuffer[p2];
        if (ImageBuffer[p3]  > max) max = ImageBuffer[p3];
        if (ImageBuffer[p4]  > max) max = ImageBuffer[p4];
        if (ImageBuffer[p5]  > max) max = ImageBuffer[p5];
        if (ImageBuffer[p6]  > max) max = ImageBuffer[p6];
        if (ImageBuffer[p7]  > max) max = ImageBuffer[p7];
        if (ImageBuffer[p8]  > max) max = ImageBuffer[p8];
        if (ImageBuffer[p9]  > max) max = ImageBuffer[p9];
        if (ImageBuffer[p10] > max) max = ImageBuffer[p10];
        if (ImageBuffer[p11] > max) max = ImageBuffer[p11];
        if (ImageBuffer[p12] > max) max = ImageBuffer[p12];
        if (ImageBuffer[p13] > max) max = ImageBuffer[p13];
        if (ImageBuffer[p14] > max) max = ImageBuffer[p14];
        if (ImageBuffer[p15] > max) max = ImageBuffer[p15];
        if (ImageBuffer[p16] > max) max = ImageBuffer[p16];

        // min
        if (ImageBuffer[p2]  < min) min = ImageBuffer[p2];
        if (ImageBuffer[p3]  < min) min = ImageBuffer[p3];
        if (ImageBuffer[p4]  < min) min = ImageBuffer[p4];
        if (ImageBuffer[p5]  < min) min = ImageBuffer[p5];
        if (ImageBuffer[p6]  < min) min = ImageBuffer[p6];
        if (ImageBuffer[p7]  < min) min = ImageBuffer[p7];
        if (ImageBuffer[p8]  < min) min = ImageBuffer[p8];
        if (ImageBuffer[p9]  < min) min = ImageBuffer[p9];
        if (ImageBuffer[p10] < min) min = ImageBuffer[p10];
        if (ImageBuffer[p11] < min) min = ImageBuffer[p11];
        if (ImageBuffer[p12] < min) min = ImageBuffer[p12];
        if (ImageBuffer[p13] < min) min = ImageBuffer[p13];
        if (ImageBuffer[p14] < min) min = ImageBuffer[p14];
        if (ImageBuffer[p15] < min) min = ImageBuffer[p15];
        if (ImageBuffer[p16] < min) min = ImageBuffer[p16];
    end

    // output logic
    always @(posedge clk) begin
        case (cur_state)
            READ,
            READ_RD: begin
                if (IROM_rd)
                    ImageBuffer[IROM_A] <= IROM_Q;
            end
            OPERATION: begin
                case (cmd)
                    MAX: begin
                        ImageBuffer[p1] <= max;
                        ImageBuffer[p2] <= max;
                        ImageBuffer[p3] <= max;
                        ImageBuffer[p4] <= max;
                        ImageBuffer[p5] <= max;
                        ImageBuffer[p6] <= max;
                        ImageBuffer[p7] <= max;
                        ImageBuffer[p8] <= max;
                        ImageBuffer[p9] <= max;
                        ImageBuffer[p10] <= max;
                        ImageBuffer[p11] <= max;
                        ImageBuffer[p12] <= max;
                        ImageBuffer[p13] <= max;
                        ImageBuffer[p14] <= max;
                        ImageBuffer[p15] <= max;
                        ImageBuffer[p16] <= max;
                    end
                    MIN: begin
                        ImageBuffer[p1] <= min;
                        ImageBuffer[p2] <= min;
                        ImageBuffer[p3] <= min;
                        ImageBuffer[p4] <= min;
                        ImageBuffer[p5] <= min;
                        ImageBuffer[p6] <= min;
                        ImageBuffer[p7] <= min;
                        ImageBuffer[p8] <= min;
                        ImageBuffer[p9] <= min;
                        ImageBuffer[p10] <= min;
                        ImageBuffer[p11] <= min;
                        ImageBuffer[p12] <= min;
                        ImageBuffer[p13] <= min;
                        ImageBuffer[p14] <= min;
                        ImageBuffer[p15] <= min;
                        ImageBuffer[p16] <= min;
                    end
                    AVERAGE: begin
                        ImageBuffer[p1] <= sum[9:4];
                        ImageBuffer[p2] <= sum[9:4];
                        ImageBuffer[p3] <= sum[9:4];
                        ImageBuffer[p4] <= sum[9:4];
                        ImageBuffer[p5] <= sum[9:4];
                        ImageBuffer[p6] <= sum[9:4];
                        ImageBuffer[p7] <= sum[9:4];
                        ImageBuffer[p8] <= sum[9:4];
                        ImageBuffer[p9] <= sum[9:4];
                        ImageBuffer[p10] <= sum[9:4];
                        ImageBuffer[p11] <= sum[9:4];
                        ImageBuffer[p12] <= sum[9:4];
                        ImageBuffer[p13] <= sum[9:4];
                        ImageBuffer[p14] <= sum[9:4];
                        ImageBuffer[p15] <= sum[9:4];
                        ImageBuffer[p16] <= sum[9:4];
                    end
                endcase
            end
            WRITE,
            WRITE_RD: begin
                if (IRAM_ceb && !IRAM_web)
                    IRAM_D <= ImageBuffer[counter];
            end
        endcase
    end
endmodule
