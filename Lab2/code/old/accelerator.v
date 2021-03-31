`timescale 1ns / 1ps

module accelerator(
	input rst_i,
	input clk_i,
	input [7:0] a_in,
	input [7:0] b_in,
	output busy_out,
	output [16:0] y_out
);
    reg [7:0] a;
    reg [7:0] b;

    reg [15:0] t;
    reg [16:0] r;
    reg [2:0] m;

    reg [2:0] state, state_next;

    reg [7:0] mult1_i1;
    reg [7:0] mult1_i2;
    wire [15:0] mult1_out;
    reg mult1_reset;
    wire mult1_busy;

    mult mult_1(
    	.clk_i(clk_i),
    	.rst_i(mult1_reset),
    	.a_bi(mult1_i1),
    	.b_bi(mult1_i2),
    	.busy_o(mult1_busy),
    	.y_bo(mult1_out)
    );

    reg [7:0] mult2_i1;
    reg [7:0] mult2_i2;
    wire [15:0] mult2_out;
    reg mult2_reset;
    wire mult2_busy;

    mult mult_2(
        .clk_i(clk_i),
        .rst_i(mult2_reset),
        .a_bi(mult2_i1),
        .b_bi(mult2_i2),
        .busy_o(mult2_busy),
        .y_bo(mult2_out)
    );

    localparam STATE0 = 3'b000;
    localparam STATE1 = 3'b001;
    localparam STATE2 = 3'b010;
    localparam STATE3 = 3'b011;
    localparam STATE4 = 3'b100;
    localparam STATE5 = 3'b101;
    localparam STATE6 = 3'b110;
    localparam STATE7 = 3'b111;

    assign busy_out = rst_i | (state != STATE0);
    assign y_out = r;

    always @(posedge clk_i) 
        if (rst_i) begin
            state <= STATE1;
        end else begin
            state <= state_next;
        end
        
    always @* begin
        case(state)
            STATE0: state_next = STATE0;
            STATE1: state_next = STATE2;
            STATE2: state_next = (m != 0) ? STATE3 : (mult2_busy ? STATE2 : STATE6);
            STATE3: state_next = mult1_busy ? STATE3 : STATE4;
            STATE4: state_next = mult1_busy ? STATE4 : STATE5;
            STATE5: state_next = STATE2;
            STATE6: state_next = STATE0;
        endcase
    end

    always @(posedge rst_i) begin
    end

    always @(posedge clk_i) begin
        if (rst_i) begin
            a <= a_in;
            b <= b_in;
            t <= 0;
            r <= 4;
            m <= 4;
            mult1_reset <= 0;
            mult2_reset <= 0;
        end else begin
            case (state)
                STATE0:
                    begin
                    end
                STATE1:
                    begin
                        mult2_reset <= 1;
                        mult2_i1 <= a;
                        mult2_i2 <= a;
                    end
                STATE2:
                    begin
                        if (mult2_busy) begin
                            mult2_reset <= 0;
                        end
                        
                        if (m != 0) begin
                            mult1_reset <= 1;
                            mult1_i1 <= r;
                            mult1_i2 <= r;
                        end
                    end
                STATE3:
                    begin
                        if (mult1_busy) begin
                            mult1_reset <= 0;
                        end else begin
                            mult1_reset <= 1;
                            mult1_i1 <= mult1_out;
                            mult1_i2 <= r;
                        end
                    end
                STATE4:
                    begin
                        mult1_reset <= 0;
                        if (!mult1_busy) begin
                            if (b == mult1_out) begin
                                m <= 0;
                            end else if (b <= mult1_out) begin
                                r = r - m;
                            end else begin
                                r = r + m;
                            end
                        end
                    end
                STATE5:
                     begin
                        if (m >= 1) begin
                            m <= m >> 1;
                        end
                     end
                STATE6:
                    begin
                        if (!mult1_busy) begin
                            r = r + mult2_out;
                        end
                    end
            endcase
        end
    end

endmodule
