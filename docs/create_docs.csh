#!/bin/csh -f


cd gen_regs_py_doc
make pdf
cd ..

cd gen_uvm_reg_model_doc
make pdf
cd ..

cp gen_regs_py_doc/build/pdf/gen_regs_py.pdf ../
cp gen_uvm_reg_model_doc/build/pdf/gen_uvm_reg_model.pdf ../
