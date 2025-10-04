`timescale 1ns / 1ps

module tb_wrap;
    // Clock and Reset
    reg asclk;
    reg aresetn;
//    reg [23:0] timer;
    
    reg start_w;
    reg start_r;
    
    wire check_policy;
    wire check_false_policy;
    
    //
    wrap uut(
        .asclk(asclk),
        .aresetn(aresetn),
//        .timer(timer),
        
        .start_w(start_w),
        .start_r(start_r),
        
        .check_policy(check_policy),
        .check_false_policy(check_false_policy)
    );
    //
    initial begin
        asclk = 1'b1;
//        timer = 0;
        forever #1 asclk = ~asclk; // 2ns period
    end
    
    //
//    always @(posedge asclk) begin
//        timer <= timer + 1;
//    end
    
    //    
    initial begin
        aresetn = 0;
        #10
        aresetn = 1;
        start_w = 0;
        start_r = 0;
        #150
        
        start_w = 1;
        start_r = 0;
        #4
        start_w = 0;
        start_r = 0;
        #4
        start_w = 1;
        start_r = 0;
        
        #8
        start_w = 0;
        start_r = 0;
        #8
        start_w = 1;
        start_r = 0;
        #300
        start_w = 0;
        start_r = 0;
        #10
        
        start_w = 0;
        start_r = 1;
        #50
        start_w = 0;
        start_r = 0;
        #4
        start_w = 0;
        start_r = 1;
    end
endmodule
