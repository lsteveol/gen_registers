//===================================================================
//
// Copyright (C) Wavious 2019 - All Rights Reserved
//
// Unauthorized copying of this file, via any medium is strictly prohibited
//
// Created by sbridges on November/08/2019 at 11:42:54
//
// dft_example_regs_top.v
//
//===================================================================



module dft_example_regs_top #(
  parameter    ADDR_WIDTH = 8,
  parameter    STDCELL    = 1
)(
  //REG1
  output wire [3:0]   swi_bf1,
  input  wire [4:0]   bf2,
  output wire [4:0]   swi_bf2_muxed,
  output wire         swi_bf3,
  output wire         swi_set_core_scan,
  //REG_WITH_BSCAN_FLOP
  output wire         swi_bscan_flop_drive,
  input  wire [2:0]   bscan_flop_capture,
  //LAST_BSCAN_FLOP
  output wire         swi_last_one_in_chain,

  //DFT Ports (if used)
  input  wire dft_core_scan_mode,
  input  wire dft_iddq_mode,
  input  wire dft_hiz_mode,
  input  wire dft_bscan_mode,
  // BSCAN Shift Interface
  input  wire dft_bscan_tck,
  input  wire dft_bscan_trstn,
  input  wire dft_bscan_capture,
  input  wire dft_bscan_shift,
  input  wire dft_bscan_update,
  input  wire dft_bscan_tdi,
  output wire dft_bscan_tdo,     //Assigned to last in chain
  
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
  reg  reg_bf2_mux;



  //---------------------------
  // REG1
  // bf1 - Global setting of 0 during DFT modes
  // bf2 - Put DFT on the non-mux. Only active in Hiz mode
  // bf2_mux - 
  // bf3 - Set to 0 in IDDQ, but 1 in all other modes
  // set_core_scan - Set to 1 in CORESCAN mode
  //---------------------------
  wire [31:0] REG1_reg_read;
  reg [3:0]   reg_bf1;
  reg  [4:0]   reg_bf2;
  reg         reg_bf3;
  reg         reg_set_core_scan;

  always @(posedge RegClk or posedge RegReset) begin
    if(RegReset) begin
      reg_bf1                                <= 4'h3;
      reg_bf2                                <= 5'h0;
      reg_bf2_mux                            <= 1'h0;
      reg_bf3                                <= 1'h1;
      reg_set_core_scan                      <= 1'h0;
    end else if(RegAddr == 'h0 && RegWrEn) begin
      reg_bf1                                <= RegWrData[3:0];
      reg_bf2                                <= RegWrData[8:4];
      reg_bf2_mux                            <= RegWrData[9];
      reg_bf3                                <= RegWrData[10];
      reg_set_core_scan                      <= RegWrData[11];
    end else begin
      reg_bf1                                <= reg_bf1;
      reg_bf2                                <= reg_bf2;
      reg_bf2_mux                            <= reg_bf2_mux;
      reg_bf3                                <= reg_bf3;
      reg_set_core_scan                      <= reg_set_core_scan;
    end
  end

  assign REG1_reg_read = {20'h0,
          reg_set_core_scan,
          reg_bf3,
          reg_bf2_mux,
          reg_bf2,
          reg_bf1};

  //-----------------------

  wire [3:0]  reg_bf1_core_scan_mode;
  wav_clock_mux #(.STDCELL(STDCELL)) u_wav_clock_mux_bf1_core_scan_mode[3:0] (
    .clk0    ( reg_bf1                            ),              
    .clk1    ( 4'd0                               ),              
    .sel     ( dft_core_scan_mode                 ),      
    .clk_out ( reg_bf1_core_scan_mode             )); 


  wire [3:0]  reg_bf1_iddq_mode;
  wav_clock_mux #(.STDCELL(STDCELL)) u_wav_clock_mux_bf1_iddq_mode[3:0] (
    .clk0    ( reg_bf1_core_scan_mode             ),              
    .clk1    ( 4'd0                               ),              
    .sel     ( dft_iddq_mode                      ),      
    .clk_out ( reg_bf1_iddq_mode                  )); 


  wire [3:0]  reg_bf1_hiz_mode;
  wav_clock_mux #(.STDCELL(STDCELL)) u_wav_clock_mux_bf1_hiz_mode[3:0] (
    .clk0    ( reg_bf1_iddq_mode                  ),              
    .clk1    ( 4'd0                               ),              
    .sel     ( dft_hiz_mode                       ),      
    .clk_out ( reg_bf1_hiz_mode                   )); 


  wire [3:0]  reg_bf1_bscan_mode;
  wav_clock_mux #(.STDCELL(STDCELL)) u_wav_clock_mux_bf1_bscan_mode[3:0] (
    .clk0    ( reg_bf1_hiz_mode                   ),              
    .clk1    ( 4'd0                               ),              
    .sel     ( dft_bscan_mode                     ),      
    .clk_out ( reg_bf1_bscan_mode                 )); 

  assign swi_bf1 = reg_bf1_bscan_mode;

  //-----------------------

  wire [4:0]  swi_bf2_muxed_pre;
  wav_clock_mux #(.STDCELL(STDCELL)) u_wav_clock_mux_bf2[4:0] (
    .clk0    ( bf2                                ),              
    .clk1    ( reg_bf2                            ),              
    .sel     ( reg_bf2_mux                        ),      
    .clk_out ( swi_bf2_muxed_pre                  )); 


  wire [4:0]  reg_bf2_hiz_mode;
  wav_clock_mux #(.STDCELL(STDCELL)) u_wav_clock_mux_bf2_hiz_mode[4:0] (
    .clk0    ( swi_bf2_muxed_pre                  ),              
    .clk1    ( 5'd1                               ),              
    .sel     ( dft_hiz_mode                       ),      
    .clk_out ( reg_bf2_hiz_mode                   )); 

  assign swi_bf2_muxed = reg_bf2_hiz_mode;

  //-----------------------
  //-----------------------

  wire        reg_bf3_core_scan_mode;
  wav_clock_mux #(.STDCELL(STDCELL)) u_wav_clock_mux_bf3_core_scan_mode (
    .clk0    ( reg_bf3                            ),              
    .clk1    ( 1'd1                               ),              
    .sel     ( dft_core_scan_mode                 ),      
    .clk_out ( reg_bf3_core_scan_mode             )); 


  wire        reg_bf3_iddq_mode;
  wav_clock_mux #(.STDCELL(STDCELL)) u_wav_clock_mux_bf3_iddq_mode (
    .clk0    ( reg_bf3_core_scan_mode             ),              
    .clk1    ( 1'd0                               ),              
    .sel     ( dft_iddq_mode                      ),      
    .clk_out ( reg_bf3_iddq_mode                  )); 


  wire        reg_bf3_hiz_mode;
  wav_clock_mux #(.STDCELL(STDCELL)) u_wav_clock_mux_bf3_hiz_mode (
    .clk0    ( reg_bf3_iddq_mode                  ),              
    .clk1    ( 1'd1                               ),              
    .sel     ( dft_hiz_mode                       ),      
    .clk_out ( reg_bf3_hiz_mode                   )); 


  wire        reg_bf3_bscan_mode;
  wav_clock_mux #(.STDCELL(STDCELL)) u_wav_clock_mux_bf3_bscan_mode (
    .clk0    ( reg_bf3_hiz_mode                   ),              
    .clk1    ( 1'd1                               ),              
    .sel     ( dft_bscan_mode                     ),      
    .clk_out ( reg_bf3_bscan_mode                 )); 

  assign swi_bf3 = reg_bf3_bscan_mode;

  //-----------------------

  wire        reg_set_core_scan_core_scan_mode;
  wav_clock_mux #(.STDCELL(STDCELL)) u_wav_clock_mux_set_core_scan_core_scan_mode (
    .clk0    ( reg_set_core_scan                  ),              
    .clk1    ( 1'd1                               ),              
    .sel     ( dft_core_scan_mode                 ),      
    .clk_out ( reg_set_core_scan_core_scan_mode     )); 

  assign swi_set_core_scan = reg_set_core_scan_core_scan_mode;





  //---------------------------
  // REG_WITH_BSCAN_FLOP
  // bscan_flop_drive - First in the chain since first in the file
  // bscan_flop_capture - 2nd, 3rd, 4th in chain
  //---------------------------
  wire [31:0] REG_WITH_BSCAN_FLOP_reg_read;
  reg         reg_bscan_flop_drive;

  always @(posedge RegClk or posedge RegReset) begin
    if(RegReset) begin
      reg_bscan_flop_drive                   <= 1'h0;
    end else if(RegAddr == 'h4 && RegWrEn) begin
      reg_bscan_flop_drive                   <= RegWrData[0];
    end else begin
      reg_bscan_flop_drive                   <= reg_bscan_flop_drive;
    end
  end

  assign REG_WITH_BSCAN_FLOP_reg_read = {28'h0,
          bscan_flop_capture,
          reg_bscan_flop_drive};

  //-----------------------

  wire        reg_bscan_flop_drive_core_scan_mode;
  wav_clock_mux #(.STDCELL(STDCELL)) u_wav_clock_mux_bscan_flop_drive_core_scan_mode (
    .clk0    ( reg_bscan_flop_drive               ),              
    .clk1    ( 1'd1                               ),              
    .sel     ( dft_core_scan_mode                 ),      
    .clk_out ( reg_bscan_flop_drive_core_scan_mode     )); 

  wire  bscan_flop_drive_tdo;

  wire bscan_flop_drive_bscan_flop_po;
  wav_jtag_bsr u_wav_jtag_bsr_bscan_flop_drive (
    .i_tck         ( dft_bscan_tck                      ),          
    .i_trst_n      ( dft_bscan_trstn                    ),          
    .i_bsr_mode    ( dft_bscan_mode                     ),          
    .i_capture     ( dft_bscan_capture                  ),          
    .i_shift       ( dft_bscan_shift                    ),          
    .i_update      ( dft_bscan_update                   ),               
    .i_pi          ( reg_bscan_flop_drive_core_scan_mode     ),               
    .o_po          ( bscan_flop_drive_bscan_flop_po     ),               
    .i_tdi         ( dft_bscan_tdi                      ),                
    .o_tdo         ( bscan_flop_drive_tdo               )); 


  assign swi_bscan_flop_drive = bscan_flop_drive_bscan_flop_po;

  //-----------------------
  wire [2:0] bscan_flop_capture_tdo;

  wav_jtag_bsr u_wav_jtag_bsr_bscan_flop_capture[2:0] (
    .i_tck         ( dft_bscan_tck                      ),          
    .i_trst_n      ( dft_bscan_trstn                    ),          
    .i_bsr_mode    ( dft_bscan_mode                     ),          
    .i_capture     ( dft_bscan_capture                  ),          
    .i_shift       ( dft_bscan_shift                    ),          
    .i_update      ( dft_bscan_update                   ),               
    .i_pi          ( bscan_flop_capture                 ),               
    .o_po          ( /*noconn*/                         ),               
    .i_tdi         ( {bscan_flop_capture_tdo[1],
                      bscan_flop_capture_tdo[0],
                      bscan_flop_drive_tdo}     ),                
    .o_tdo         ( {bscan_flop_capture_tdo[2],
                      bscan_flop_capture_tdo[1],
                      bscan_flop_capture_tdo[0]}     )); 






  //---------------------------
  // LAST_BSCAN_FLOP
  // last_one_in_chain - Last one in the chain
  //---------------------------
  wire [31:0] LAST_BSCAN_FLOP_reg_read;
  reg         reg_last_one_in_chain;

  always @(posedge RegClk or posedge RegReset) begin
    if(RegReset) begin
      reg_last_one_in_chain                  <= 1'h0;
    end else if(RegAddr == 'h8 && RegWrEn) begin
      reg_last_one_in_chain                  <= RegWrData[0];
    end else begin
      reg_last_one_in_chain                  <= reg_last_one_in_chain;
    end
  end

  assign LAST_BSCAN_FLOP_reg_read = {31'h0,
          reg_last_one_in_chain};

  //-----------------------
  wire  last_one_in_chain_tdo;

  wire last_one_in_chain_bscan_flop_po;
  wav_jtag_bsr u_wav_jtag_bsr_last_one_in_chain (
    .i_tck         ( dft_bscan_tck                      ),          
    .i_trst_n      ( dft_bscan_trstn                    ),          
    .i_bsr_mode    ( dft_bscan_mode                     ),          
    .i_capture     ( dft_bscan_capture                  ),          
    .i_shift       ( dft_bscan_shift                    ),          
    .i_update      ( dft_bscan_update                   ),               
    .i_pi          ( reg_last_one_in_chain              ),               
    .o_po          ( last_one_in_chain_bscan_flop_po     ),               
    .i_tdi         ( bscan_flop_capture_tdo[2]          ),                
    .o_tdo         ( last_one_in_chain_tdo              )); 


  assign swi_last_one_in_chain = last_one_in_chain_bscan_flop_po;





  //---------------------------
  // DEBUG_BUS_CTRL
  // DEBUG_BUS_CTRL_SEL - Select signal for DEBUG_BUS_CTRL
  //---------------------------
  wire [31:0] DEBUG_BUS_CTRL_reg_read;
  reg         reg_debug_bus_ctrl_sel;

  always @(posedge RegClk or posedge RegReset) begin
    if(RegReset) begin
      reg_debug_bus_ctrl_sel                 <= 1'h0;
    end else if(RegAddr == 'hc && RegWrEn) begin
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
      'd0 : debug_bus_ctrl_status = {27'd0, swi_bf2_muxed};
      default : debug_bus_ctrl_status = 32'd0;
    endcase
  end 
  
  assign DEBUG_BUS_STATUS_reg_read = {          debug_bus_ctrl_status};

  //-----------------------

  //=======================
  // Final BSCAN Connection
  //=======================
  assign dft_bscan_tdo = last_one_in_chain_tdo;


  
    
  //---------------------------
  // PRDATA Selection
  //---------------------------
  reg [31:0] prdata_sel;
  
  always @(*) begin
    case(RegAddr)
      'h0    : prdata_sel = REG1_reg_read;
      'h4    : prdata_sel = REG_WITH_BSCAN_FLOP_reg_read;
      'h8    : prdata_sel = LAST_BSCAN_FLOP_reg_read;
      'hc    : prdata_sel = DEBUG_BUS_CTRL_reg_read;
      'h10   : prdata_sel = DEBUG_BUS_STATUS_reg_read;

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
      'h10   : pslverr_pre = 1'b0;

      default : pslverr_pre = 1'b1;
    endcase
  end
  
  assign PSLVERR = pslverr_pre;

endmodule
