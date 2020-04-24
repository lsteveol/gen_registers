//===================================================================
//
// Copyright (C) Wavious 2019 - All Rights Reserved
//
// Unauthorized copying of this file, via any medium is strictly prohibited
//
// Created by sbridges on November/05/2019 at 14:22:58
//
// my_regs_regs_top.v
//
//===================================================================



module my_regs_regs_top #(
  parameter    ADDR_WIDTH = 8,
  parameter    STDCELL    = 1
)(
  //REG1
  input  wire [4:0]   bf1,
  output wire [4:0]   swi_bf1_muxed,
  input  wire [4:0]   bf2,
  output wire [4:0]   swi_bf2_muxed,
  output wire [3:0]   swi_bf3,
  output wire [4:0]   swi_bf3longname,
  //AREADONLYREG
  input  wire         some_status_in,
  //ANOTHERREG
  output wire [4:0]   swi_bloofgg,
  input  wire [2:0]   rarara,
  output wire [3:0]   swi_poopoo,
  //RO_REG1
  input  wire [2:0]   robf,
  input  wire         byp_in,
  //WF_REG
  output wire [7:0]   wfifo_wdata,
  output wire         wfifo_winc_wdata,

  //DFT Ports (if used)
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
  wire dft_core_scan_mode = 1'b0;
  wire dft_iddq_mode = 1'b0;
  wire dft_hiz_mode = 1'b0;

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
  reg  reg_bf2_mux;



  //---------------------------
  // REG1
  // bf1 - Some description1                
  // bf1_mux - Some description2                
  // bf2 - Some description1                
  // bf2_mux - Some description2                
  // bf3 - 
  // bf3longname - 
  //---------------------------
  wire [31:0] REG1_reg_read;
  reg  [4:0]   reg_bf1;
  reg  [4:0]   reg_bf2;
  reg [3:0]   reg_bf3;
  reg [4:0]   reg_bf3longname;

  always @(posedge RegClk or posedge RegReset) begin
    if(RegReset) begin
      reg_bf1                                <= 5'h0;
      reg_bf1_mux                            <= 1'h1;
      reg_bf2                                <= 5'h0;
      reg_bf2_mux                            <= 1'h1;
      reg_bf3                                <= 4'ha;
      reg_bf3longname                        <= 5'ha;
    end else if(RegAddr == 'h0 && RegWrEn) begin
      reg_bf1                                <= RegWrData[4:0];
      reg_bf1_mux                            <= RegWrData[5];
      reg_bf2                                <= RegWrData[10:6];
      reg_bf2_mux                            <= RegWrData[11];
      reg_bf3                                <= RegWrData[15:12];
      reg_bf3longname                        <= RegWrData[20:16];
    end else begin
      reg_bf1                                <= reg_bf1;
      reg_bf1_mux                            <= reg_bf1_mux;
      reg_bf2                                <= reg_bf2;
      reg_bf2_mux                            <= reg_bf2_mux;
      reg_bf3                                <= reg_bf3;
      reg_bf3longname                        <= reg_bf3longname;
    end
  end

  assign REG1_reg_read = {11'h0,
          reg_bf3longname,
          reg_bf3,
          reg_bf2_mux,
          reg_bf2,
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
  //-----------------------

  wire [4:0]  swi_bf2_muxed_pre;
  wav_clock_mux #(.STDCELL(STDCELL)) u_wav_clock_mux_bf2[4:0] (
    .clk0    ( bf2                                ),              
    .clk1    ( reg_bf2                            ),              
    .sel     ( reg_bf2_mux                        ),      
    .clk_out ( swi_bf2_muxed_pre                  )); 

  assign swi_bf2_muxed = swi_bf2_muxed_pre;

  //-----------------------
  //-----------------------
  assign swi_bf3 = reg_bf3;

  //-----------------------
  assign swi_bf3longname = reg_bf3longname;





  //---------------------------
  // AREADONLYREG
  // some_status_in - A signal I want to observe  
  //---------------------------
  wire [31:0] AREADONLYREG_reg_read;
  assign AREADONLYREG_reg_read = {31'h0,
          some_status_in};

  //-----------------------




  //---------------------------
  // ANOTHERREG
  // bloofgg - 
  // rarara - 
  // poopoo - 
  //---------------------------
  wire [31:0] ANOTHERREG_reg_read;
  reg [4:0]   reg_bloofgg;
  reg [3:0]   reg_poopoo;

  always @(posedge RegClk or posedge RegReset) begin
    if(RegReset) begin
      reg_bloofgg                            <= 5'hc;
      reg_poopoo                             <= 4'h4;
    end else if(RegAddr == 'h8 && RegWrEn) begin
      reg_bloofgg                            <= RegWrData[4:0];
      reg_poopoo                             <= RegWrData[11:8];
    end else begin
      reg_bloofgg                            <= reg_bloofgg;
      reg_poopoo                             <= reg_poopoo;
    end
  end

  assign ANOTHERREG_reg_read = {20'h0,
          reg_poopoo,
          rarara,
          reg_bloofgg};

  //-----------------------
  assign swi_bloofgg = reg_bloofgg;

  //-----------------------
  //-----------------------
  wire [3:0] poopoo_tdo;

  wire poopoo_bscan_flop_po;
  wav_jtag_bsr u_wav_jtag_bsr_poopoo[3:0] (
    .i_tck         ( dft_bscan_tck                      ),          
    .i_trst_n      ( dft_bscan_trstn                    ),          
    .i_bsr_mode    ( dft_bscan_mode                     ),          
    .i_capture     ( dft_bscan_capture                  ),          
    .i_shift       ( dft_bscan_shift                    ),          
    .i_update      ( dft_bscan_update                   ),               
    .i_pi          ( reg_poopoo                         ),               
    .o_po          ( poopoo_bscan_flop_po               ),               
    .i_tdi         ( {poopoo_tdo[2],
                      poopoo_tdo[1],
                      poopoo_tdo[0],
                      dft_bscan_tdi}     ),                
    .o_tdo         ( {poopoo_tdo[3],
                      poopoo_tdo[2],
                      poopoo_tdo[1],
                      poopoo_tdo[0]}     )); 


  assign swi_poopoo = poopoo_bscan_flop_po;





  //---------------------------
  // RO_REG1
  // robf - 
  // byp_in - 
  //---------------------------
  wire [31:0] RO_REG1_reg_read;
  assign RO_REG1_reg_read = {28'h0,
          byp_in,
          robf};

  //-----------------------
  //-----------------------
  wire  byp_in_tdo;

  wav_jtag_bsr u_wav_jtag_bsr_byp_in (
    .i_tck         ( dft_bscan_tck                      ),          
    .i_trst_n      ( dft_bscan_trstn                    ),          
    .i_bsr_mode    ( dft_bscan_mode                     ),          
    .i_capture     ( dft_bscan_capture                  ),          
    .i_shift       ( dft_bscan_shift                    ),          
    .i_update      ( dft_bscan_update                   ),               
    .i_pi          ( byp_in                             ),               
    .o_po          ( /*noconn*/                         ),               
    .i_tdi         ( poopoo_tdo[3]                      ),                
    .o_tdo         ( byp_in_tdo                         )); 






  //---------------------------
  // WF_REG
  // wdata - 
  //---------------------------
  wire [31:0] WF_REG_reg_read;

  assign wfifo_wdata      = (RegAddr == 'h10 && RegWrEn) ? RegWrData[7:0] : 'd0;
  assign wfifo_winc_wdata = (RegAddr == 'h10 && RegWrEn);
  assign WF_REG_reg_read = {24'h0,
          8'd0}; //Reserved

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
    end else if(RegAddr == 'h14 && RegWrEn) begin
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
      'd1 : debug_bus_ctrl_status = {27'd0, swi_bf2_muxed};
      default : debug_bus_ctrl_status = 32'd0;
    endcase
  end 
  
  assign DEBUG_BUS_STATUS_reg_read = {          debug_bus_ctrl_status};

  //-----------------------

  //=======================
  // Final BSCAN Connection
  //=======================
  assign dft_bscan_tdo = byp_in_tdo;


  
    
  //---------------------------
  // PRDATA Selection
  //---------------------------
  reg [31:0] prdata_sel;
  
  always @(*) begin
    case(RegAddr)
      'h0    : prdata_sel = REG1_reg_read;
      'h4    : prdata_sel = AREADONLYREG_reg_read;
      'h8    : prdata_sel = ANOTHERREG_reg_read;
      'hc    : prdata_sel = RO_REG1_reg_read;
      'h10   : prdata_sel = WF_REG_reg_read;
      'h14   : prdata_sel = DEBUG_BUS_CTRL_reg_read;
      'h18   : prdata_sel = DEBUG_BUS_STATUS_reg_read;

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
      'h14   : pslverr_pre = 1'b0;
      'h18   : pslverr_pre = 1'b0;

      default : pslverr_pre = 1'b1;
    endcase
  end
  
  assign PSLVERR = pslverr_pre;

endmodule
