Overview
========
``gen_regs_py`` is a Python based Register RTL generation tool. The aim of gen_regs_py is to automate the register
design and creation process, resulting in quicker RTL development and fewer bugs along the way.

Using simple text file input, a designer can quickly develop registers. No clunky spreadsheets, no crazy syntaxes, just simple
text files.

The tool will create a register block that has a APB/AHB slave interface to be used for transactions


Running the Script (Options)
----------------------------

-h, --help
  Shows the HELP message

-i, -input_file (REQUIRED)
  Input file to be used for parsing. There are no requirements on the file extention

-p, -prefix (REQUIRED)
  PREFIX NAME to be used. This has no effect on the bitfield names in the RTL

-b, -block (REQUIRED)
  BLOCK NAME to be used. This has no effect on the bitfield names in the RTL
  
-ahb (Optional)
  Creates the register block with an AHB-Lite supported interface.
  
  .. note ::
    
    Register operation is not changed by interface type.

-sphinx (Optional)
  Prints out a Sphinx formatted table for documentation purposes.

-dv (Optional)
  Creates 'DV' related files that are used for DV and/or fed into the ``gen_uvm_reg_model`` script.  

-dbg (Optional)
  Prints some info to the console during building. Can be used to track down any incorrect input file setup

.. note::

  The **PREFIX** and **BLOCK** names are used to *uniquify* the design. For the RTL the only place these are seen
  is in the output RTL and module name. During DV, these are used as qualifiers to specific blocks.

After running the script, provided no errors for setup, you should receive a verilog file in the following format:
``<prefix>_<block>_regs_top.v``


Here is an example of an input file

.. code-block:: none

   REG1                RW
     bf1               5'b0                    Some description1                
     bf1_mux           1'b1                    Some description2                
     bf2               5'b0                    Some description1                
     bf2_mux           1'b1                    Some description2                
     bf3               4'ha      
     bf3longname       5'd10        

   AREADONLYREG        RO
     some_status_in    1'b0                    A signal I want to observe  



And here is what part of the output Verilog would look like

.. code-block:: verilog

    //---------------------------
    // REG1
    // bf1 - Some description1                
    // bf1_mux - Some description2                
    // bf2 - Some description1                
    // bf2_mux - Some description2                
    // bf3 - 
    // bf3longname - 
    //---------------------------
    wire [31:0] REG1_reg_read;
    reg  [4:0]   reg_bf1;
    reg  [4:0]   reg_bf2;
    reg [3:0]   reg_bf3;
    reg [4:0]   reg_bf3longname;

    always @(posedge RegClk or posedge RegReset) begin
      if(RegReset) begin
        reg_bf1                                <= 5'h0;
        reg_bf1_mux                            <= 1'h1;
        reg_bf2                                <= 5'h0;
        reg_bf2_mux                            <= 1'h1;
        reg_bf3                                <= 4'ha;
        reg_bf3longname                        <= 5'ha;
      end else if(RegAddr == 'h0 && RegWrEn) begin
        reg_bf1                                <= RegWrData[4:0];
        reg_bf1_mux                            <= RegWrData[5];
        reg_bf2                                <= RegWrData[10:6];
        reg_bf2_mux                            <= RegWrData[11];
        reg_bf3                                <= RegWrData[15:12];
        reg_bf3longname                        <= RegWrData[20:16];
      end else begin
        reg_bf1                                <= reg_bf1;
        reg_bf1_mux                            <= reg_bf1_mux;
        reg_bf2                                <= reg_bf2;
        reg_bf2_mux                            <= reg_bf2_mux;
        reg_bf3                                <= reg_bf3;
        reg_bf3longname                        <= reg_bf3longname;
      end
    end

    assign REG1_reg_read = {11'h0,
            reg_bf3longname,
            reg_bf3,
            reg_bf2_mux,
            reg_bf2,
            reg_bf1_mux,
            reg_bf1};

    //-----------------------

    wire [4:0]  swi_bf1_muxed_pre;
    wav_clock_mux #(.STDCELL(STDCELL)) u_wav_clock_mux_bf1[4:0] (
      .clk0    ( bf1                                ),              
      .clk1    ( reg_bf1                            ),              
      .sel     ( reg_bf1_mux                        ),      
      .clk_out ( swi_bf1_muxed_pre                  )); 

    assign swi_bf1_muxed = swi_bf1_muxed_pre;

    //-----------------------
    //-----------------------

    wire [4:0]  swi_bf2_muxed_pre;
    wav_clock_mux #(.STDCELL(STDCELL)) u_wav_clock_mux_bf2[4:0] (
      .clk0    ( bf2                                ),              
      .clk1    ( reg_bf2                            ),              
      .sel     ( reg_bf2_mux                        ),      
      .clk_out ( swi_bf2_muxed_pre                  )); 

    assign swi_bf2_muxed = swi_bf2_muxed_pre;

    //-----------------------
    //-----------------------
    assign swi_bf3 = reg_bf3;

    //-----------------------
    assign swi_bf3longname = reg_bf3longname;





    //---------------------------
    // AREADONLYREG
    // some_status_in - A signal I want to observe  
    //---------------------------
    wire [31:0] AREADONLYREG_reg_read;
    assign AREADONLYREG_reg_read = {31'h0,
            some_status_in};



