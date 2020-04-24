//===================================================================
//
// Copyright (C) Wavious 2019 - All Rights Reserved
//
// Unauthorized copying of this file, via any medium is strictly prohibited
//
// Created by sbridges on November/08/2019 at 08:10:35
//
// rfifo_example_regs_top.v
//
//===================================================================



module rfifo_example_regs_top #(
  parameter    ADDR_WIDTH = 8,
  parameter    STDCELL    = 1
)(
  //REG1
  input  wire [4:0]   bf1,
  output wire [4:0]   swi_bf1_muxed,
  //REG_WITH_RFIFO
  input  wire [7:0]   rfifo_read_data,
  output wire         rfifo_rinc_read_data,

  //DFT Ports (if used)
  
  // APB Interface
  input  wire RegReset,
  input  wire RegClk,
  input  wire PSEL,
  input  wire PENABLE,
  input  wire PWRITE,
  output wire PSLVERR,
  output wire PREADY,
  input  wire [(ADDR_WIDTH-1):0] PADDR,
  input  wire [31:0] PWDATA,
  output wire [31:0] PRDATA
);
  
  //DFT Tieoffs (if not used)
  wire dft_core_scan_mode = 1'b0;
  wire dft_iddq_mode = 1'b0;
  wire dft_hiz_mode = 1'b0;
  wire dft_bscan_mode = 1'b0;

  //APB Setup/Access 
  wire [(ADDR_WIDTH-1):0] RegAddr_in;
  reg  [(ADDR_WIDTH-1):0] RegAddr;
  wire [31:0] RegWrData_in;
  reg  [31:0] RegWrData;
  wire RegWrEn_in;
  reg  RegWrEn_pq;
  wire RegWrEn;

  assign RegAddr_in = PSEL ? PADDR : RegAddr; 

  always @(posedge RegClk or posedge RegReset) begin
    if (RegReset) begin
      RegAddr <= {(ADDR_WIDTH){1'b0}};
    end else begin
      RegAddr <= RegAddr_in;
    end
  end

  assign RegWrData_in = PSEL ? PWDATA : RegWrData; 

  always @(posedge RegClk or posedge RegReset) begin
    if (RegReset) begin
      RegWrData <= 32'h00000000;
    end else begin
      RegWrData <= RegWrData_in;
    end
  end

  assign RegWrEn_in = PSEL & PWRITE;

  always @(posedge RegClk or posedge RegReset) begin
    if (RegReset) begin
      RegWrEn_pq <= 1'b0;
    end else begin
      RegWrEn_pq <= RegWrEn_in;
    end
  end

  assign RegWrEn = RegWrEn_pq & PENABLE;
  
  //assign PSLVERR = 1'b0;
  assign PREADY  = 1'b1;
  


  //Regs for Mux Override sel
  reg  reg_bf1_mux;



  //---------------------------
  // REG1
  // bf1 - My read-write bitfield
  // bf1_mux - Mux register select
  //---------------------------
  wire [31:0] REG1_reg_read;
  reg  [4:0]   reg_bf1;

  always @(posedge RegClk or posedge RegReset) begin
    if(RegReset) begin
      reg_bf1                                <= 5'h0;
      reg_bf1_mux                            <= 1'h0;
    end else if(RegAddr == 'h0 && RegWrEn) begin
      reg_bf1                                <= RegWrData[4:0];
      reg_bf1_mux                            <= RegWrData[5];
    end else begin
      reg_bf1                                <= reg_bf1;
      reg_bf1_mux                            <= reg_bf1_mux;
    end
  end

  assign REG1_reg_read = {26'h0,
          reg_bf1_mux,
          reg_bf1};

  //-----------------------

  wire [4:0]  swi_bf1_muxed_pre;
  wav_clock_mux #(.STDCELL(STDCELL)) u_wav_clock_mux_bf1[4:0] (
    .clk0    ( bf1                                ),              
    .clk1    ( reg_bf1                            ),              
    .sel     ( reg_bf1_mux                        ),      
    .clk_out ( swi_bf1_muxed_pre                  )); 

  assign swi_bf1_muxed = swi_bf1_muxed_pre;

  //-----------------------




  //---------------------------
  // REG_WITH_RFIFO
  // read_data - Reads from the FIFO
  //---------------------------
  wire [31:0] REG_WITH_RFIFO_reg_read;

  assign rfifo_rinc_read_data = (RegAddr == 'h4 && PENABLE && PSEL && ~(PWRITE || RegWrEn));
  assign REG_WITH_RFIFO_reg_read = {24'h0,
          rfifo_read_data};

  //-----------------------




  //---------------------------
  // DEBUG_BUS_CTRL
  // DEBUG_BUS_CTRL_SEL - Select signal for DEBUG_BUS_CTRL
  //---------------------------
  wire [31:0] DEBUG_BUS_CTRL_reg_read;
  reg         reg_debug_bus_ctrl_sel;

  always @(posedge RegClk or posedge RegReset) begin
    if(RegReset) begin
      reg_debug_bus_ctrl_sel                 <= 1'h0;
    end else if(RegAddr == 'h8 && RegWrEn) begin
      reg_debug_bus_ctrl_sel                 <= RegWrData[0];
    end else begin
      reg_debug_bus_ctrl_sel                 <= reg_debug_bus_ctrl_sel;
    end
  end

  assign DEBUG_BUS_CTRL_reg_read = {31'h0,
          reg_debug_bus_ctrl_sel};

  //-----------------------
  assign swi_debug_bus_ctrl_sel = reg_debug_bus_ctrl_sel;





  //---------------------------
  // DEBUG_BUS_STATUS
  // DEBUG_BUS_CTRL_STATUS - Status output for DEBUG_BUS_STATUS
  //---------------------------
  wire [31:0] DEBUG_BUS_STATUS_reg_read;
  reg  [31:0]  debug_bus_ctrl_status;

  //Debug bus control logic  
  always @(*) begin
    case(swi_debug_bus_ctrl_sel)
      'd0 : debug_bus_ctrl_status = {27'd0, swi_bf1_muxed};
      default : debug_bus_ctrl_status = 32'd0;
    endcase
  end 
  
  assign DEBUG_BUS_STATUS_reg_read = {          debug_bus_ctrl_status};

  //-----------------------


  
    
  //---------------------------
  // PRDATA Selection
  //---------------------------
  reg [31:0] prdata_sel;
  
  always @(*) begin
    case(RegAddr)
      'h0    : prdata_sel = REG1_reg_read;
      'h4    : prdata_sel = REG_WITH_RFIFO_reg_read;
      'h8    : prdata_sel = DEBUG_BUS_CTRL_reg_read;
      'hc    : prdata_sel = DEBUG_BUS_STATUS_reg_read;

      default : prdata_sel = 32'd0;
    endcase
  end
  
  assign PRDATA = prdata_sel;


  
    
  //---------------------------
  // PSLVERR Detection
  //---------------------------
  reg pslverr_pre;
  
  always @(*) begin
    case(RegAddr)
      'h0    : pslverr_pre = 1'b0;
      'h4    : pslverr_pre = 1'b0;
      'h8    : pslverr_pre = 1'b0;
      'hc    : pslverr_pre = 1'b0;

      default : pslverr_pre = 1'b1;
    endcase
  end
  
  assign PSLVERR = pslverr_pre;

endmodule
