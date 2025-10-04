`timescale 1ns / 1ps

module tb_host;
    reg asclk;
    reg aresetn;
    
    reg start_w;
    reg start_r;
    
    reg r_cnt_rdy;
    reg w_cnt_rdy;
    reg in_rdy;
    //
    wire [13:0] r_cnt_id; 
    wire r_cnt_vld;
    wire [13:0] w_cnt_id; 
    wire w_cnt_vld; 
    wire [511:0] w_cnt_data;
   
    wire in_vld;
    wire [95:0] in_pkt_id; 
    wire [15:0] in_pkt_len; 
    wire [13:0] in_cnt_id; 
    wire in_cnt_en; 
    wire in_ul;
    //
    host uut(
        .asclk(asclk),
        .aresetn(aresetn),
        .start_w(start_w),
        .start_r(start_r),
        
        .r_cnt_rdy(r_cnt_rdy),
        .w_cnt_rdy(w_cnt_rdy),
        
        //
        .r_cnt_id(r_cnt_id), 
        .r_cnt_vld(r_cnt_vld),
        .w_cnt_id(w_cnt_id), 
        .w_cnt_vld(w_cnt_vld), 
        .w_cnt_data(w_cnt_data),
        
        //
        .in_rdy(in_rdy),
        
        //
        .in_vld(in_vld),
        .in_pkt_id(in_pkt_id), 
        .in_pkt_len(in_pkt_len), 
        .in_cnt_id(in_cnt_id), 
        .in_cnt_en(in_cnt_en), 
        .in_ul(in_ul)
    );
    //
    initial begin
        asclk = 1'b1;
        forever #1 asclk = ~asclk; // 2ns period
    end
    
    initial begin
        aresetn = 0;
        
        r_cnt_rdy = 1;
        w_cnt_rdy = 1;
        in_rdy = 1;
        #10
        aresetn = 1;
        start_w = 1;
        start_r = 0;
        
        in_rdy = 0;
        #6
        in_rdy = 1;
        
        #10
        in_rdy = 0;
        #6
        in_rdy = 1;
        #100
        
        start_w = 0;
        start_r = 1;
    end
endmodule
