#!/bin/csh -f

if($#argv < 1) then
  echo "No test defined!"
  echo "Usage:"
  echo "       $0 <test>"
  exit 1
endif

set TB_BASE = ../

set GR_PKG  = "+incdir+$TB_BASE/sv/gr_uvm_reg_agent/ \
               $TB_BASE/sv/gr_uvm_reg_agent/gr_reg_pkg.sv"


xrun -stop_on_build_error  -sv  -64bit   -licqueue -warn_multiple_driver -errormax 1 \
  -timescale "1ns/1ps" -l xrun.log -uvm -access rwc -input input.tcl -fsmdebug \
  $GR_PKG \
  +incdir+$TB_BASE \
  $TB_BASE/sv/test_regs_pkg.sv \
  $TB_BASE/tests/test_regs_test_pkg.sv \
  $TB_BASE/tb_top/test_regs_tb_top.sv \
  $TB_BASE/tb_top/*.v +UVM_TESTNAME=$1
