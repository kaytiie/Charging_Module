
//==============================================
module counter_logic(
    input asclk,
    input aresetn,
    input [23:0] timer,
    //
    input [511:0] load,
    output reg [13:0] cnt_id,
    output reg [511:0] update,
    output reg web,
    //
    input [127:0] dout_ib,
    output rd_en_ib,
    input valid_ib,
    
    input prog_full_ob,
    output reg [138:0] din_ob,
    output reg wr_en_ob
    );

    reg vol_quo_total_en;
    reg vol_quo_uplink_en;
    reg vol_quo_downlink_en;
    reg vol_quo_sendtohost_en;
    reg exceed_quo_total;
    reg exceed_quo_uplink;
    reg exceed_quo_downlink;
    reg [47:0] vol_quo_total; 
    reg [47:0] vol_quo_uplink;
    reg [47:0] vol_quo_downlink;
    reg vol_thres_total_en;
    reg vol_thres_uplink_en;
    reg vol_thres_downlink_en;
    reg vol_thres_sendtohost_en;
    reg exceed_thres_total;
    reg exceed_thres_uplink;
    reg exceed_thres_downlink;
    reg [47:0] vol_thres_total;
    reg [47:0] vol_thres_uplink;
    reg [47:0] vol_thres_downlink;
    reg [47:0] record_uplink_pkt;
    reg [47:0] record_downlink_pkt;
    reg [47:0] offload_last_time;

    reg vld, vld_reg1, vld_reg2, vld_reg3, vld_reg4, vld_reg5, vld_reg6;
    reg [15:0] pkt_len, pkt_len_reg1, pkt_len_reg2, pkt_len_reg3, pkt_len_reg4, pkt_len_reg5, pkt_len_reg6;
    reg [95:0] pkt_id, pkt_id_reg1, pkt_id_reg2, pkt_id_reg3, pkt_id_reg4, pkt_id_reg5, pkt_id_reg6;
    reg [13:0] cnt_id_reg1, cnt_id_reg2, cnt_id_reg3, cnt_id_reg4, cnt_id_reg5;
    reg cnt_en, cnt_en_reg1, cnt_en_reg2, cnt_en_reg3, cnt_en_reg4, cnt_en_reg5, cnt_en_reg6;
    reg ul, ul_reg1, ul_reg2, ul_reg3, ul_reg4, ul_reg5, ul_reg6;

    reg [21:0] cnt_report;
    reg [3:0] policy_quo, policy_thres;
    
    //
    wire id_conflict; 
    reg clk2_count;

    reg state;
    localparam READ = 1'b0,
               WRITE = 1'b1;

assign id_conflict = //(dout_ib[125:112] == cnt_id && dout_ib[126] && cnt_en && valid_ib && vld)||
            (dout_ib[125:112] == cnt_id_reg1 && dout_ib[126] && cnt_en_reg1 && valid_ib && vld_reg1)||
//            (dout_ib[125:112] == cnt_id_reg2 && dout_ib[126] && cnt_en_reg2 && valid_ib && vld_reg2)||
            (dout_ib[125:112] == cnt_id_reg3 && dout_ib[126] && cnt_en_reg3 && valid_ib && vld_reg3);
//            (dout_ib[125:112] == cnt_id_reg4 && dout_ib[126] && cnt_en_reg4 && valid_ib && vld_reg4);
//            (dout_ib[125:112] == cnt_id_reg5 && dout_ib[126] && cnt_en_reg5 && valid_ib && vld_reg5);
assign rd_en_ib = valid_ib & !id_conflict & !prog_full_ob & clk2_count;

//
always @(posedge asclk) begin
    if (!aresetn) begin
        state <= READ;
        web <= 1'b0;
        
        cnt_id <= 14'd0;
        cnt_id_reg1 <= 14'd0;
        cnt_id_reg2 <= 14'd0;
        cnt_id_reg3 <= 14'd0;
        cnt_id_reg4 <= 14'd0;
        cnt_id_reg5 <= 14'd0;

        pkt_len <= 16'd0;
        pkt_len_reg1 <= 16'd0;
        pkt_len_reg2 <= 16'd0;
        pkt_len_reg3 <= 16'd0;
        pkt_len_reg4 <= 16'd0;
        pkt_len_reg5 <= 16'd0;
        pkt_len_reg6 <= 16'd0;
        
        pkt_id <= 96'd0;
        pkt_id_reg1 <= 96'd0;
        pkt_id_reg2 <= 96'd0;
        pkt_id_reg3 <= 96'd0;
        pkt_id_reg4 <= 96'd0;
        pkt_id_reg5 <= 96'd0;
        pkt_id_reg6 <= 96'd0;

        vld <= 1'b0;
        vld_reg1 <= 1'b0;
        vld_reg2 <= 1'b0;
        vld_reg3 <= 1'b0;
        vld_reg4 <= 1'b0;
        vld_reg5 <= 1'b0;
        vld_reg6 <= 1'b0;

        cnt_en <= 1'b0;
        cnt_en_reg1 <= 1'b0;
        cnt_en_reg2 <= 1'b0;
        cnt_en_reg3 <= 1'b0;
        cnt_en_reg4 <= 1'b0;
        cnt_en_reg5 <= 1'b0;
        cnt_en_reg6 <= 1'b0;

        ul <= 1'd0;
        ul_reg1 <= 1'b0;
        ul_reg2 <= 1'b0;
        ul_reg3 <= 1'b0;
        ul_reg4 <= 1'b0;
        ul_reg5 <= 1'b0;
        ul_reg6 <= 1'b0;

        clk2_count <= 0;

        vol_quo_total_en <= 1'd0;
        vol_quo_uplink_en <= 1'd0;
        vol_quo_downlink_en <= 1'd0;
        vol_quo_sendtohost_en <= 1'd0;
        exceed_quo_total <= 1'd0;
        exceed_quo_uplink <= 1'd0;
        exceed_quo_downlink <= 1'd0;
        vol_quo_total <= 48'd0;
        vol_quo_uplink <= 48'd0;
        vol_quo_downlink <= 48'd0;
        vol_thres_total_en <= 1'd0;
        vol_thres_uplink_en <= 1'd0;
        vol_thres_downlink_en <= 1'd0;
        vol_thres_sendtohost_en <= 1'd0;
        exceed_thres_total <= 1'd0;
        exceed_thres_uplink <= 1'd0;
        exceed_thres_downlink <= 1'd0;
        vol_thres_total <= 48'd0;
        vol_thres_uplink <= 48'd0;
        vol_thres_downlink <= 48'd0;
        record_uplink_pkt <= 48'd0;
        record_downlink_pkt <= 48'd0;
    end else begin
        case (state)
            READ: begin
                if (cnt_en_reg4 && vld_reg4) begin
                    state <= WRITE;
                    cnt_id <= cnt_id_reg4;
                    web <= 1'b1;
                end 
            end
            WRITE: begin
                web <= 1'b0;
                state <= READ;
            end
            default: begin 
                web <= 1'b0;
                state <= READ;
            end
        endcase
        //
        clk2_count <= ~clk2_count;
        if (rd_en_ib) begin
           {ul, cnt_en, cnt_id, pkt_id, pkt_len} <= dout_ib;
           vld <= 1'd1;
        end else begin
            vld <= 1'd0;
        end
        cnt_id_reg1 <= cnt_id;
        cnt_id_reg2 <= cnt_id_reg1;
        cnt_id_reg3 <= cnt_id_reg2;
        cnt_id_reg4 <= cnt_id_reg3;
        cnt_id_reg5 <= cnt_id_reg4;

        pkt_len_reg1 <= pkt_len;
        pkt_len_reg2 <= pkt_len_reg1;
        pkt_len_reg3 <= pkt_len_reg2;
        pkt_len_reg4 <= pkt_len_reg3;
        pkt_len_reg5 <= pkt_len_reg4;
        pkt_len_reg6 <= pkt_len_reg5;

        pkt_id_reg1 <= pkt_id;
        pkt_id_reg2 <= pkt_id_reg1;
        pkt_id_reg3 <= pkt_id_reg2;
        pkt_id_reg4 <= pkt_id_reg3;
        pkt_id_reg5 <= pkt_id_reg4;
        pkt_id_reg6 <= pkt_id_reg5;

        vld_reg1 <= vld;
        vld_reg2 <= vld_reg1;
        vld_reg3 <= vld_reg2;
        vld_reg4 <= vld_reg3;
        vld_reg5 <= vld_reg4;
        vld_reg6 <= vld_reg5;

        cnt_en_reg1 <= cnt_en;
        cnt_en_reg2 <= cnt_en_reg1;
        cnt_en_reg3 <= cnt_en_reg2;
        cnt_en_reg4 <= cnt_en_reg3;
        cnt_en_reg5 <= cnt_en_reg4;
        cnt_en_reg6 <= cnt_en_reg5;
        
        ul_reg1 <= ul;
        ul_reg2 <= ul_reg1;
        ul_reg3 <= ul_reg2;
        ul_reg4 <= ul_reg3;
        ul_reg5 <= ul_reg4;
        ul_reg6 <= ul_reg5;

        if(cnt_en_reg2 && vld_reg2) begin
            vol_quo_total_en <= load[0];
            vol_quo_uplink_en <= load[1];
            vol_quo_downlink_en <= load[2];
            vol_quo_sendtohost_en <= load[3];
            vol_quo_total <= load[55:8];
            vol_quo_uplink <= load[103:56];
            vol_quo_downlink <= load[151:104];

            vol_thres_total_en <= load[152];
            vol_thres_uplink_en <= load[153];
            vol_thres_downlink_en <= load[154];
            vol_thres_sendtohost_en <= load[155];
            vol_thres_total <= load[207:160];
            vol_thres_uplink <= load[255:208];
            vol_thres_downlink <= load[303:256];

            record_uplink_pkt <= load[351:304];
            record_downlink_pkt <= load[399:352];
            offload_last_time <= load[511:464];
        end

        if (cnt_en_reg3 && vld_reg3) begin
            offload_last_time <= {{24{1'b0}}, timer};
            if (ul_reg3) begin
                record_uplink_pkt <= record_uplink_pkt + 48'd1;
            end else begin
                record_downlink_pkt <= record_downlink_pkt + 48'd1;
             end
             //
            if (vol_quo_total_en) begin
                if (vol_quo_total < pkt_len_reg3) begin
                   vol_quo_total <= 0;
                   exceed_quo_total <= 1'd1;
                end else begin
                    vol_quo_total <= vol_quo_total - pkt_len_reg3;
                    exceed_quo_total <= 1'd0;
                end
            end else begin
                exceed_quo_total <= 1'd0;
            end
            //
            if (vol_quo_uplink_en && ul_reg3) begin
                if (vol_quo_uplink < pkt_len_reg3) begin
                      vol_quo_uplink <= 48'd0;
                      exceed_quo_uplink <= 1'd1;
                end else begin
                       vol_quo_uplink <= vol_quo_uplink - pkt_len_reg3;
                       exceed_quo_uplink <= 1'd0;
               end
            end else begin
               exceed_quo_uplink <= 1'd0;
            end
            //
            if (vol_quo_downlink_en && !ul_reg3) begin
               if (vol_quo_downlink < pkt_len_reg3) begin
                   vol_quo_downlink <= 48'd0;
                   exceed_quo_downlink <= 1'd1;
               end else begin
                    vol_quo_downlink <= vol_quo_downlink - pkt_len_reg3;
                    exceed_quo_downlink <= 1'd0;
               end
           end else begin
                exceed_quo_downlink <= 1'd0;
           end
           //
           if (vol_thres_total_en) begin
              if (vol_thres_total < pkt_len_reg3) begin
                   vol_thres_total  <= 48'd0;
                   exceed_thres_total <= 1'd1;
              end else begin
                    vol_thres_total <= vol_thres_total - pkt_len_reg3;  
                    exceed_thres_total <= 1'd0;
              end
           end else begin
                exceed_thres_total <= 1'd0;
            end
            //
           if (vol_thres_uplink_en && ul_reg3) begin
                if (vol_thres_uplink < pkt_len_reg3) begin
                      vol_thres_uplink <= 48'd0;
                      exceed_thres_uplink <= 1'd1;
                end else begin
                   vol_thres_uplink <= vol_thres_uplink - pkt_len_reg3;
                   exceed_thres_uplink <= 1'd0;
                end
            end else begin
                exceed_thres_uplink <= 1'd0;
            end
            //
            if (vol_thres_downlink_en && !ul_reg3) begin
               if (vol_thres_downlink < pkt_len_reg3) begin
                   vol_thres_downlink <= 48'd0;
                   exceed_thres_downlink <= 1'd1;
               end else begin
                    vol_thres_downlink <= vol_thres_downlink - pkt_len_reg3;
                    exceed_thres_downlink <= 1'd0;
               end
           end else begin
                exceed_thres_downlink <= 1'd0;
            end
        end
    end
end

//
always @(posedge asclk) begin
    if (!aresetn) begin
        update <= 512'd0;
        cnt_report <= 22'd0;
        policy_quo <= 3'd0;     
        policy_thres <= 3'd0;
        din_ob <= 0;
    end
    else begin
        if(vld_reg4 && cnt_en_reg4) begin
             update[0]<=vol_quo_total_en;
             update[1]<=vol_quo_uplink_en;
             update[2]<=vol_quo_downlink_en;
             update[3]<=vol_quo_sendtohost_en;
             update[55:8] <= vol_quo_total;
             update[103:56] <= vol_quo_uplink;
             update[151:104] <= vol_quo_downlink;
             update[152]<=vol_thres_total_en;
             update[153]<=vol_thres_uplink_en;
             update[154]<=vol_thres_downlink_en;
             update[155]<=vol_thres_sendtohost_en;
             update[207:160] <= vol_thres_total;
             update[255:208] <= vol_thres_uplink;
             update[303:256] <= vol_thres_downlink;
             update[351:304] <= record_uplink_pkt;
             update[399:352] <= record_downlink_pkt;
             update[511:464] <= offload_last_time;
        end
        if(cnt_en_reg4) begin
            cnt_report [13:0] <= cnt_id_reg4;
            cnt_report [16:14] <= {vol_quo_downlink_en, vol_quo_uplink_en, vol_quo_total_en};
            cnt_report [19:17] <= {vol_thres_downlink_en, vol_thres_uplink_en, vol_thres_total_en};
        end else begin
            cnt_report [13:0] <= cnt_id_reg4;
            cnt_report [16:14] <= 3'd0;//sua
            cnt_report [19:17] <= 3'd0;//sua
        end
        if (exceed_quo_total||exceed_quo_uplink||exceed_quo_downlink) begin
            if (vol_quo_sendtohost_en) begin
                policy_quo <= 3'd2;
            end else begin
                policy_quo <= 3'd1;
            end
        end
        else begin
            policy_quo <= 3'd4;
        end
        if (exceed_thres_total||exceed_thres_uplink||exceed_thres_downlink) begin
            if (vol_thres_sendtohost_en) begin
                policy_thres <= 3'd2;
            end else begin
                policy_thres <= 3'd1;
            end
        end
        else begin
            policy_thres <= 3'd4;
        end
        if (cnt_en_reg5) begin 
            din_ob[114:112] <= (policy_quo <= policy_thres) ? policy_quo : policy_thres;
        end else begin
            din_ob[114:112] <= 3'd4;
        end
        din_ob[15:0] <= pkt_len_reg5;
        din_ob[111:16] <= pkt_id_reg5;
        din_ob[115] <= ul_reg5;
        din_ob[137:116] <= cnt_report;
        din_ob[138] <= cnt_en_reg5;
    end
end

//
always @(posedge asclk) begin
    if (!aresetn) begin 
        wr_en_ob <= 0;
    end
    else begin
        wr_en_ob <= vld_reg5;  
    end 
end
        
endmodule
