`timescale 1ns / 1ps

module test;
    reg reset_reg, clk_reg;
    wire clk, reset;
    
    reg [7:0] a;
    reg [7:0] b;
    wire busy;
    wire [16:0] y_bo;
    
    accelerator accelerator1(
        .clk_i(clk_reg),
        .rst_i(reset),
        .a_in(a),
        .b_in(b),
        .busy_out(busy),
        .y_out(y_bo)
    );
    
    assign reset = reset_reg;
    assign clk = clk_reg;
    
    initial begin
        clk_reg = 1;
        forever
            #10 clk_reg = ~clk_reg;
    end
    
    initial begin
        a <= 0;
        b <= 0;
        reset_reg <= 1;
    end
    
    always @(posedge clk_reg) begin
        if (reset_reg) begin
            reset_reg = 0;
        end
    end
    
    always @(posedge clk_reg) begin
        if (reset_reg) begin
            reset_reg = 0;
        end
        
        if (!busy) begin
            $display("%d^2 + floor cbrt %d = %d", a, b, y_bo);
            
            if (!reset_reg) begin
                a <= a + 1;
                b <= b + 1;
                reset_reg <= 1;
            end
        end
    end 
endmodule