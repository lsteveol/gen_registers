#!/bin/csh -f


if(-d dist) then
  rm -rf dist
endif


#

#pyinstaller --onefile --add-data="../python/sub/*.py:." \
#  --paths="../python/sub/" \
#  --hidden-import="pyparsing" \
#  ../python/gen_uvm_reg_model

../venv/bin/pyinstaller --onefile \
  --paths="../python/" \
  --paths="../python/sub/" \
  --add-data="../python/sub/*.py:." \
  --hidden-import="pyparsing" \
  ../python/gen_uvm_reg_model

if(-e dist/gen_uvm_reg_model) then
  cp dist/gen_uvm_reg_model ../
endif
