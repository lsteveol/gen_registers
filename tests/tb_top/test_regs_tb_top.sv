`timescale 1ns/1ps

module test_regs_tb_top;
  
import uvm_pkg::*;
import test_regs_pkg::*;
import test_regs_test_pkg::*;

reg RegReset  = 1;
reg RegClk    = 0;
always #10ns RegClk <= ~RegClk;


gr_apb_if apb_if(.clk(RegClk), .reset(RegReset));

initial begin
  #10ns;
  RegReset = 0;
end

initial begin
  uvm_config_db#(virtual gr_apb_if)::set(uvm_root::get(), "*", "gr_apb_if", apb_if);
  run_test();
end


test_regs_regs_top #(
  //parameters
  .ADDR_WIDTH         ( 8         )
) u_test_regs_regs_top (
  .swi_rw_bf1                  (                              ),  //output - 1              
  .rw_bf2                      ( 3'd5                         ),  //input -  [2:0]              
  .swi_rw_bf2_muxed            (                              ),  //output - [2:0]              
  .swi_reg2_rw_bf1             (                              ),  //output - [7:0]              
  .reg2_ro_bf1                 ( 5'h19                        ),  //input -  [4:0]              
  .swi_reg2_rw_bf2             (                              ),  //output - 1              
  .reg2_ro_bf2                 ( 1'b0                         ),  //input -  1              
  .wfifo_my_wfifo_reg          (                              ),  //output - [7:0]              
  .wfifo_winc_my_wfifo_reg     (                              ),  //output - 1              
  .rfifo_my_rfifo_reg          ( 8'd200                       ),  //input -  [7:0]              
  .rfifo_rinc_my_rfifo_reg     (                              ),  //output - 1              
  .w1c_in_my_w1c_bf            ( 1'b0                         ),  //input -  1              
  .w1c_out_my_w1c_bf           (                              ),  //output - 1              
  .debug_bus_ctrl_status       (                              ),  //output - reg [31:0]              
  .RegReset                    ( RegReset                     ),  //input -  1              
  .RegClk                      ( RegClk                       ),  //input -  1              
  .PSEL                        ( apb_if.psel                  ),  //input -  1              
  .PENABLE                     ( apb_if.penable               ),  //input -  1              
  .PWRITE                      ( apb_if.pwrite                ),  //input -  1              
  .PSLVERR                     ( apb_if.pslverr               ),  //output - 1              
  .PREADY                      ( apb_if.pready                ),  //output - 1              
  .PADDR                       ( apb_if.paddr                 ),  //input -  [(ADDR_WIDTH-1):0]             
  .PWDATA                      ( apb_if.pwdata                ),  //input -  [31:0]              
  .PRDATA                      ( apb_if.prdata                )); //output - [31:0]  


endmodule
