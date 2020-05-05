Overview
========
``gen_uvm_reg_model`` is a Python based script that can create large scale UVM reg_models, along with software header files 
and PDF documents.

``gen_uvm_reg_model`` builds on various other register flows, like ``gen_regs_py`` to facilitate a automated flow for design to DV handoff.

Running the Script (Options)
----------------------------

-h, --help
  Shows the HELP message. Also prints a link to this documenation

-b, -blk (REQUIRED)
  Input block/system file to be used for register model generation.
  
-o, -out (Optional)
  Output reg_model name. Defaults to `wav_uvm_reg_model`. Define without any file extension.

-p, -prefix (Optional)
  Global prefix to apply to each register. This is usually a chip/project name. Use caution when dealing with lower level
  blocks.

-aw, -addr_width (Optional)
  Sets the **ADDRESS** width for internal reg mappings. Defaults to 32 bit.

-ch, -cheader (Optional)
  Prints out a C #defines to a .h file for each block in the system. The output of this is usually passed to the software team.

-dbg, -debug (Optional, **not recommended**)
  Prints out various debug messages during the run. Only use when debugging.

-sp, -script_path (Optional, **not recommended**)
  Changes the search path for ``gen_regs_py`` or any other scripts called. This is usually for the developer or for trying out 
  a change before submitting it live.


