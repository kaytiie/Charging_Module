`timescale 1ns / 1ps
// TEST CASE: 2 id

module host_config(
    input asclk,
    input aresetn,
    input start_w,
    input start_r,
    
    //
    input r_cnt_rdy,
    input w_cnt_rdy,
    //
    input [32*9  - 1:0] host_data0,
    input host_data_valid,
    //
    output reg [13:0] r_cnt_id, 
    output reg r_cnt_vld,
    output reg [13:0] w_cnt_id, 
    output reg w_cnt_vld, 
    output reg [511:0] w_cnt_data,
    output reg stop_update
    //
    );
    
    reg [3:0] flag;
    
    reg [48:0] quota_total;
    reg [48:0] quota_uplink;
    reg [48:0] quota_downlink;
    
    reg [48:0] thres_total;
    reg [48:0] thres_uplink;
    reg [48:0] thres_downlink;
    
//Gi?i h?n 200 giá tr?
    reg [7:0] init_cnt;        // ??m s? l?n ?ã kh?i t?o (t?i ?a 200)
//    reg stop_update;           // Tín hi?u d?ng update sau 200 l?n
//    reg [47:0] len_total;
//
//-------------------------------------------------------------------------   
    // vld and rdy
    always @(posedge asclk or negedge aresetn) begin
        if (!aresetn) begin
            w_cnt_vld <= 0;
            r_cnt_vld <= 0;
        end else begin
            w_cnt_vld <= start_w & host_data_valid;
            r_cnt_vld <= start_r & host_data_valid;
        end
    end
//=============================   
    always @(posedge asclk or negedge aresetn) begin
           if(!aresetn) begin
//               w_cnt_id <= host_data0[32*0 +: 32];
//               r_cnt_id <= host_data0[32*0 +: 32];
//               w_cnt_data[7:0]     <= host_data0[32*1 +: 32];                          // quota_flag (8 bits) down-up-total
//                w_cnt_data[55:8]    <= host_data0[32*2 +: 32];                   // quota_total (48 bits)
//                w_cnt_data[103:56]  <= host_data0[32*3 +: 32];                   // quota_uplink (48 bits)
//                w_cnt_data[151:104] <= host_data0[32*4 +: 32];                  // quota_downlink (48 bits)
                
//                // thres group
//                w_cnt_data[159:152] <= host_data0[32*5 +: 32];                         // thres_flag (8 bits)
//                w_cnt_data[207:160] <= host_data0[32*6 +: 32];                   // thres_total (48 bits)
//                w_cnt_data[255:208] <= host_data0[32*7 +: 32];                  // thres_uplink (48 bits)
//                w_cnt_data[303:256] <= host_data0[32*8 +: 32];                  // thres_downlink (48 bits)
                
//                w_cnt_data[351:304] <= 48'b0;
//                w_cnt_data[399:352] <= 48'b0;
//                w_cnt_data[463:400] <= 64'b0;
//                w_cnt_data[511:464] <= 48'b0;
                w_cnt_id <= host_data0[32*0 +: 14];
                r_cnt_id <= host_data0[32*0 +: 14];
                w_cnt_data <= 512'd0;
           end
           else if(w_cnt_vld & w_cnt_rdy & !stop_update & host_data_valid )  begin
               w_cnt_id <= w_cnt_id + 1;
               
                w_cnt_data[7:0]     <= host_data0[32*1 +: 32];                          // quota_flag (8 bits) down-up-total
                w_cnt_data[55:8]    <= host_data0[32*2 +: 32];                   // quota_total (48 bits)
                w_cnt_data[103:56]  <= host_data0[32*3 +: 32];                   // quota_uplink (48 bits)
                w_cnt_data[151:104] <= host_data0[32*4 +: 32];                  // quota_downlink (48 bits)
                
                // thres group
                w_cnt_data[159:152] <= host_data0[32*5 +: 32];                         // thres_flag (8 bits)
                w_cnt_data[207:160] <= host_data0[32*6 +: 32];                   // thres_total (48 bits)
                w_cnt_data[255:208] <= host_data0[32*7 +: 32];                  // thres_uplink (48 bits)
                w_cnt_data[303:256] <= host_data0[32*8 +: 32];                  // thres_downlink (48 bits)

           end
           else if (r_cnt_vld & r_cnt_rdy & host_data_valid ) begin
               r_cnt_id <= r_cnt_id + 1;
           end
         end
    
    
//============================
    // B? ??m s? l?n update
    always @(posedge asclk or negedge aresetn) begin
        if (!aresetn) begin
            init_cnt <= 8'd0;
            stop_update <= 1'b0;
        end else if (w_cnt_vld && w_cnt_rdy && !stop_update && host_data_valid ) begin
            if (init_cnt == 8'd5) begin
                stop_update <= 1'b1; // ?? 150 l?n thì khóa
            end else begin
                init_cnt <= init_cnt + 1'b1;
            end
        end
    end
//-----------------------------------------------------------------------------
endmodule