//module charging (
//    input asclk,
//    input aresetn,
//    input [23:0] timer,

//    input [13:0] r_cnt_id, 
//    input r_cnt_vld,
//    output reg r_cnt_rdy, 
//    output reg r_cnt_data_vld, 
//    output [511:0] r_cnt_data,
//    input [13:0] w_cnt_id, 
//    input w_cnt_vld, 
//    input [511:0] w_cnt_data,
//    output reg w_cnt_rdy,

//    input in_vld,
//    input [15:0] in_pkt_len,
//    input [95:0] in_pkt_id,
//    input [13:0] in_cnt_id,
//    input in_cnt_en,
//    input in_ul,
//    output in_rdy,

//    output out_vld,
//    output [15:0] out_pkt_len,
//    output [95:0] out_pkt_id,
//    output [2:0] out_cnt_policy,
//    output out_ul,
//    input out_rdy,
//    output [21:0] out_cnt_report,
//    output out_cnt_en //sua
//);
//    wire [511:0] load;
//    wire [13:0] cnt_id_to_bram;
//    wire [511:0] update;
//    wire web;
    
//    reg r_vld, r_vld_reg1;
//    reg [13:0] id_config;
//    reg [511:0] data_config;
//    reg wea;
//    //
//    wire wr_en1;
//    wire rd_en1;
//    wire full1, empty1;
//    wire [127:0] din1;
//    wire [127:0] dout1;
//    wire valid1;

//    wire wr_en;
//    wire rd_en;
//    wire full, empty;
//    wire [138:0] din;//sua
//    wire [138:0] dout;//sua
//    wire prog_full;
//    wire valid;

    

//    blk_mem_gen_0 counter_table (
//      .clka(asclk),    // input wire clka
//      .wea(wea),      // input wire [0 : 0] wea
//      .addra(id_config),  // input wire [13 : 0] addra
//      .dina(data_config),    // input wire [511 : 0] dina
//      .douta(r_cnt_data),  // output wire [511 : 0] douta
      
//      .clkb(asclk),    // input wire clkb
//      .web(web),      // input wire [0 : 0] web
//      .addrb(cnt_id_to_bram),  // input wire [13 : 0] addrb
//      .dinb(update),    // input wire [511 : 0] dinb
//      .doutb(load)  // output wire [511 : 0] doutb
//    );
//    fifo_input input_buffer (
//      .clk(asclk),        
//      .srst(~aresetn),      
//      .din(din1),      
//      .wr_en(wr_en1),    
//      .rd_en(rd_en1),    
//      .dout(dout1),     
//      .full(full1),   
//      .empty(empty1),  
//      .valid(valid1)  
//    );
//    fifo_output output_buffer (
//      .clk(asclk),              
//      .srst(~aresetn),            
//      .din(din),              
//      .wr_en(wr_en),       
//      .rd_en(rd_en),         
//      .dout(dout),         
//      .full(full),          
//      .empty(empty),         
//      .valid(valid),         
//      .prog_full(prog_full)  
//    );
//    counter_logic counter_logic(
//      .asclk(asclk),              
//      .aresetn(aresetn),
//      .timer(timer),
      
//      .load(load),
//      .cnt_id_to_bram(cnt_id_to_bram),
//      .update(update),
//      .web(web),
//        //
//      .dout1(dout1),
//      .rd_en1(rd_en1),
//      .valid1(valid1),
        
//      .prog_full(prog_full),
//      .din(din),
//      .wr_en(wr_en)
//    );

//    always @(posedge asclk) begin
//        if (!aresetn) begin
//            id_config <= 1'b0;
//            wea <= 1'b0;
//            //
//            r_vld <= 1'b0;         
//            r_vld_reg1 <= 1'b0;     
//            r_cnt_data_vld <= 1'b0; 
//        end else begin
//            r_cnt_rdy <= 1'b1;
//            w_cnt_rdy <= 1'b1;
//            if (w_cnt_vld && w_cnt_rdy) begin
//                wea <= 1'b1;
//                id_config <= w_cnt_id;
//                data_config <= w_cnt_data;
//                r_vld <= 0;
//            end else if (r_cnt_vld && r_cnt_rdy) begin
//                r_vld <= 1;
//                wea <= 1'b0;
//                id_config <= r_cnt_id;
//                data_config  <= 32'd0;
//            end else begin
//                wea <= 1'b0;
//                r_vld <= 0;
//            end
//            r_vld_reg1 <= r_vld;
//            r_cnt_data_vld <= r_vld_reg1;
//        end
//    end
    
//    //
//    assign in_rdy = ~full1;
//    assign wr_en1 = in_vld & in_rdy;
//    assign din1 = {in_ul, in_cnt_en, in_cnt_id, in_pkt_id, in_pkt_len};
    
//    //
//    assign out_vld = valid;
//    assign rd_en = out_rdy & valid;
//    assign {out_cnt_en, out_cnt_report, out_ul, out_cnt_policy, out_pkt_id, out_pkt_len} = dout;//sua
//endmodule
//======================================================================
module charging (
    input asclk,
    input aresetn,
    input [23:0] timer,

    input [13:0] r_cnt_id, 
    input r_cnt_vld,
    output reg r_cnt_rdy, 
    output reg r_cnt_data_vld, 
    output [511:0] r_cnt_data,
    input [13:0] w_cnt_id, 
    input w_cnt_vld, 
    input [511:0] w_cnt_data,
    output reg w_cnt_rdy,

    input in_vld,
    input [15:0] in_pkt_len,
    input [95:0] in_pkt_id,
    input [13:0] in_cnt_id,
    input in_cnt_en,
    input in_ul,
    output in_rdy,

    output out_vld,
    output [15:0] out_pkt_len,
    output [95:0] out_pkt_id,
    output [2:0] out_cnt_policy,
    output out_ul,
    input out_rdy,
    output [21:0] out_cnt_report,
    output out_cnt_en //sua
);
    wire [511:0] load;
    wire [13:0] cnt_id;
    wire [511:0] update;
    wire web;
    
    reg r_vld, r_vld_reg1;
    reg [13:0] id_config;
    reg [511:0] data_config;
    reg wea;
    //
    wire wr_en_ib;
    wire rd_en_ib;
    wire full_ib, empty_ib;
    wire [127:0] din_ib;
    wire [127:0] dout_ib;
    wire valid_ib;

    wire wr_en_ob;
    wire rd_en_ob;
    wire full_ob, empty_ob;
    wire [138:0] din_ob;//sua
    wire [138:0] dout_ob;//sua
    wire prog_full_ob;
    wire valid_ob;

    

    blk_mem_gen_0 counter_table (
      .clka(asclk),    // input wire clka
      .wea(wea),      // input wire [0 : 0] wea
      .addra(id_config),  // input wire [13 : 0] addra
      .dina(data_config),    // input wire [511 : 0] dina
      .douta(r_cnt_data),  // output wire [511 : 0] douta
      
      .clkb(asclk),    // input wire clkb
      .web(web),      // input wire [0 : 0] web
      .addrb(cnt_id),  // input wire [13 : 0] addrb
      .dinb(update),    // input wire [511 : 0] dinb
      .doutb(load)  // output wire [511 : 0] doutb
    );
    fifo_input input_buffer (
      .clk(asclk),        
      .srst(~aresetn),      
      .din(din_ib),      
      .wr_en(wr_en_ib),    
      .rd_en(rd_en_ib),    
      .dout(dout_ib),     
      .full(full_ib),   
      .empty(empty_ib),  
      .valid(valid_ib)  
    );
    fifo_output output_buffer (
      .clk(asclk),              
      .srst(~aresetn),            
      .din(din_ob),              
      .wr_en(wr_en_ob),       
      .rd_en(rd_en_ob),         
      .dout(dout_ob),         
      .full(full_ob),          
      .empty(empty_ob),         
      .valid(valid_ob),         
      .prog_full(prog_full_ob)  
    );
    counter_logic counter_logic(
      .asclk(asclk),              
      .aresetn(aresetn),
      .timer(timer),
      
      .load(load),
      .cnt_id(cnt_id),
      .update(update),
      .web(web),
        //
      .dout_ib(dout_ib),
      .rd_en_ib(rd_en_ib),
      .valid_ib(valid_ib),
        
      .prog_full_ob(prog_full_ob),
      .din_ob(din_ob),
      .wr_en_ob(wr_en_ob)
    );

    always @(posedge asclk) begin
        if (!aresetn) begin
            id_config <= 1'b0;
            wea <= 1'b0;
            //
            r_vld <= 1'b0;         
            r_vld_reg1 <= 1'b0;     
            r_cnt_data_vld <= 1'b0; 
        end else begin
            r_cnt_rdy <= 1'b1;
            w_cnt_rdy <= 1'b1;
            if (w_cnt_vld && w_cnt_rdy) begin
                wea <= 1'b1;
                id_config <= w_cnt_id;
                data_config <= w_cnt_data;
                r_vld <= 0;
            end else if (r_cnt_vld && r_cnt_rdy) begin
                r_vld <= 1;
                wea <= 1'b0;
                id_config <= r_cnt_id;
                data_config  <= 32'd0;
            end else begin
                wea <= 1'b0;
                r_vld <= 0;
            end
            r_vld_reg1 <= r_vld;
            r_cnt_data_vld <= r_vld_reg1;
        end
    end
    
    //
    assign in_rdy = ~full_ib;
    assign wr_en_ib = in_vld & in_rdy;
    assign din_ib = {in_ul, in_cnt_en, in_cnt_id, in_pkt_id, in_pkt_len};
    
    //
    assign out_vld = valid_ob;
    assign rd_en_ob = out_rdy & out_vld;
    assign {out_cnt_en, out_cnt_report, out_ul, out_cnt_policy, out_pkt_id, out_pkt_len} = dout_ob;//sua
endmodule
