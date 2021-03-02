`timescale 1ns / 1ps

module demultiplexer_tb;
    reg m1_in, m2_in, in_in;
    wire o1_out, o2_out, o3_out, o4_out;
    
    demultiplexer demultiplexer_1(
        .m1(m1_in),
        .m2(m2_in),
        .in(in_in),
        .o1(o1_out),
        .o2(o2_out),
        .o3(o3_out),
        
        .o4(o4_out)
    );
    
    integer i;
    reg [2:0] test_val;
    
    initial begin
        for (i = 0; i < 8; i = i + 1) begin
            test_val = i;
            m1_in = test_val[0];
            m2_in = test_val[1];
            in_in = test_val[2];
            
            #10
            
            if ((m1_in == 1 & m2_in == 1 & in_in == 1 & o1_out == 1 & o2_out == 0 & o3_out == 0 & o4_out == 0) |
                (m1_in == 1 & m2_in == 1 & in_in == 0 & o1_out == 0 & o2_out == 0 & o3_out == 0 & o4_out == 0) |
                (m1_in == 1 & m2_in == 0 & in_in == 1 & o1_out == 0 & o2_out == 1 & o3_out == 0 & o4_out == 0) |
                (m1_in == 1 & m2_in == 0 & in_in == 0 & o1_out == 0 & o2_out == 0 & o3_out == 0 & o4_out == 0) |
                (m1_in == 0 & m2_in == 1 & in_in == 1 & o1_out == 0 & o2_out == 0 & o3_out == 1 & o4_out == 0) |
                (m1_in == 0 & m2_in == 1 & in_in == 0 & o1_out == 0 & o2_out == 0 & o3_out == 0 & o4_out == 0) |
                (m1_in == 0 & m2_in == 0 & in_in == 1 & o1_out == 0 & o2_out == 0 & o3_out == 0 & o4_out == 1) |
                (m1_in == 0 & m2_in == 0 & in_in == 0 & o1_out == 0 & o2_out == 0 & o3_out == 0 & o4_out == 0)) begin
                $display("The demultiplexer output is correct!!!");
            end else begin
                $display("The demultiplexer output is wrong!!!");
            end
    
        end
        
        #10 $stop;
    end
    
    
endmodule
