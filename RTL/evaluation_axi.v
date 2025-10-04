`timescale 1ns / 1ps
// Test 1 id:
module evaluation_axi(
    input asclk,
    input aresetn,
    
    input [95:0] out_pkt_id, 
    input [15:0] out_pkt_len, 
    input [2:0] out_cnt_policy, 
    input [21:0] out_cnt_report, 
    input out_ul,
    input out_vld, 
    input out_cnt_en,
    
    output reg out_rdy,
    output reg check_policy,
    output reg check_false_policy,
    output [32*10-1:0] statistics
    );
    
    //
    reg [15:0] pkt_id; 
    reg [15:0] pkt_len; 
    reg [2:0] cnt_policy; 
    reg [21:0] cnt_report;
    reg [21:0] cnt_report1;
    reg [21:0] cnt_report2;
    reg [21:0] cnt_report3;
    
    reg ul;
    reg pkt_en;
    //
    localparam MAX_TEST_ID = 3;
    localparam MAX_ID = 16583;
    reg [3:0] quota_flag [MAX_TEST_ID-1:0];
    reg [3:0] thres_flag [MAX_TEST_ID-1:0];
    
    reg [47:0] quota_total [MAX_TEST_ID-1:0];
    reg [47:0] quota_uplink [MAX_TEST_ID-1:0];
    reg [47:0] quota_downlink [MAX_TEST_ID-1:0];
    reg [47:0] thres_total [MAX_TEST_ID-1:0];
    reg [47:0] thres_uplink [MAX_TEST_ID-1:0];
    reg [47:0] thres_downlink [MAX_TEST_ID-1:0];
    
    reg [13:0] cnt_id;
    
    reg [6:0]  init_index;
    reg        init_done;
    integer i;
    
    reg [2:0] out_rdy_cnt;
    
    //flag quota vuot nguong
    reg exceed_quo_total;
    reg exceed_quo_uplink;
    reg exceed_quo_downlink;
    //flag thres vuot nguong
    reg exceed_thres_total;
    reg exceed_thres_uplink;
    reg exceed_thres_downlink;
    //
    reg [2:0] policy_quo, policy_thres, policy;
    //
    localparam LATENCY = 3,
               LATENCY1 = 2;
    integer j, k;
    reg [2:0] policy_pipeline [LATENCY-1:0];
    wire [2:0] delayed_policy;
    reg [2:0] policy_reg1;
    reg [2:0] policy_reg2;
    
    reg vld_reg1;
    reg vld_reg2;
    reg vld_reg3;
    reg vld_reg4;
    //
    reg pkt_en1;
    reg pkt_en2;
    reg pkt_en3;
    reg toggle_bit;
    
    reg [31:0] drop_counting;
    reg [31:0] sendtohost_counting;
    reg [31:0] forward_counting;
    reg [31:0] drop_capacity;
    reg [31:0] sendtohost_capacity;
    reg [31:0] forward_capacity;
    
    assign statistics = {
      32'd0,                          // [319:288]
      32'd0,                          // [287:256]
      32'd0,                          // [255:224]
      check_false_policy,                          // [223:192]
      forward_capacity,               // [191:160]
      sendtohost_capacity,            // [159:128]  
      drop_capacity,                  // [127:96]
      {forward_counting},      // [95:64]
      {sendtohost_counting},   // [63:32]
      {drop_counting}          // [31:0] 
    };

    always @(posedge asclk or negedge aresetn) begin
        if (!aresetn) begin
//            out_rdy <= 0;
            for (i = 0; i < MAX_TEST_ID; i = i + 1) begin
                quota_flag[i] <= 4'd0;
                thres_flag[i] <= 4'd0; 
                quota_total[i] <= 48'd0;
                quota_uplink[i] <= 48'd0;
                quota_downlink[i] <= 48'd0;
                thres_total[i] <= 48'd0;
                thres_uplink[i] <= 48'd0;
                thres_downlink[i] <= 48'd0;
            end
            init_index <= 0;
            init_done <= 0;
            toggle_bit <= 1'b1;
            
            //
            exceed_quo_total <= 1'd0;
            exceed_quo_uplink <= 1'd0;
            exceed_quo_downlink <= 1'd0;
            //
            exceed_thres_total <= 1'd0;
            exceed_thres_uplink <= 1'd0;
            exceed_thres_downlink <= 1'd0;
            
            policy_reg1 <= 3'd0;
            
            vld_reg1 <= 0;
            vld_reg2 <= 0;
            vld_reg3 <= 0;
            vld_reg4 <= 0;
            
            pkt_en1 <= 0;
            pkt_en2 <= 0;
            pkt_en3 <= 0;
            
            //
            cnt_report <= 0;
        end else if (!init_done) begin
//            quota_flag[init_index] <= init_index;
//            thres_flag[init_index] <= init_index;
            quota_flag[init_index] <= 8'b00000011;
            thres_flag[init_index] <= 8'b00001011;
            
            quota_total[init_index] <= 32'd102400 ;
            quota_uplink[init_index] <= 32'd71680 ;
            quota_downlink[init_index] <= 32'd30720;
            thres_total[init_index] <= 32'd81920 ;
            thres_uplink[init_index] <= 32'd51200; 
            thres_downlink[init_index] <= 32'd30720; 
            if (init_index == MAX_TEST_ID) begin
                init_done <= 1;
//                out_rdy <= 1;
            end else
                init_index <= init_index + 1;
                toggle_bit <= ~toggle_bit;
        end else if (init_done) begin
            if (out_vld && out_rdy) begin
                vld_reg1 <= 1'b1;  // Capture tín hi?u h?p l?
                pkt_en <= out_cnt_en;
                cnt_report <= out_cnt_report;
            end else begin
                vld_reg1 <= 1'b0;  // Không có tín hi?u m?i thì ghi 0
                pkt_en <= 1'b0;
                cnt_report <= 1'b0;
            end
            vld_reg2 <= vld_reg1;
            vld_reg3 <= vld_reg2;
            vld_reg4 <= vld_reg3;
            
            //
            pkt_en1 <= pkt_en;
            pkt_en2 <= pkt_en1;
            pkt_en3 <= pkt_en2;
            //
            cnt_report1 <= cnt_report;
            cnt_report2 <= cnt_report1;
            cnt_report3 <= cnt_report2;
            
            if (pkt_en && vld_reg1) begin
//                if (cnt_report[13:0] >= 0 & cnt_report[13:0] <= MAX_TEST_ID) begin
                    if (cnt_report[14]) begin
                        if (quota_total[cnt_report[13:0]] < pkt_len) begin
                           quota_total[cnt_report[13:0]] <= 0;
                           exceed_quo_total <= 1'd1;
                        end else begin
                            quota_total[cnt_report[13:0]] <= quota_total[cnt_report[13:0]] - pkt_len;
                            exceed_quo_total <= 1'd0;
                        end
                    end else begin
                        exceed_quo_total <= 1'd0;
                    end
                    if (cnt_report[15] && ul) begin
                        if (quota_uplink[cnt_report[13:0]] < pkt_len) begin
                           quota_uplink[cnt_report[13:0]] <= 48'd0;
                           exceed_quo_uplink <= 1'd1;
                        end else begin
                           quota_uplink[cnt_report[13:0]] <= quota_uplink[cnt_report[13:0]] - pkt_len;
                           exceed_quo_uplink <= 1'd0;
                        end
                    end else begin
                       exceed_quo_uplink <= 1'd0;
                    end
                    if (cnt_report[16] && !ul) begin
                        if (quota_downlink[cnt_report[13:0]] < pkt_len) begin
                           quota_downlink[cnt_report[13:0]] <= 48'd0;
                           exceed_quo_downlink <= 1'd1;
                        end else begin
                            quota_downlink[cnt_report[13:0]] <= quota_downlink[cnt_report[13:0]] - pkt_len;
                            exceed_quo_downlink <= 1'd0;
                        end
                    end else begin
                        exceed_quo_downlink <= 1'd0;
                    end
        
        
                    //thress
                    if (cnt_report[17]) begin
                        if (thres_total[cnt_report[13:0]] < pkt_len) begin
                           thres_total[cnt_report[13:0]]  <= 48'd0;
                           exceed_thres_total <= 1'd1;
                        end else begin
                            thres_total[cnt_report[13:0]] <= thres_total[cnt_report[13:0]] - pkt_len;  
                            exceed_thres_total <= 1'd0;
                        end
                    end else begin
                        exceed_thres_total <= 1'd0;
                    end
                    if (cnt_report[18] && ul) begin
                        if (thres_uplink[cnt_report[13:0]] < pkt_len) begin
                            thres_uplink[cnt_report[13:0]] <= 48'd0;
                            exceed_thres_uplink <= 1'd1;
                        end else begin
                           thres_uplink[cnt_report[13:0]] <= thres_uplink[cnt_report[13:0]] - pkt_len;
                           exceed_thres_uplink <= 1'd0;
                        end
                    end else begin
                        exceed_thres_uplink <= 1'd0;
                    end
                    //
                    if (cnt_report[19] && !ul) begin
                        if (thres_downlink[cnt_report[13:0]] < pkt_len) begin
                            thres_downlink[cnt_report[13:0]] <= 48'd0;
                            exceed_thres_downlink <= 1'd1;
                        end else begin 
                            thres_downlink[cnt_report[13:0]] <= thres_downlink[cnt_report[13:0]] - pkt_len;
                            exceed_thres_downlink <= 1'd0;
                        end
                    end else begin
                        exceed_thres_downlink <= 1'd0;
                    end
//                end
            end else if (!pkt_en && vld_reg1)  begin
                policy_reg1 <= 3'd4;
            end
            
            //
            
            //
            
            //
            
        end 
    end
    //
    reg [7:0] lfsr; // 8-bit LFSR
    wire feedback = lfsr[6] ^ lfsr[4]; // taps cho 8-bit
    
    always @(posedge asclk or negedge aresetn) begin
        if (!aresetn) begin
            lfsr   <= 8'hA5;  // SEED không ???c all 0
            out_rdy <= 1'b0;
        end else if (init_done) begin
            lfsr   <= {lfsr[6:0], feedback}; // Shift trái + feedback
            out_rdy <= lfsr[0]; // L?y bit 0 làm tín hi?u in_vld
        end
    end
    
    
    //
    always @(posedge asclk or negedge aresetn) begin
        if (!aresetn) begin
            for (j = 0; j < LATENCY; j = j + 1)
                policy_pipeline[j] <= 3'd0;
        end else begin
            // shift pipeline
            policy_pipeline[0] <= cnt_policy;
            for (j = 1; j < LATENCY; j = j + 1) begin
                policy_pipeline[j] <= policy_pipeline[j-1];
            end
        end    
    end
    assign delayed_policy = policy_pipeline[LATENCY-1];
    
    


    //
    always @(posedge asclk or negedge aresetn) begin
        if (!aresetn) begin
            pkt_id <= 0;
            pkt_len <= 0;
            cnt_policy <= 0;
            ul <= 0;
            cnt_id <= 0;
            //
            drop_counting <= 0;
            drop_capacity <= 0;
            sendtohost_counting <= 0;
            sendtohost_capacity <= 0;
            forward_counting <= 0;
            forward_capacity <= 0;
        end else if (init_done) begin
            if (out_vld && out_rdy) begin
                pkt_id <= out_pkt_id[15:0];
                pkt_len <= out_pkt_len;
                cnt_policy <= out_cnt_policy;
                ul <= out_ul;
    //            pkt_en <= out_pkt_id[16];
                cnt_id <= out_cnt_report[13:0];
                //
                if (out_cnt_policy == 1) begin
                    drop_counting <= drop_counting + 1;
                    drop_capacity <= drop_capacity + out_pkt_len;
                end else if (out_cnt_policy == 2) begin
                    sendtohost_counting <= sendtohost_counting + 1;
                    sendtohost_capacity <= sendtohost_capacity + out_pkt_len;
                end else if (out_cnt_policy == 4) begin
                    forward_counting <= forward_counting + 1;
                    forward_capacity <= forward_capacity + out_pkt_len;
                end
                
               
            end
        end
    end
    //
    always @(posedge asclk or negedge aresetn) begin
        if (!aresetn) begin
            //
            policy_reg2 <= 3'd0;
            policy_quo <= 0;
            policy_thres <= 0;
        end else if (init_done) begin
            if (pkt_en1) begin
                if (cnt_report1[13:0] >= 0 && cnt_report1[13:0] <= MAX_TEST_ID) begin
                    if (exceed_quo_total || exceed_quo_uplink || exceed_quo_downlink) begin
                        if (quota_flag[cnt_report1[13:0]][3]) begin
                            policy_quo <= 3'd2;
                        end else begin
                            policy_quo <= 3'd1;
                        end
                    end
                    else begin
                        policy_quo <= 3'd4;
                    end
        
                    if (exceed_thres_total || exceed_thres_uplink || exceed_thres_downlink) begin
                        if (thres_flag[cnt_report1[13:0]][3]) begin
                            policy_thres <= 3'd2;
                        end else begin
                            policy_thres <= 3'd1;
                        end
                    end
                    else begin
                        policy_thres <= 3'd4;
                    end
                end
            end else if (!pkt_en1 && vld_reg2)  begin
                    policy_reg2 <= policy_reg1;
            end
        end
    end
    
    //
    always @(posedge asclk or negedge aresetn) begin
        if (!aresetn) begin
            policy <= 0;
        end else if (init_done) begin
            if (pkt_en2 & vld_reg3) begin
                if (cnt_report2[13:0] >= 0 && cnt_report2[13:0] <= MAX_TEST_ID) begin
                    if (policy_quo <= policy_thres) begin
                        policy <= policy_quo;
                    end else begin
                        policy <= policy_thres;    
                    end
                end
            end else if (!pkt_en2 && vld_reg3)  begin
                policy <= policy_reg2;
            end
        end
    end
    //policy
            
            
    
    //
    always @(posedge asclk) begin
        if (!aresetn) begin
            check_policy <= 0;
            check_false_policy <= 0;
        end else if (init_done) begin
            if (vld_reg4) begin
                if (cnt_report3[13:0] >= 0 && cnt_report3[13:0] <= MAX_TEST_ID) begin
                    if (policy == delayed_policy) begin
                        check_policy <= 1;
                    end else begin
                        check_policy <= 0;
                        check_false_policy <= 1;
                    end
                end
            end
        end
    end
   
//  
    reg [28:0] timestamp;  // ?? ?? ??m 300M
    reg [28:0] pkt_per_sec;
    reg [28:0] pkt_per_sec_max;
    
    always @(posedge asclk or negedge aresetn) begin
        if (!aresetn) begin
            timestamp <= 0;
            pkt_per_sec <= 0;
            pkt_per_sec_max <= 0;
        end else if (init_done) begin
            timestamp <= timestamp + 1;
            if (out_vld & out_rdy)
                pkt_per_sec <= pkt_per_sec + 1;
            if (timestamp == 100_000_000) begin
                $display("Packets per second: %d", pkt_per_sec);
                pkt_per_sec_max <= pkt_per_sec;
                timestamp <= 0;
            end
        end
    end
endmodule
