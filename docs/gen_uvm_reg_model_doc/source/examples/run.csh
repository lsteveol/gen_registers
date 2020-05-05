#!/bin/csh -f

setenv TEST_REGS  /prj/wavious/r0_tsmc28hpc/iceng/work/sbridges/scripts/py_regs/gen_uvm_reg_model_doc/source/examples


set    scripts    = /cad/bin
#set    scripts    = /prj/wavious/r0_tsmc28hpc/iceng/work/sbridges/scripts/py_regs
set    reg_model  = wav_reg_model_lss

${scripts}/gen_uvm_reg_model -b ${TEST_REGS}/lss.sys -o ${reg_model} 
