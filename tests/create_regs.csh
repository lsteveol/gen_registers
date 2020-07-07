#!/bin/csh -f


set scripts       = ../
set scripts       = ../python

set    blk_name   = regs.blk

set    reg_model  = test_reg_model

if(-e $blk_name) then
  rm $blk_name
  touch $blk_name
endif
echo "BLK:test_regs.txt    N/A   my    reg    0x0000" >> $blk_name

$scripts/gen_regs_py        -i test_regs.txt -p test -b regs 
$scripts/gen_uvm_reg_model  -b $blk_name  -o $reg_model


mv test_regs_regs_top.v   tb_top/
mv test_reg_model.*       sv/register/
