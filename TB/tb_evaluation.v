`timescale 1ns / 1ps

module tb_evaluation;
    reg asclk;
    reg aresetn;
    
    reg [95:0] out_pkt_id; 
    reg [15:0] out_pkt_len; 
    reg [2:0] out_cnt_policy; 
    reg [21:0] out_cnt_report; 
    reg out_ul;
    reg out_vld; 
    
    //
    wire out_rdy;
    wire check_policy;
    
    evaluation uut(
        .asclk(asclk),
        .aresetn(aresetn),
        .out_pkt_id(out_pkt_id),
        .out_pkt_len(out_pkt_len),
        .out_cnt_policy(out_cnt_policy),
        .out_cnt_report(out_cnt_report),
        .out_ul(out_ul), 
        .out_vld(out_vld),
        
        .out_rdy(out_rdy), 
        .check_policy(check_policy)
    );
    
    //
    initial begin
        asclk = 1'b1;
        forever #1 asclk = ~asclk; // 2ns period
    end
    
    // Random generation for packet inputs
    always @(posedge asclk) begin
        if (out_vld == out_rdy) begin
            out_pkt_id <= 9; 
            out_pkt_len <= 100000; 
            out_cnt_policy <= 4; 
            out_cnt_report <= 22'b0011111100000000001001; 
            out_ul <= 1;
        end
    end
    
    initial begin
        aresetn = 0;
        #10
        aresetn = 1;
        #30
        out_vld = 1;
        
//        repeat (3) begin
//            #2 start_wr = 1;
//            #50 start_wr = 0;
//            #100;
//        end

//        #200;
    end
endmodule
