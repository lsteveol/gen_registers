#!/bin/csh -f


if(-d dist) then
  rm -rf dist
endif


pyinstaller --onefile ../python/gen_regs_py

if(-e dist/gen_regs_py) then
  cp dist/gen_regs_py ../
endif
