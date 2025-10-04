module top(
    input i_clk_p,
    input i_clk_n,
    input areset,
    //=====
//    input asclk,
//    input aresetn,
    
    input start_w,
    input start_r,
    

    output [2:0] out_cnt_policy,
    output [21:0] out_cnt_report,
    output [95:0] out_pkt_id,
    output [15:0] out_pkt_len,
    output out_ul,
    output out_vld, 
    output out_rdy,
    output out_cnt_en
    
//    output check_policy,
//    output check_false_policy
    );
    //
    wire asclk;         // T�n hi?u ??ng h? single-ended sau khi k?t h?p
    wire aresetn;
    assign aresetn = !areset;
    
    wire [23:0] timer;
    //
    wire r_cnt_rdy;
    wire w_cnt_rdy;
    
    //
    wire [13:0] r_cnt_id; 
    wire r_cnt_vld;
    wire [13:0] w_cnt_id; 
    wire w_cnt_vld; 
    wire [511:0] w_cnt_data;
    
    //
    wire in_rdy;
    
    //
    wire in_vld;
    wire [95:0] in_pkt_id; 
    wire [15:0] in_pkt_len; 
    wire [13:0] in_cnt_id; 
    wire in_cnt_en; 
    wire in_ul;
    
    //
    wire r_cnt_data_vld;
    wire [511:0] r_cnt_data;
    wire stop_update;
    // 
//    wire [2:0] out_cnt_policy; 
//    wire [95:0] out_pkt_id; 
//    wire [15:0] out_pkt_len;
//    wire [21:0] out_cnt_report;
//    wire out_ul;
//    wire out_vld; 
//    wire out_rdy;
//    wire out_cnt_en;

//    wire [28:0] pkt_per_sec_max;
    
    //
//    wire check_policy;
//    wire check_false_policy;
    
    wire [47:0] drop_counting;
    wire [47:0] sendtohost_counting;
    wire [47:0] forward_counting;
    wire [47:0] drop_capacity;
    wire [47:0] sendtohost_capacity;
    wire [47:0] forward_capacity;
//    wire [32*10-1:0] statstics;
   
  clk_wiz_0 instance_name
   (
    .clk_out1(asclk),     // output clk_out1
   // Clock in ports
    .clk_in1_p(i_clk_p),    // input clk_in1_p
    .clk_in1_n(i_clk_n));    // input clk_in1_n
    
   ila_0 ila1 (
       .clk(asclk), // input wire clk
    
       .probe0(asclk),
       .probe1(aresetn), // input wire [0:0]  probe0  
       .probe2(start_w), // input wire [0:0]  probe1 
       .probe3(start_r), // input wire [0:0]  probe2 
       .probe4(check_policy), // input wire [0:0]  probe3 
       .probe5(r_cnt_rdy), // input wire [0:0]  probe4 
       .probe6(w_cnt_rdy), // input wire [0:0]  probe5 
       .probe7(r_cnt_id), // input wire [0:0]  probe6 
       .probe8(r_cnt_vld), // input wire [13:0]  probe7 
       .probe9(w_cnt_id), // input wire [0:0]  probe8 
       .probe10(w_cnt_vld), // input wire [13:0]  probe9 
       .probe11(w_cnt_data), // input wire [0:0]  probe10 
       .probe12(in_rdy), // input wire [511:0]  probe11 
       .probe13(in_vld), // input wire [0:0]  probe12 
       .probe14(in_pkt_id), // input wire [0:0]  probe13 
       .probe15(in_pkt_len), // input wire [95:0]  probe14 
       .probe16(in_cnt_id), // input wire [15:0]  probe15 
       .probe17(in_cnt_en), // input wire [13:0]  probe16 
       .probe18(in_ul), // input wire [0:0]  probe17 
       .probe19(r_cnt_data_vld), // input wire [0:0]  probe18 
       .probe20(r_cnt_data), // input wire [0:0]  probe19 
       .probe21(out_pkt_id), // input wire [0:0]  probe20 
       .probe22(out_pkt_len), // input wire [95:0]  probe21 
       .probe23(out_cnt_policy), // input wire [15:0]  probe22 
       .probe24(out_cnt_report), // input wire [2:0]  probe23 
       .probe25(out_ul), // input wire [21:0]  probe24 
       .probe26(out_vld), // input wire [0:0]  probe25 
       .probe27(out_rdy), // input wire [0:0]  probe26 
       .probe28(pkt_per_sec_max),
       .probe29(check_false_policy), // input wire [95:0]  probe21 
       .probe30(drop_counting), // input wire [15:0]  probe22 
       .probe31(sendtohost_counting), // input wire [2:0]  probe23 
       .probe32(forward_counting), // input wire [21:0]  probe24 
       .probe33(drop_capacity), // input wire [0:0]  probe25 
       .probe34(sendtohost_capacity), // input wire [0:0]  probe26 
       .probe35(forward_capacity),
       .probe36(out_cnt_en)
   );
    
    //host
    host host(
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
        .in_vld(in_vld),
        .in_pkt_id(in_pkt_id), 
        .in_pkt_len(in_pkt_len), 
        .in_cnt_id(in_cnt_id), 
        .in_cnt_en(in_cnt_en), 
        .in_ul(in_ul),
        .timer(timer)
    );
//    host_config host_config(
//        .asclk(asclk),
//        .aresetn(aresetn),
//        .start_w(start_w),  
//        .start_r(start_r),   
    
//        .r_cnt_rdy(r_cnt_rdy),
//        .w_cnt_rdy(w_cnt_rdy),
        
//        //
//        .r_cnt_id(r_cnt_id), 
//        .r_cnt_vld(r_cnt_vld),
//        .w_cnt_id(w_cnt_id), 
//        .w_cnt_vld(w_cnt_vld), 
//        .w_cnt_data(w_cnt_data),
        
//        //
//        .stop_update(stop_update),
//        .timer(timer)
//    );
    
//    packet_gen packet_gen(
//        .asclk(asclk),
//        .aresetn(aresetn),  
//        .stop_update(stop_update),   
    
//        //
//        .in_rdy(in_rdy),
//        .in_vld(in_vld),
//        .in_pkt_id(in_pkt_id), 
//        .in_pkt_len(in_pkt_len), 
//        .in_cnt_id(in_cnt_id), 
//        .in_cnt_en(in_cnt_en), 
//        .in_ul(in_ul)
//    );
    
    charging charging(
        .asclk(asclk),
        .aresetn(aresetn),
        .timer(timer),
        
        .r_cnt_id(r_cnt_id), 
        .r_cnt_vld(r_cnt_vld),
        .r_cnt_rdy(r_cnt_rdy), 
        .r_cnt_data_vld(r_cnt_data_vld), 
        .r_cnt_data(r_cnt_data),  
        
        .w_cnt_id(w_cnt_id), 
        .w_cnt_vld(w_cnt_vld), 
        .w_cnt_data(w_cnt_data),
        .w_cnt_rdy(w_cnt_rdy),
        
        .in_vld(in_vld),
        .in_pkt_id(in_pkt_id), 
        .in_pkt_len(in_pkt_len), 
        .in_cnt_id(in_cnt_id), 
        .in_cnt_en(in_cnt_en), 
        .in_ul(in_ul),
        .in_rdy(in_rdy),
        
        .out_pkt_id(out_pkt_id), 
        .out_pkt_len(out_pkt_len), 
        .out_cnt_policy(out_cnt_policy), 
        .out_cnt_report(out_cnt_report), 
        .out_ul(out_ul),
        .out_vld(out_vld), 
        .out_rdy(out_rdy),
        .out_cnt_en(out_cnt_en)
    );
    
        // eval_test eval_test(
        // .asclk(asclk),
        // .aresetn(aresetn),
        // .out_rdy(out_rdy)
        // );
   evaluation evaluation(
       .asclk(asclk),
       .aresetn(aresetn),
        
       .out_pkt_id(out_pkt_id), 
       .out_pkt_len(out_pkt_len), 
       .out_cnt_policy(out_cnt_policy), 
       .out_cnt_report(out_cnt_report), 
       .out_ul(out_ul),
       .out_vld(out_vld), 
       .out_cnt_en(out_cnt_en),
        
       .out_rdy(out_rdy),
       .check_policy(check_policy),
       .check_false_policy(check_false_policy),
       .pkt_per_sec_max(pkt_per_sec_max),
       .drop_counting(drop_counting),
       .sendtohost_counting(sendtohost_counting),
       .forward_counting(forward_counting),
       .drop_capacity(drop_capacity),
       .sendtohost_capacity(sendtohost_capacity),
       .forward_capacity(forward_capacity)
        
   );
    
endmodule

