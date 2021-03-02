`timescale 1ns / 1ps

module demultiplexer(
        input m1,
        input m2,
        input in,
        output o1,
        output o2,
        output o3,
        output o4
    );
    
    wire not_m1, not_m2;
    
    not(not_m1, m1);
    not(not_m2, m2);
    
    and(o1, in, m1, m2);
    and(o2, in, m1, not_m2);
    and(o3, in, not_m1, m2);
    and(o4, in, not_m1, not_m2);
endmodule
