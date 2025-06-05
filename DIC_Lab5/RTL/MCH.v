module MCH (
    input               clk,
    input               reset,
    input       [ 7:0]  X,
    input       [ 7:0]  Y,
    output              Done,
    output      [16:0]  area
);

    //================================================================
    //  Parameters
    //================================================================

    // registers for coordinates
    reg [7:0] px [0:19];
    reg [7:0] py [0:19];

    reg [4:0] load_counter;  
    reg [4:0] anchor_idx;

    // registers for insertion sort
    wire signed [18:0] cp_insert;
    reg [1:0] swapped_anchor;
    reg [7:0] tmp_x, tmp_y;
    reg [4:0] sorted_idx;  // current element to insert
    reg [4:0] shift_idx;   // index used to scan left for insertion
    reg       inserting;
    reg shift_phase;
    reg [7:0] shift_x, shift_y;


    // registers for stack
    reg [4:0] stack [0:19]; 
    reg [4:0] top;
    reg [4:0] scan_idx;

    // registers for area calculation
    reg signed [31:0] sum;
    reg        [4:0] area_idx;
    wire       [4:0] j;

    //================================================================
    //  Functions
    //================================================================

    // cross product
    function signed [18:0] cross;
        input [7:0] ax, ay, bx, by, cx, cy;
        begin
            cross = ($signed({1'b0,bx})-$signed({1'b0,ax}))*
                    ($signed({1'b0,cy})-$signed({1'b0,ay})) -
                    ($signed({1'b0,by})-$signed({1'b0,ay}))*
                    ($signed({1'b0,cx})-$signed({1'b0,ax}));
        end
    endfunction

    //================================================================
    //  FSM
    //================================================================

    // state
    reg [2:0] cur_state;
    reg [2:0] next_state;

    // stage parameters
    parameter LOAD          = 3'b000;
    parameter SORT          = 3'b001;
    parameter LOWER         = 3'b010;
    parameter AREA          = 3'b011;
    parameter DONE          = 3'b100;

    // state register
    always @(posedge clk) begin
        if (reset)
            cur_state <= LOAD;
        else
            cur_state <= next_state;
    end

    // next state logic 
    always @(*) begin 
        case (cur_state)
            LOAD: begin
                next_state = (load_counter == 5'd19) ? SORT : LOAD;
            end
            SORT: begin
                next_state = (sorted_idx == 5'd20) ? LOWER : SORT;
            end
            LOWER: begin
                next_state = (scan_idx == 5'd20) ? AREA : LOWER;
            end
            AREA: begin
                next_state = (area_idx == top - 1) ? DONE : AREA;
            end
            DONE: begin
                next_state = LOAD;
            end
            default: next_state = LOAD;
        endcase
    end

    //================================================================
    //  Load
    //================================================================

    // load counter
    always @(posedge clk) begin
        if (reset)
            load_counter <= 5'd0;
        else if (cur_state == LOAD)
            load_counter <= load_counter + 5'd1;
        else if (cur_state == DONE)
            load_counter <= 5'd0;
        else
            load_counter <= load_counter;
    end

    // anchor
    always @(posedge clk) begin
        if (reset)
            anchor_idx   <= 5'b0;
        else if (cur_state == LOAD) begin
                if ((Y < py[anchor_idx]) || (Y == py[anchor_idx] && X < px[anchor_idx]))
                    anchor_idx <= load_counter;
                else
                    anchor_idx <= anchor_idx;
        end else if (cur_state == DONE)
            anchor_idx   <= 5'b0;
        else begin
            anchor_idx   <= anchor_idx;
        end
    end


    //================================================================
    //  Insertion Sort
    //================================================================
    
    assign cp_insert = (shift_idx < 20) ? cross(px[0], py[0], px[shift_idx], py[shift_idx], tmp_x, tmp_y) : 19'd0;
    
    integer i;
    always @(posedge clk) begin
        if (reset || cur_state == DONE) begin
            sorted_idx     <= 5'd2;
            shift_idx      <= 5'd1;
            inserting      <= 1'b0;
            shift_phase    <= 1'b0;
            swapped_anchor <= 2'd0;
            tmp_x          <= 8'd0;
            tmp_y          <= 8'd0;
            for (i = 0; i < 20; i = i + 1) begin
                px[i] <= 8'd0;
                py[i] <= 8'd0;
            end
        end else if (cur_state == LOAD) begin
            px[load_counter] <= X;
            py[load_counter] <= Y;
        end else if (cur_state == SORT && swapped_anchor == 2'd0) begin
            swapped_anchor <= 2'd1;
            tmp_x <= px[0];
            tmp_y <= py[0];
            px[0] <= px[anchor_idx];
            py[0] <= py[anchor_idx];
        end else if (cur_state == SORT && swapped_anchor == 2'd1) begin
            swapped_anchor <= 2'd2;
            px[anchor_idx] <= tmp_x;
            py[anchor_idx] <= tmp_y;
        end else if (cur_state == SORT && swapped_anchor == 2'd2) begin
            if (!inserting) begin
                tmp_x <= px[sorted_idx];
                tmp_y <= py[sorted_idx];
                shift_idx <= sorted_idx - 1;
                inserting <= 1'b1;
                shift_phase <= 1'b0;
            end else if (inserting && !shift_phase) begin
                if (shift_idx >= 1 && cp_insert < 0) begin
                    shift_x <= px[shift_idx];
                    shift_y <= py[shift_idx];
                    shift_phase <= 1'b1;
                end else begin
                    px[shift_idx + 1] <= tmp_x;
                    py[shift_idx + 1] <= tmp_y;
                    sorted_idx <= sorted_idx + 1;
                    inserting <= 1'b0;
                end
            end else if (inserting && shift_phase) begin
                px[shift_idx + 1] <= shift_x;
                py[shift_idx + 1] <= shift_y;
                shift_idx <= shift_idx - 1;
                shift_phase <= 1'b0;
            end
        end
    end

    //================================================================
    //  Stack
    //================================================================

    always @(posedge clk) begin
        if (reset || cur_state == DONE) begin
            top <= 2;                       // stack[0]=0(anchor), stack[1]=1
            scan_idx <= 5'd2;
            stack[0] <= 5'b0;
            stack[1] <= 5'b1;
            for (i = 2; i < 20; i = i + 1) begin
                stack[i] <= 5'b0;
            end
        end else if (cur_state == LOWER) begin
            if (scan_idx < 5'd20) begin
                // If the turn is not a left turn (cross ≤ 0), pop the last point
                if (top >= 2 && cross( px[ stack[top-2] ], py[ stack[top-2] ], px[ stack[top-1] ], py[ stack[top-1] ], px[ scan_idx     ], py[ scan_idx     ]) <= 0 )
                    top <= top - 1;              // Pop
                else begin
                    stack[top] <= scan_idx;      // Push
                    top        <= top + 1;
                    scan_idx   <= scan_idx + 1;
                end
            end
        end
    end

    //================================================================
    //  Area
    //================================================================

    assign j = (area_idx == top-1) ? 5'd0 : area_idx + 5'd1;

    // Area calculation using the shoelace formula
    always @(posedge clk) begin
        if (reset || cur_state == DONE) begin
            sum <= 0;
        end else if (cur_state == AREA) begin
            sum <= sum + $signed({1'b0, px[ stack[area_idx] ]}) * 
                         $signed({1'b0, py[ stack[j] ]}) -
                         $signed({1'b0, px[ stack[j] ]}) * 
                         $signed({1'b0, py[ stack[area_idx] ]});
        end else begin
            sum <= sum;
        end
    end

    // Area index
    always @(posedge clk) begin
        if (reset || cur_state == DONE) begin
            area_idx <= 0;
        end else if (cur_state == AREA) begin
            area_idx <= area_idx + 1'b1;
        end else begin
            area_idx <= area_idx;
        end
    end

    //================================================================
    //  Control Signals
    //================================================================
    assign area = sum;
    assign Done = (cur_state == DONE);

endmodule

endmodule
