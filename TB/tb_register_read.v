`timescale 1ns/1ps

module tb_register_read;

  localparam REG_ADDR_W = 12;
  localparam NUMBER_REG = 10;
  localparam REG_PREFIX = 0;

  reg         clk, rstn;
  reg         s_axil_awvalid;
  reg  [31:0] s_axil_awaddr;
  wire        s_axil_awready;

  reg         s_axil_wvalid;
  reg  [31:0] s_axil_wdata;
  wire        s_axil_wready;

  wire        s_axil_bvalid;
  wire  [1:0] s_axil_bresp;
  reg         s_axil_bready;

  reg         s_axil_arvalid;
  reg  [31:0] s_axil_araddr;
  wire        s_axil_arready;

  wire        s_axil_rvalid;
  wire [31:0] s_axil_rdata;
  wire  [1:0] s_axil_rresp;
  reg         s_axil_rready;

  reg  [32*NUMBER_REG-1:0] statstics;
  wire [32*NUMBER_REG-1:0] host_data;

  // Instantiate DUT
  register_read #(
    .REG_ADDR_W(REG_ADDR_W),
    .NUMBER_REG(NUMBER_REG),
    .REG_PREFIX(REG_PREFIX)
  ) dut (
    .s_axil_awvalid(s_axil_awvalid),
    .s_axil_awaddr(s_axil_awaddr),
    .s_axil_awready(s_axil_awready),
    .s_axil_wvalid(s_axil_wvalid),
    .s_axil_wdata(s_axil_wdata),
    .s_axil_wready(s_axil_wready),
    .s_axil_bvalid(s_axil_bvalid),
    .s_axil_bresp(s_axil_bresp),
    .s_axil_bready(s_axil_bready),
    .s_axil_arvalid(s_axil_arvalid),
    .s_axil_araddr(s_axil_araddr),
    .s_axil_arready(s_axil_arready),
    .s_axil_rvalid(s_axil_rvalid),
    .s_axil_rdata(s_axil_rdata),
    .s_axil_rresp(s_axil_rresp),
    .s_axil_rready(s_axil_rready),
    .aclk(clk),
    .aresetn(rstn),
    .statstics(statstics),
    .host_data(host_data)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // AXI-Lite helper task
  task axi_write(input [31:0] addr, input [31:0] data);
    begin
      @(posedge clk);
      s_axil_awvalid <= 1;
      s_axil_awaddr  <= addr;
      s_axil_wvalid  <= 1;
      s_axil_wdata   <= data;

      // Wait for write handshake
      wait (s_axil_awready && s_axil_wready);
      @(posedge clk);
      s_axil_awvalid <= 0;
      s_axil_wvalid  <= 0;

      // Wait for B channel
      s_axil_bready <= 1;
      wait (s_axil_bvalid);
      @(posedge clk);
      s_axil_bready <= 0;
    end
  endtask

  task axi_read(input [31:0] addr, output [31:0] data);
    begin
      @(posedge clk);
      s_axil_arvalid <= 1;
      s_axil_araddr  <= addr;

      wait (s_axil_arready);
      @(posedge clk);
      s_axil_arvalid <= 0;

      s_axil_rready <= 1;
      wait (s_axil_rvalid);
      data = s_axil_rdata;
      @(posedge clk);
      s_axil_rready <= 0;
    end
  endtask

  integer i;
  reg [31:0] tmp_data;

  initial begin
    // Init
    s_axil_awvalid = 0;
    s_axil_wvalid  = 0;
    s_axil_bready  = 0;
    s_axil_arvalid = 0;
    s_axil_rready  = 0;
    s_axil_awaddr  = 0;
    s_axil_wdata   = 0;
    s_axil_araddr  = 0;
    statstics      = 0;

    rstn = 0;
    repeat (3) @(posedge clk);
    rstn = 1;
    @(posedge clk);

    // Set statistics data
    for (i = 0; i < NUMBER_REG; i = i + 1) begin
      statstics[i*32 +: 32] = i + 1000;
    end

    // Ghi vào host_data registers t?i ??a ch? 0x40, 0x44, ...
    for (i = 0; i < NUMBER_REG; i = i + 1) begin
      axi_write(32'h40 + i*4, i + 100);
    end

    // ??c l?i các host_data registers
    for (i = 0; i < NUMBER_REG; i = i + 1) begin
      axi_read(32'h40 + i*4, tmp_data);
      $display("Read host_data[%0d] = %0d", i, tmp_data);
    end

    // ??c các statstics registers
    for (i = 0; i < NUMBER_REG; i = i + 1) begin
      axi_read(32'h00 + i*4, tmp_data);
      $display("Read statstics[%0d] = %0d", i, tmp_data);
    end

    $display("Test done.");
    #20;
    $finish;
  end

endmodule
