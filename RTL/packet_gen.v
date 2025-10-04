`timescale 1ns / 1ps

module packet_gen(
    input asclk,
    input aresetn,
    
    //
    input in_rdy,
    input stop_update,
    //
    output reg in_vld,
    output reg [95:0] in_pkt_id, 
    output reg [15:0] in_pkt_len, 
    output [13:0] in_cnt_id, 
    output reg in_cnt_en, 
    output reg in_ul,
    output reg [23:0] timer
    );
    reg [47:0] len_total;
    reg max_cnt_id;
    reg [15:0] max_pkt_id;
    assign in_cnt_id = max_cnt_id;
    
    always @(posedge asclk or negedge aresetn) begin
        if (!aresetn) begin
            timer <= 0;
        end else begin
            timer <= timer + 1;
        end
    end
    
    always @(posedge asclk or negedge aresetn) begin
           if(!aresetn) begin
               max_cnt_id <= 3;
           end
           else if (stop_update) begin 
               //
               max_cnt_id <= 3;
           end
     end
     
     //
    always @(posedge asclk or negedge aresetn) begin
           if(!aresetn) begin
               in_pkt_id <= 0;
           end else if (stop_update) begin
                if (in_vld && in_rdy) begin
                    in_pkt_id <= in_pkt_id + 1;
                end
           end
     end 
         
    //
    always @(posedge asclk or negedge aresetn) begin
        if(!aresetn) begin
           in_pkt_len <= 1_024;
           len_total <= 0;
        end
        else if (stop_update) begin
            if (in_vld && in_rdy) begin
                in_pkt_len <= 1_024;
                len_total <= len_total + in_pkt_len;
            end
       end
    end 

    // Ng?u nhiên 
    reg [7:0] lfsr; // 8-bit LFSR
    wire feedback = lfsr[7] ^ lfsr[5]; // taps cho 8-bit
    
    always @(posedge asclk or negedge aresetn) begin
        if (!aresetn) begin
            lfsr   <= 8'hA5;  // SEED không ???c all 0
            in_vld <= 1'b0;
            max_pkt_id <= 0;
        end else if (stop_update) begin
            lfsr   <= {lfsr[6:0], feedback}; // Shift trái + feedback
            in_vld <= lfsr[0]; // L?y bit 0 làm tín hi?u in_vld
            if (in_vld & in_rdy) begin 
                max_pkt_id <= max_pkt_id + 1;
            end
            if (max_pkt_id == 200) begin
                in_vld <= 0;
            end
        end
    end
    
    
    //
    reg [1:0] en_cnt;
    always @(posedge asclk or negedge aresetn) begin
        if (!aresetn) begin
            in_cnt_en  <= 1'b0;
        end else if (stop_update) begin
            in_cnt_en <= 1;
        end
    end
    
    //
    reg [2:0] ul_cnt;
    always @(posedge asclk or negedge aresetn) begin
        if (!aresetn) begin
            in_ul  <= 1'b0;
        end else if (stop_update) begin
            in_ul <= 1;
        end
    end
     
endmodule
