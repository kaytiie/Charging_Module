`timescale 1ns/1ps
module register_read #(
  parameter REG_ADDR_W = 32,
  parameter BASE_ADDRESS = 32'h40000000,
  parameter NUMBER_REG_IN = 9,
  parameter NUMBER_REG_OUT = 10,
  parameter REG_PREFIX = 0
)(
  input         s_axil_awvalid,
  input  [31:0] s_axil_awaddr,
  output        s_axil_awready,
  
  input         s_axil_wvalid,
  input  [31:0] s_axil_wdata,
  output        s_axil_wready,
  
  output        s_axil_bvalid,
  output  [1:0] s_axil_bresp,
  input         s_axil_bready,
  
  input         s_axil_arvalid,
  input  [31:0] s_axil_araddr,
  output        s_axil_arready,
  
  output        s_axil_rvalid,
  output [31:0] s_axil_rdata,
  output  [1:0] s_axil_rresp,
  input         s_axil_rready,

  input         aclk,
  input         aresetn,
  
  input  [32*NUMBER_REG_OUT - 1:0] statistics,
  output [32*NUMBER_REG_IN  - 1:0] host_data0,
  output reg host_data_valid
);

  wire                  reg_en;
  wire                  reg_we;
  wire [REG_ADDR_W-1:0] reg_addr;
  wire           [31:0] reg_din;
  reg            [31:0] reg_dout;

  reg [31:0] regs [0:2*NUMBER_REG_IN-1];

  axi_lite_register #(
    .CLOCKING_MODE ("common_clock"),
    .ADDR_W        (REG_ADDR_W),
    .DATA_W        (32)
  ) axil_reg_inst (
    .s_axil_awvalid (s_axil_awvalid),
    .s_axil_awaddr  (s_axil_awaddr),
    .s_axil_awready (s_axil_awready),
    .s_axil_wvalid  (s_axil_wvalid),
    .s_axil_wdata   (s_axil_wdata),
    .s_axil_wready  (s_axil_wready),
    .s_axil_bvalid  (s_axil_bvalid),
    .s_axil_bresp   (s_axil_bresp),
    .s_axil_bready  (s_axil_bready),
    .s_axil_arvalid (s_axil_arvalid),
    .s_axil_araddr  (s_axil_araddr),
    .s_axil_arready (s_axil_arready),
    .s_axil_rvalid  (s_axil_rvalid),
    .s_axil_rdata   (s_axil_rdata),
    .s_axil_rresp   (s_axil_rresp),
    .s_axil_rready  (s_axil_rready),

    .reg_en         (reg_en),
    .reg_we         (reg_we),
    .reg_addr       (reg_addr),
    .reg_din        (reg_din),
    .reg_dout       (reg_dout),

    .axil_aclk      (aclk),
    .axil_aresetn   (aresetn),
    .reg_clk        (aclk),
    .reg_rstn       (aresetn)
  );

//  // Gán host_data t? regs
    genvar gi;
    generate
      for (gi = 0; gi < NUMBER_REG_IN; gi = gi + 1) begin
        assign host_data0[gi*32 +: 32] = regs[gi];
      end
//      for (gi = 0; gi < NUMBER_REG_IN; gi = gi + 1) begin : gen_out1
//        assign host_data1[gi*32 +: 32] = regs[NUMBER_REG_IN + gi];
//      end
    endgenerate



  // Reset & ??c/ghi t? ??ng theo index
  integer i;
  reg host_data_valid_next;
  always @(posedge aclk) begin
    if (~aresetn) begin
      reg_dout <= 32'd0;
      host_data_valid <= 1'b0;
      host_data_valid_next <= 1'b0;
      for (i = 0; i < NUMBER_REG_IN; i = i + 1)
         regs[i] <= 32'd0;
    end else begin
        host_data_valid <= host_data_valid_next;
//        host_data_valid_next <= 1'b0;  // default: clear after 1 cycle
        if (reg_en) begin
          if (reg_we) begin
            case (reg_addr[11:0])
              12'h40: regs[0]  <= reg_din;
              12'h44: regs[1]  <= reg_din;
              12'h48: regs[2]  <= reg_din;
              12'h4C: regs[3]  <= reg_din;
              12'h50: regs[4]  <= reg_din;
              12'h54: regs[5]  <= reg_din;
              12'h58: regs[6]  <= reg_din;
              12'h5C: regs[7]  <= reg_din;
              12'h60: begin
                regs[8]  <= reg_din;
                host_data_valid_next <= 1'b1;  // assert next cycle
              end
    //          12'h64: regs[9]  <= reg_din;
    //          12'h68: regs[10] <= reg_din;
    //          12'h6C: regs[11] <= reg_din;
    //          12'h70: regs[12] <= reg_din;
    //          12'h74: regs[13] <= reg_din;
    //          12'h78: regs[14] <= reg_din;
    //          12'h7C: regs[15] <= reg_din;
    //          12'h80: regs[16] <= reg_din;
              //=============
    //          12'h84: regs[17] <= reg_din;
    //          12'h88: regs[18] <= reg_din;
    //          12'h8C: regs[19] <= reg_din;
    //          12'h90: regs[20] <= reg_din;
    //          12'h94: regs[21] <= reg_din;
    //          12'h98: regs[22] <= reg_din;
    //          12'h9C: regs[23] <= reg_din;
    //          12'hA0: regs[24] <= reg_din;
    //          12'hA4: regs[25] <= reg_din;
    //          12'hA8: regs[26] <= reg_din;
    //          12'hAC: regs[27] <= reg_din;
    //          12'hB0: regs[28] <= reg_din;
    //          12'hB4: regs[29] <= reg_din;
    //          12'hB8: regs[30] <= reg_din;
    //          12'hBC: regs[31] <= reg_din;
    //          12'hC0: regs[32] <= reg_din;
    //          12'hC4: regs[33] <= reg_din;
            endcase
          end else begin
            case (reg_addr[11:0])
              12'h00: reg_dout <= statistics[32*0 +: 32];
              12'h04: reg_dout <= statistics[32*1 +: 32];
              12'h08: reg_dout <= statistics[32*2 +: 32];
              12'h0C: reg_dout <= statistics[32*3 +: 32];
              12'h10: reg_dout <= statistics[32*4 +: 32];
              12'h14: reg_dout <= statistics[32*5 +: 32];
              12'h18: reg_dout <= statistics[32*6 +: 32];
              12'h1C: reg_dout <= statistics[32*7 +: 32];
              12'h20: reg_dout <= statistics[32*8 +: 32];
              12'h24: reg_dout <= statistics[32*9 +: 32];
              default: reg_dout <= 32'd0;
            endcase
          end
        end
    end
end


endmodule
