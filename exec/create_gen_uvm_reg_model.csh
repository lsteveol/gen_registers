#!/bin/csh -f


if(-d dist) then
  rm -rf dist
endif


pyinstaller --onefile ../python/gen_uvm_reg_model

if(-e dist/gen_uvm_reg_model) then
  cp dist/gen_uvm_reg_model ../
endif
