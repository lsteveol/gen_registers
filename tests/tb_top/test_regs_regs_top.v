//===================================================================
//
// Created by sbridges on July/07/2020 at 14:07:45
//
// test_regs_regs_top.v
//
//===================================================================



module test_regs_regs_top #(
  parameter    ADDR_WIDTH = 8
)(
  //REG1
  output wire         swi_rw_bf1,
  input  wire [2:0]   rw_bf2,
  output wire [2:0]   swi_rw_bf2_muxed,
  //REG2
  output wire [7:0]   swi_reg2_rw_bf1,
  input  wire [4:0]   reg2_ro_bf1,
  output wire         swi_reg2_rw_bf2,
  input  wire         reg2_ro_bf2,
  //REG3
  output wire [7:0]   wfifo_my_wfifo_reg,
  output wire         wfifo_winc_my_wfifo_reg,
  //REG4
  input  wire [7:0]   rfifo_my_rfifo_reg,
  output wire         rfifo_rinc_my_rfifo_reg,
  //REG5
  input  wire         w1c_in_my_w1c_bf,
  output wire         w1c_out_my_w1c_bf,
  //DEBUG_BUS_STATUS
  output reg  [31:0]  debug_bus_ctrl_status,

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
  reg  reg_rw_bf2_mux;



  //---------------------------
  // REG1
  // rw_bf1 - rw_bf1 description
  // rw_bf2 - rw_bf2 description
  // rw_bf2_mux - 
  //---------------------------
  wire [31:0] REG1_reg_read;
  reg         reg_rw_bf1;
  reg  [2:0]   reg_rw_bf2;

  always @(posedge RegClk or posedge RegReset) begin
    if(RegReset) begin
      reg_rw_bf1                             <= 1'h0;
      reg_rw_bf2                             <= 3'h4;
      reg_rw_bf2_mux                         <= 1'h0;
    end else if(RegAddr == 'h0 && RegWrEn) begin
      reg_rw_bf1                             <= RegWrData[0];
      reg_rw_bf2                             <= RegWrData[3:1];
      reg_rw_bf2_mux                         <= RegWrData[4];
    end else begin
      reg_rw_bf1                             <= reg_rw_bf1;
      reg_rw_bf2                             <= reg_rw_bf2;
      reg_rw_bf2_mux                         <= reg_rw_bf2_mux;
    end
  end

  assign REG1_reg_read = {27'h0,
          reg_rw_bf2_mux,
          reg_rw_bf2,
          reg_rw_bf1};

  //-----------------------
  assign swi_rw_bf1 = reg_rw_bf1;

  //-----------------------

  wire [2:0]  swi_rw_bf2_muxed_pre;
  booboo_mux u_booboo_mux_rw_bf2[2:0] (
    .clk0    ( rw_bf2                             ),              
    .clk1    ( reg_rw_bf2                         ),              
    .sel     ( reg_rw_bf2_mux                     ),      
    .clk_out ( swi_rw_bf2_muxed_pre               )); 

  assign swi_rw_bf2_muxed = swi_rw_bf2_muxed_pre;

  //-----------------------




  //---------------------------
  // REG2
  // reg2_rw_bf1 - 
  // reg2_ro_bf1 - 
  // reg2_rw_bf2 - 
  // reg2_ro_bf2 - 
  //---------------------------
  wire [31:0] REG2_reg_read;
  reg [7:0]   reg_reg2_rw_bf1;
  reg         reg_reg2_rw_bf2;

  always @(posedge RegClk or posedge RegReset) begin
    if(RegReset) begin
      reg_reg2_rw_bf1                        <= 8'h0;
      reg_reg2_rw_bf2                        <= 1'h1;
    end else if(RegAddr == 'h4 && RegWrEn) begin
      reg_reg2_rw_bf1                        <= RegWrData[7:0];
      reg_reg2_rw_bf2                        <= RegWrData[13];
    end else begin
      reg_reg2_rw_bf1                        <= reg_reg2_rw_bf1;
      reg_reg2_rw_bf2                        <= reg_reg2_rw_bf2;
    end
  end

  assign REG2_reg_read = {17'h0,
          reg2_ro_bf2,
          reg_reg2_rw_bf2,
          reg2_ro_bf1,
          reg_reg2_rw_bf1};

  //-----------------------
  assign swi_reg2_rw_bf1 = reg_reg2_rw_bf1;

  //-----------------------
  //-----------------------
  assign swi_reg2_rw_bf2 = reg_reg2_rw_bf2;

  //-----------------------




  //---------------------------
  // REG3
  // my_wfifo_reg - 
  //---------------------------
  wire [31:0] REG3_reg_read;

  assign wfifo_my_wfifo_reg      = (RegAddr == 'h8 && RegWrEn) ? RegWrData[7:0] : 'd0;
  assign wfifo_winc_my_wfifo_reg = (RegAddr == 'h8 && RegWrEn);
  assign REG3_reg_read = {24'h0,
          8'd0}; //Reserved

  //-----------------------




  //---------------------------
  // REG4
  // my_rfifo_reg - 
  //---------------------------
  wire [31:0] REG4_reg_read;

  assign rfifo_rinc_my_rfifo_reg = (RegAddr == 'hc && PENABLE && PSEL && ~(PWRITE || RegWrEn));
  assign REG4_reg_read = {24'h0,
          rfifo_my_rfifo_reg};

  //-----------------------




  //---------------------------
  // REG5
  // my_w1c_bf - 
  //---------------------------
  wire [31:0] REG5_reg_read;
  reg          reg_w1c_my_w1c_bf;
  wire         reg_w1c_in_my_w1c_bf_ff2;
  reg          reg_w1c_in_my_w1c_bf_ff3;

  // my_w1c_bf W1C Logic
  always @(posedge RegClk or posedge RegReset) begin
    if(RegReset) begin
      reg_w1c_my_w1c_bf                         <= 1'h0;
      reg_w1c_in_my_w1c_bf_ff3                  <= 1'h0;
    end else begin
      reg_w1c_my_w1c_bf                         <= RegWrData[0] && reg_w1c_my_w1c_bf && (RegAddr == 'h10) && RegWrEn ? 1'b0 : (reg_w1c_in_my_w1c_bf_ff2 & ~reg_w1c_in_my_w1c_bf_ff3 ? 1'b1 : reg_w1c_my_w1c_bf);
      reg_w1c_in_my_w1c_bf_ff3                  <= reg_w1c_in_my_w1c_bf_ff2;
    end
  end

  mai_demet u_mai_demet_my_w1c_bf (
    .clk     ( RegClk                                     ),              
    .reset   ( RegReset                                   ),              
    .sig_in  ( w1c_in_my_w1c_bf                           ),            
    .sig_out ( reg_w1c_in_my_w1c_bf_ff2                   )); 

  assign REG5_reg_read = {31'h0,
          reg_w1c_my_w1c_bf};

  //-----------------------
  assign w1c_out_my_w1c_bf = reg_w1c_my_w1c_bf;




  //---------------------------
  // DEBUG_BUS_CTRL
  // DEBUG_BUS_CTRL_SEL - Select signal for DEBUG_BUS_CTRL
  //---------------------------
  wire [31:0] DEBUG_BUS_CTRL_reg_read;
  reg         reg_debug_bus_ctrl_sel;
  wire         swi_debug_bus_ctrl_sel;

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

  //Debug bus control logic  
  always @(*) begin
    case(swi_debug_bus_ctrl_sel)
      'd0 : debug_bus_ctrl_status = {17'd0, reg2_ro_bf2, 1'd0, reg2_ro_bf1, 8'd0};
      'd1 : debug_bus_ctrl_status = {29'd0, swi_rw_bf2_muxed};
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
      'h4    : prdata_sel = REG2_reg_read;
      'h8    : prdata_sel = REG3_reg_read;
      'hc    : prdata_sel = REG4_reg_read;
      'h10   : prdata_sel = REG5_reg_read;
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
