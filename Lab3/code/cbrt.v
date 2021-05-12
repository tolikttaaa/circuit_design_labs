`timescale 1ns / 1ps

module cbrt (
	input clk_i,
	input rst_i ,
	input [7 : 0] a_bi,
	output busy_o,
	output reg [2 : 0] y_bo
);

	localparam IDLE = 3'b000;
	localparam STATE1 = 3'b001;
	localparam STATE2 = 3'b010;
	localparam STATE3 = 3'b011;
	localparam STATE4 = 3'b100;
	localparam STATE5 = 3'b101;
	localparam STATE6 = 3'b110;
	localparam STATE7 = 3'b111;

	reg [7 : 0] a;

	reg [3 : 0] r, m;
	reg [7 : 0] t;

	reg [2 : 0] state;
	reg [2 : 0] state_next;

	reg [7:0] mult2_i1;
    reg [7:0] mult2_i2;
    wire [15:0] mult2_out;
    reg mult2_reset;
    wire mult2_busy;

    mult mult2(
        .clk_i(clk_i),
        .rst_i(mult2_reset),
        .a_bi(mult2_i1),
        .b_bi(mult2_i2),
        .busy_o(mult2_busy),
        .y_bo(mult2_out)
    );

	assign busy_o = rst_i | (state != 0);
	
	always @(posedge clk_i) 
        if (rst_i) begin
            state <= STATE1;
        end else begin
            state <= state_next;
        end

    always @* begin
        case(state)
            IDLE: state_next = IDLE;
            STATE1: state_next = (m != 0) ? STATE2 : IDLE;
            STATE2: state_next = mult2_busy ? STATE2 : STATE3;
            STATE3: state_next = mult2_busy ? STATE3 : STATE4;
            STATE4: state_next = STATE1;
        endcase
    end

    always @(posedge clk_i) begin
        if (rst_i) begin
            a <= a_bi;
            t <= 0;
            r <= 3;
            m <= 3;
            y_bo <= 0;
            mult2_reset <= 0;
        end else begin
	        case (state)
	            IDLE:
	                begin
                       y_bo <= r[2:0];
	                end
	            STATE1:
	                begin
	                   y_bo <= r[2:0];
	                   if (|m) begin
	                       mult2_reset <= 1;
	                       mult2_i1 <= r;
	                       mult2_i2 <= r;
	                   end
	                end
	            STATE2:
	                begin
	                    if (mult2_busy) begin
	                        mult2_reset <= 0;
	                    end else begin
	                        mult2_reset <= 1;
	                        mult2_i1 <= mult2_out[7:0];
	                        mult2_i2 <= r;
	                    end
	                end
	            STATE3:
	                begin
	                    mult2_reset <= 0;
	                    if (!mult2_busy) begin
	                        if (a == mult2_out[7:0]) begin
	                            m = 0;
	                        end else if (a < mult2_out[7:0]) begin
	                            r = r - m;
	                        end else begin
	                            r = r + m;
	                        end
	                        
	                        if (r > 6) begin 
	                           r = 6;
	                        end
	                    end
	                end
	            STATE4:
	                begin
	                    if (m > 0) begin
	                        m = m - 1;
	                    end
	                 end
	        endcase
        end
    end
endmodule