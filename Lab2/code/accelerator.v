`timescale 1ns / 1ps

module accelerator(
	input rst_i,
	input clk_i,
	input [7 : 0] a_in,
	input [7 : 0] b_in,
	output busy_out,
	output reg [15 : 0] y_out
);

    reg [7 : 0] a, b;
    reg [1 : 0] state, state_next;

    localparam IDLE = 2'b00;
    localparam WORK1 = 2'b01;
    localparam WORK2 = 2'b10;
    localparam WORK3 = 2'b11;

    wire [2:0] cbrt1_out;
    reg cbrt1_reset;
    wire cbrt1_busy;

    cbrt cbrt1(
        .clk_i(clk_i),
        .rst_i(cbrt1_reset),
        .a_bi(b),
        .busy_o(cbrt1_busy),
        .y_bo(cbrt1_out)
    );

    wire [15:0] mult1_out;
    reg mult1_reset;
    wire mult1_busy;

    mult mult1(
    	.clk_i(clk_i),
    	.rst_i(mult1_reset),
    	.a_bi(a),
    	.b_bi(a),
    	.busy_o(mult1_busy),
    	.y_bo(mult1_out)
    );

    assign busy_out = rst_i | (state != 0);

    always @(posedge clk_i) 
        if (rst_i) begin
            state <= WORK1;
        end else begin
            state <= state_next;
        end
        
    always @* begin
        case(state)
            IDLE: state_next = IDLE;
            WORK1: state_next = WORK2;
            WORK2: state_next = (mult1_busy | cbrt1_busy) ? WORK2 : WORK3;
            WORK3: state_next = IDLE;
        endcase
    end

    always @(posedge rst_i) begin
    end

    always @(posedge clk_i) begin
        if (rst_i) begin
            a <= a_in;
            b <= b_in;
            y_out <= 0;
            mult1_reset <= 0;
            cbrt1_reset <= 0;
        end else begin
            case (state)
                IDLE:
                    begin
                        y_out <= cbrt1_out + mult1_out;
                    end
                WORK1:
                    begin
                        mult1_reset <= 1;
                        cbrt1_reset <= 1;
                    end
                WORK2:
                    begin
                        if (mult1_busy) begin
                            mult1_reset <= 0;
                        end

                        if (cbrt1_busy) begin
                            cbrt1_reset <= 0;
                        end

                    end
                WORK3:
                    begin
                        y_out <= cbrt1_out + mult1_out;
                    end
            endcase
        end
    end

endmodule