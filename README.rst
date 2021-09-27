gen_registers
=============
A Python based tool for generating hardware registers and their associated files


Create Some Registers!
----------------------

:: 

  cat > my_regs.txt
  MY_REG_1           RW                It's a read-write register
    bf1              1'b0              Single bit RW register that resets to 0
    bf2              3'd7              A 3bit RW register that reset to 7
    bf               4'h9              We don't leave our hex friends hanging

  MY_REG_2           RW
   somebf            1'b0              
   readit            1'b0     RO       This is a read-only register 
  
  CTRL-D


  gen_regs_py -i my_regs.txt -p my -b regs
  Generating file -- my_regs_regs_top.v
  
  head -50 my_regs_regs_top.v

  //===================================================================
  //
  // Created by sbridges on September/27/2021 at 13:39:28
  //
  // my_regs_regs_top.v
  //
  //===================================================================



  module my_regs_regs_top #(
    parameter    ADDR_WIDTH = 8
  )(
    //MY_REG_1
    output wire         swi_bf1,
    output wire [2:0]   swi_bf2,
    output wire [3:0]   swi_bf,
    //MY_REG_2
    output wire         swi_somebf,
    input  wire         readit,
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


See the gen_regs_py.pdf for more details and usecases!

* **python** - Dir for python files
* **docs** - Documentation using Sphinx (can also look at pdfs in the top level)
* **exec** - Single file executables for deployment (are copied to top level after generation)
* **tests** - Example testbench using the gr_uvm_reg_agent to validate any changes to the gen_regs_py or gen_uvm_reg_model script

The executables are provided for deploying across multiple servers. I had to do this at work and I just got fed up with
having to make sure each server had pip modules. I wasn't even about to try to get everyone on virtualenvs!

**gen_uvm_reg_model doc is half-baked. Will try to update when time allows**

virtualenv
----------
If you want to play around with it....

Due to some older server support originally still on python 2.7 (really 2.6 support). Want to upgrade to 3.6 when time allows.
So for now we should do the following to compile the executible.

'virtualenv venv' at top level repo
source venv/bin/activate* (* is shell type)
pip install -r requirements.txt (at least pyparsing)

We can then point to the pyinstaller in the venv/bin dir for compiling
