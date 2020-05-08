`timescale 1ns/1ps

package test_regs_test_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  import gr_reg_pkg::*;
  
  import test_regs_pkg::*;
  
  `include "tests/test_regs_base_test.sv"
  `include "tests/test_regs_hw_reset_test.sv"
  `include "tests/test_regs_bit_bash_test.sv"
endpackage
