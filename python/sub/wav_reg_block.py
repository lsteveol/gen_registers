"""
wav_reg_block.py
~~~~~~~~~~

A module to implement a block of registers


"""

import re
import math
import wav_bitfield as wbf
import wav_register as wr
import wav_print as wp
import sys


#For PDF Gen
#from reportlab.lib.enums import TA_JUSTIFY
#from reportlab.lib.pagesizes import letter
#from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Image, Table, TableStyle, PageBreak
#from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
#from reportlab.lib.units import inch
#from reportlab.lib import colors

class RegBlock(object):

  ################################################
  def __init__(self, base_name='', mapname='MAP_APB', mapaddr='0x0'):
    """Base Name: Name associated with gen_regs file (-p/-b options)
       Name     : Name associated in the register space (basically like the instance).
                  i.e. if the base_name is WMP_TX, the name would be L0_WMP_TX
       Base Addr: Base Address relative to some system """
    
    #Base name can be used to reference back to the lowest
    #level of the hierarchy
    self.base_name= base_name.upper()
    
    self.name     = base_name.upper()          
    self.base_addr= 0
    self.reg_list = []
    self.mapname  = mapname
    #Remove any underscores, python2 issue
    mapaddr = re.sub(r'_', '', mapaddr)
    self.mapaddr  = mapaddr
    
    self.addr_width = 8
    self.mux_list = []
    
#    self.RW_color = colors.HexColor("#7091ff")
#    self.RO_color = colors.HexColor("#3dffae")
#    self.W1C_color= colors.HexColor("#0abdbd")
#    self.WO_color = colors.HexColor("#bd590a")
    
    
    #Address Width
    self.addrw    = '32'

  ################################################
  def add_reg(self, reg, bypass_bf_chk=0):
    reg.add_offset(self.mapaddr)
    
    
    
    #check dupe reg name
    for r in self.reg_list:
      if r.name.lower() == reg.name.lower():
        print("Error: Register {0} has been declared twice! Please fix".format(r.name))
        sys.exit(1)
    
    #reserved fix for DLA since they are using a huge DV.txt file
    #Should we add this to only happen if bypass_bf_chk is true?    
    rsvd_index = 0
    for bf in reg.bf_list:
      rchk = bf.name.lower()
      rchk_rsvd = rchk.startswith("reserved")
      if rchk_rsvd:
        bf.name = bf.name+str(rsvd_index)
        rsvd_index += 1
    
    #check dup bitfield
    for bf in reg.bf_list:
      for r in self.reg_list:
        for bfchk in r.bf_list:
          rchk = bf.name.lower()
          rchk_rsvd = rchk.startswith("reserved")
          if (bfchk.name.lower() == bf.name.lower()) and not (rchk_rsvd) :
          # Added this here since the DLA team is passing in one large DV.txt file and they have several bitfields in the same dv.txt file
            if not bypass_bf_chk:
              if (bfchk.name.lower() == bf.name.lower()):
                print("Error: Bitfield {0} in register {1} has been declared twice in reg block {2}! Please fix".format(bf.name, r.name, self.name))
                sys.exit(1)
      
    self.reg_list.append(reg)
    
  
  ################################################
  def add_prefix(self, prefix):
    """Adds a prefix to the name"""
    self.name = prefix.upper()+'_'+self.name
  
  
   ################################################
  def set_addrw(self, addrw):
    """Sets the addrw of this regblock"""
    self.addrw = addrw
  
  
  ################################################
  def update_regs_with_new_base(self, newbase):
    """Goes through each register and updates the address based on new base
       Value passed should be hex"""
    self.base_addr = newbase
    for r in self.reg_list:
      r.add_offset(newbase)
  
  ################################################
  def create_debug_bus(self):
    """Creates the debug bus for mux overrides if there are any mux signals"""
    
    if self.mux_list:
      num_dbg_regs = math.ceil(math.log(len(self.mux_list), 2))
      if num_dbg_regs == 0:
        num_dbg_regs = 1
      num_dbg_regs = int(num_dbg_regs)
      
      #print('dbg_regs '+str(num_dbg_regs))
      
      #Make the control register
      creg = wr.Register('DEBUG_BUS_CTRL', "'d"+str(len(self.reg_list*4)), desc="Debug observation bus selection for signals that have a mux override", rtype="RW")
      cbf  = curbf = wbf.Bitfield('DEBUG_BUS_CTRL_SEL', "0", "RW", (str(num_dbg_regs)+"'d0"), desc="Select signal for DEBUG_BUS_CTRL")
      creg.add_bf(cbf)      
      self.reg_list.append(creg)
      
      #Make the status register
      creg = wr.Register('DEBUG_BUS_STATUS', "'d"+str(len(self.reg_list*4)), desc="Debug observation bus for signals that have a mux override", rtype="RO")
      cbf  = curbf = wbf.Bitfield('DEBUG_BUS_CTRL_STATUS', "0", "RO", (str(32)+"'d0"), desc="Status output for DEBUG_BUS_STATUS")
      creg.add_bf(cbf)      
      self.reg_list.append(creg)
  
  ################################################
  def check_for_muxes(self):
    """Goes through the registers and looks for mux override registers.
       Start with each bit field and look for a corresponding bitfield with 
       <bf>_mux attached (doesn't have to be in the same register)"""
    
    for check_reg in self.reg_list:
      for check_bf in check_reg.bf_list:
        if not check_bf.name.endswith("_mux"):
          #Now check for a corresponding _mux signal and add to list
          for test_reg in self.reg_list:
            for test_bf in test_reg.bf_list:
              bfname = check_bf.name + "_mux"
              if bfname == test_bf.name:
                self.mux_list.append(check_bf)      #trying this with the whole bitfield for now
                check_bf.has_mux = 1

        
  ################################################
  def run_checks(self):
    
    for r in self.reg_list:
      r.check_width()
  

  ################################################  
  #  ___         _          _        
  # | _ \  _ _  (_)  _ _   | |_   ___
  # |  _/ | '_| | | | ' \  |  _| (_-<
  # |_|   |_|   |_| |_||_|  \__| /__/
  ################################################
    
  
  ################################################
  def print_uvm_reg_class(self, fh=None):
    """Goes through each register and prints the uvm_reg extension of the 
       reg_model"""
    
    fh.write("// RegBlock {0}\n".format(self.name))
    for r in self.reg_list:
      r.print_uvm_reg_class(prefix=self.name, fh=fh, mapname=self.mapname,mapaddr=self.mapaddr)
  
  ################################################
  def print_uvm_reg_model_top_register(self, fh=None):
    """Goes through each register and prints the class declaration of the 
       register in the reg_model that extends wav_reg_model"""
    
    fh.write("  //RegBlock {0}\n".format(self.name))
    for r in self.reg_list:
      fh.write('  rand {0:50} {1};\n'.format((self.name+r.name+'_'), (self.name+r.name)))
    fh.write('\n')
  
  ################################################
  def print_uvm_reg_no_reg_test(self, fh=None):
    """Prints out the noreg_test if applicable"""
    for r in self.reg_list:
      if r.notest:
        fh.write('  uvm_resource_db#(bit)::set(.scope("REG::*{0}"), .name("NO_REG_TESTS"), .val(1), .accessor(this));\n'.format((self.name+r.name)))
  
  ################################################
  def print_uvm_reg_model_create(self, fh=None):
    """Goes through each register and prints the creation portion of the reg_model
       and assigns to the MAP"""
    for r in self.reg_list:
      if r.notest:
        fh.write('    //THIS REG HAS BEEN DEFINED AS NO_REG_TEST\n')
      fh.write('    this.{0} = {1}::type_id::create("{2}");\n'.format(self.name+r.name, self.name+r.name+'_', self.name+r.name))
      fh.write('    this.{0}.build();\n'.format(self.name+r.name))
      fh.write('    this.{0}.configure(this);\n'.format(self.name+r.name))
      #remove the map base from the address
      addr_min_map = r.addr_dec - int(self.mapaddr, 16)
      addr_min_map = re.sub(r'0x', '', hex(addr_min_map))
      fh.write('    this.{0}.add_hdl_path_slice("{1}", {2}\'h{3}, 32);\n'.format(self.name+r.name, self.name+r.name, self.addrw, addr_min_map))
      fh.write('    {0}.add_reg({1}, {2}\'h{3}, "{4}");\n\n'.format(self.mapname, self.name+r.name, self.addrw, addr_min_map, r.get_reg_type()))
    
  ################################################
  def print_info(self, indent=''):
    print("{0}RegBlock : {1:20}  Base Name:{2:20} Map: {3:20} Map Base: {4}".format(indent, self.name, self.base_name, self.mapname, self.mapaddr))
    for r in self.reg_list:
      r.print_info(indent+'  ')

  
  ################################################
  def print_dv_file(self, p, b):
    """Prints the DV file to be used by the gen_uvm_reg_model flow"""
    
    dvfile = p + "_" + b + "_dv.txt"
    
    if dvfile:
      f = open(dvfile, 'w')
      print("Generating file -- {0}".format(dvfile))
    else:
      f = sys.stdout
      print("DV File will be printed to STDOUT since no file name passed")
    
    f.write("# <REG_NAME> <type RW|RO> <addr> <description>\n# <bit field> <size> <lsb location> <reset_val> <type(for RW/RO embed)> <description>\n")
    
    for r in self.reg_list:
      notest = '<NO_REG_TEST>' if r.notest else ''
        
      f.write("{0} {1} 'h{2} <DESC>{3}<\\DESC> {4}\n".format((p.upper()+"_"+b.upper()+"_"+r.name.upper()), r.rtype.upper(), r.addr_hex, r.desc, notest))
      for bf in reversed(r.bf_list):
        f.write("{0} {1} {2} {1}'h{3} {4} <DESC>{5}<\\DESC>\n".format(bf.name.upper(), bf.length, bf.lsb, bf.reset_hex, bf.type.upper(), bf.desc))
      f.write("\n")
  
  ################################################
  def print_ad_file(self, p, b, use_this_filename=None):
    """Prints the `defines DV file to be used by the gen_uvm_reg_model flow"""
    
    #Just in case you want to use a hard name (DV files or soemthing)
    if(use_this_filename):
      dvfile = use_this_filename
    else:
      dvfile = p + "_" + b + "_addr_defines.vh"
      
    if dvfile:
      f = open(dvfile, 'w')
      print("Generating file -- {0}".format(dvfile))
    else:
      f = sys.stdout
      print("addr_defines DV File will be printed to STDOUT since no file name passed")
    
    head = wp.print_verilog_c_script_header(dvfile)
    f.write(head)
    
    #if not passing a prefix/block, then ignore this
    if(use_this_filename):
      reg_base = ""
    else:
      reg_base = p+"_"+b+"_"
    
    for r in self.reg_list:
      reset_total = 0
      addr_padded = r.addr_hex.upper().zfill(8)
      f.write("`define {0:60} {1:>20}\n".format((reg_base+r.name).upper(), "'h"+addr_padded)) #extra format for 8 char hex
      for bf in reversed(r.bf_list):
        if bf.length > 1:
          bindex = "{0}:{1}".format(str(int(bf.lsb) + int(bf.length) - 1), bf.lsb)
        else:
          bindex = str(bf.lsb)
        f.write("`define {0:60} {1:>20}\n".format((reg_base+r.name+"__"+bf.name).upper(), bindex))
        reset_total += (bf.reset_dec * (2**int(bf.lsb)))
      
      reset_total = format(reset_total, 'X').zfill(8)
      f.write("`define {0:60} {1:>20}\n".format((reg_base+r.name+"___POR").upper(), "32'h"+reset_total)) 
      
      f.write("\n")
  
  ################################################
  def print_ch_file(self, fh=None):
    """Prints the C header file. If a filehandle is passed, it will concatenate to
       that file, else it will create a file using the prefix and block similar to
       the old gen_regs method"""
    
    
    if not fh:
      chf = self.base_name.lower() + "_c_defines.h"
      f = open(chf, 'w')
      print("Generating file -- {0}".format(chf))
      head = wp.print_verilog_c_script_header(chf)
      f.write(head)
    else:
      f = fh
     
    
    f.write('// C Headers for {0}\n'.format(self.base_name.lower()))
    f.write('// Base Address : 0x{0}\n'.format(self.base_addr))
    for r in self.reg_list:
      addr_padded = r.addr_hex.upper().zfill(16)
      addr_lo     = int(r.addr_hex, 16) & 4294967295
      addr_lo     = format(addr_lo, 'x').zfill(16)
      addr_hi     = (int(r.addr_hex, 16) & (4294967295<<32)) >> 32
      addr_hi     = format(addr_hi, 'x').zfill(16)
      f.write('#define {0:100} 0x{1:20}    //Address\n'.format(self.name + r.name.upper(), addr_padded))
      f.write('#define {0:100} 0x{1:20}    //Address Lower 32bits\n'.format(self.name + r.name.upper() +'__LO', addr_lo))
      f.write('#define {0:100} 0x{1:20}    //Address Upper 32bits\n'.format(self.name + r.name.upper() +'__HI', addr_hi))
      for bf in r.bf_list:
        #Mask
        bfmask = 0
        bitcount = int(bf.lsb)
        while bitcount < (int(bf.length) + int(bf.lsb)):
          bfmask += 2**bitcount
          bitcount += 1
        bfmask = '0x' + format(bfmask, 'x').zfill(8)
        f.write('#define {0:100} {1:20}      //Desc : {2}\n'.format(self.name + r.name.upper() + '__' + bf.name.upper() + '__MASK', bfmask, bf.desc))
        
        f.write('#define {0:100} {1:20}      //Reset: {2}{3}\n'.format(self.name + r.name.upper() + '__' + bf.name.upper() + '__SHIFT', bf.lsb, bf.length, bf.get_reset_hex_verilog()))
      
      f.write('\n')
    f.write('\n')
    
  ################################################
  def print_verilog(self, p, b, ahb=False, vfile=None):
    """Prints the verilog file with the actual RTL"""
    
    #This will hold the LAST BSCAN register/bitfield so 
    #we have a pointer to the last one in the chain. It will always connect these in
    #order, but we don't want to traverse through it in reverse
    last_bscan_bf = None
    last_tdo_name = None
    
    vfile = p + "_" + b + "_regs_top.v"
    
    if vfile:
      #with open(vfile, 'w') as f:
      f = open(vfile, 'w')
      print("Generating file -- {0}".format(vfile))
    else:
      f = sys.stdout
      print("RTL will be printed to STDOUT since no file name passed")
    
    head = wp.print_verilog_c_script_header(vfile)
    f.write(head)
    
    #Module Header
    self.addr_width = math.ceil(math.log(len(self.reg_list), 2))
    if self.addr_width < 8:
      self.addr_width = 8
      
    f.write("module {0}_{1}_regs_top #(\n".format(p,b))
    #Params for any bitfields that have a PARAM
    for r in self.reg_list:
      for bf in r.bf_list:
        if bf.reset_is_param:
          f.write("  parameter    {0}_RESET_PARAM = {1}'h{2},\n".format(bf.name.upper(), bf.length, str(bf.reset_hex)))
    f.write("  parameter    ADDR_WIDTH = {0}\n".format(self.addr_width))
    #f.write("  parameter    STDCELL    = 1\n")
    f.write(")(\n")
    
    #Ports
    need_iddq_port = False
    need_hiz_port  = False
    need_bscan_port= False
    need_bscan_intf= False
    need_scan_port = False
    for r in self.reg_list:
      #Skip the auto inserted debug
      if r.name == "DEBUG_BUS_CTRL" or r.name == "DEBUG_BUS_STATUS":
        continue
      
      f.write("  //{0}\n".format(r.name))      
      for bf in r.bf_list:
        bf_width = ""
        if bf.length > 1:
          bf_width = "[{0}:0] ".format(bf.length-1)
        
        if bf.has_dft:
          if bf.iddq:  need_iddq_port  = True
          if bf.hiz:   need_hiz_port   = True
          if bf.bscan: need_bscan_port = True
          if bf.bsflop:need_bscan_intf = True #Only if bFLOPs are used
          if bf.core_scan: need_scan_port = True
          if bf.dftall:
            need_iddq_port  = True
            need_hiz_port   = True
            need_bscan_port = True
            need_scan_port  = True
        
        #RO input
        if bf.type == "RO" and bf.rsvd == 0:
          f.write("  input  wire {0:7} {1},\n".format(bf_width, bf.name.lower()))
        
        #RO input
        elif bf.type == "RO" and bf.rsvd == 1:
          pass # Do nothing
            
        #RW output, no mux
        elif bf.type == "RW" and bf.has_mux == 0:
          #Skip the mux ones
          if not bf.name.endswith("_mux"):
            f.write("  output wire {0:7} swi_{1},\n".format(bf_width, bf.name.lower()))
        
        #RW with mux
        elif bf.type == "RW" and bf.has_mux == 1:
          #Core side input and _muxed output
          f.write("  input  wire {0:7} {1},\n".format(bf_width, bf.name.lower()))
          f.write("  output wire {0:7} swi_{1}_muxed,\n".format(bf_width, bf.name.lower()))
        
        elif bf.type == "W1C":
          f.write("  input  wire {0:7} w1c_in_{1},\n".format(bf_width, bf.name.lower()))
          f.write("  output wire {0:7} w1c_out_{1},\n".format(bf_width, bf.name.lower()))
        
        elif bf.type == "WFIFO":
          f.write("  output wire {0:7} wfifo_{1},\n".format(bf_width, bf.name.lower()))
          f.write("  output wire {0:7} wfifo_winc_{1},\n".format("", bf.name.lower()))
        
        elif bf.type == "RFIFO":
          f.write("  input  wire {0:7} rfifo_{1},\n".format(bf_width, bf.name.lower()))
          f.write("  output wire {0:7} rfifo_rinc_{1},\n".format("", bf.name.lower()))
        
        else:
          print("------Some error with this bf: {0}".format(bf.name))
    
    
    dft_ports   = '\n  //DFT Ports (if used)\n'
    dft_tieoffs = '  //DFT Tieoffs (if not used)\n'
    if need_scan_port:  dft_ports   += '  input  wire dft_core_scan_mode,\n'
    else:               dft_tieoffs += "  wire dft_core_scan_mode = 1'b0;\n"
    if need_iddq_port:  dft_ports   += '  input  wire dft_iddq_mode,\n'
    else:               dft_tieoffs += "  wire dft_iddq_mode = 1'b0;\n"
    if need_hiz_port:   dft_ports   += '  input  wire dft_hiz_mode,\n'
    else:               dft_tieoffs += "  wire dft_hiz_mode = 1'b0;\n"
    #Possible to have BSCAN control without BSCAN Flops
    if need_bscan_port or need_bscan_intf: 
      dft_ports   += '  input  wire dft_bscan_mode,\n'
    else:               
      dft_tieoffs += "  wire dft_bscan_mode = 1'b0;\n"
    
    
    
    #Only if FLOPs are used
    if need_bscan_intf:
      dft_ports   += '  // BSCAN Shift Interface\n'
      #dft_ports   += '  //input  wire dft_bscan_tck,\n'
      #dft_ports   += '  //input  wire dft_bscan_trstn,\n'
      dft_ports   += '  input  wire dft_bscan_clockdr,\n'
      dft_ports   += '  input  wire dft_bscan_shiftdr,\n'
      dft_ports   += '  input  wire dft_bscan_updatedr,\n'
      dft_ports   += '  input  wire dft_bscan_tdi,\n'
      dft_ports   += '  output wire dft_bscan_tdo,     //Assigned to last in chain\n'
    
    f.write(dft_ports);
    
    #APB interface
    #Adding AHB. Yes I'm just using the apb_sigs variable for both, bite me
    if not ahb:
      ################
      # APB
      ################
      apb_sigs = """  
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
  
"""
    else:
      ################
      # AHB
      ################
      apb_sigs = """
    // AHB Interface
  input  wire RegReset,
  input  wire RegClk,
  input  wire                     hsel,
  input  wire                     hwrite,
  input  wire [1:0]               htrans,
  input  wire [2:0]               hsize,    //not really supporting
  input  wire [2:0]               hburst,   //not really supporting
  input  wire [(ADDR_WIDTH-1):0]  haddr,
  input  wire [31:0]              hwdata,
  output wire [31:0]              hrdata,
  output wire [1:0]               hresp,
  output wire                     hready
);
  
"""
    
    f.write(apb_sigs)
    f.write(dft_tieoffs)
    
    if not ahb:
      ################
      # APB
      ################
      apb_sigs = """
  //APB Setup/Access 
  wire [(ADDR_WIDTH-1):0] RegAddr_in;
  reg  [(ADDR_WIDTH-1):0] RegAddr;
  wire [31:0] RegWrData_in;
  reg  [31:0] RegWrData;
  wire RegWrEn_in;
  reg  RegWrEn_pq;
  wire RegWrEn;

  assign RegAddr_in = PSEL ? PADDR : RegAddr; 

  always @(posedge RegClk or posedge RegReset) begin
    if (RegReset) begin
      RegAddr <= {(ADDR_WIDTH){1'b0}};
    end else begin
      RegAddr <= RegAddr_in;
    end
  end

  assign RegWrData_in = PSEL ? PWDATA : RegWrData; 

  always @(posedge RegClk or posedge RegReset) begin
    if (RegReset) begin
      RegWrData <= 32'h00000000;
    end else begin
      RegWrData <= RegWrData_in;
    end
  end

  assign RegWrEn_in = PSEL & PWRITE;

  always @(posedge RegClk or posedge RegReset) begin
    if (RegReset) begin
      RegWrEn_pq <= 1'b0;
    end else begin
      RegWrEn_pq <= RegWrEn_in;
    end
  end

  assign RegWrEn = RegWrEn_pq & PENABLE;
  
  //assign PSLVERR = 1'b0;
  assign PREADY  = 1'b1;
  
"""
    else:
      ################
      # AHB
      ################
      apb_sigs = """
  //AHB Setup/Access 
  wire [(ADDR_WIDTH-1):0] RegAddr_in;
  reg  [(ADDR_WIDTH-1):0] RegAddr;
  wire [31:0] RegWrData_in;
  //reg  [31:0] RegWrData;
  wire [31:0] RegWrData;
  wire RegWrEn_in;
  reg  RegWrEn;
  wire RegRdEn_in;
  reg  RegRdEn;
  
  wire htrans_valid;
  
  assign htrans_valid = (htrans == 2'b11) || (htrans == 2'b10);

  assign RegAddr_in =            hsel && htrans_valid ? haddr : RegAddr; 
  assign RegWrEn_in = hwrite  && hsel && htrans_valid;
  assign RegRdEn_in = ~hwrite && hsel && htrans_valid;

  always @(posedge RegClk or posedge RegReset) begin
    if (RegReset) begin
      RegAddr   <= {(ADDR_WIDTH){1'b0}};
      RegWrEn   <= 1'b0;
      RegRdEn   <= 1'b0;
      //RegWrData <= 32'h00000000;
    end else begin
      RegAddr   <= RegAddr_in;
      RegWrEn   <= RegWrEn_in;
      RegRdEn   <= RegRdEn_in;
      //RegWrData <= hwdata;
    end
  end
  
  assign RegWrData = hwdata;

  //We are always ready to accept data
  assign hready  = 1'b1;
  
"""

    f.write(apb_sigs);
    
    
    #Initial for muxes
    f.write("\n\n  //Regs for Mux Override sel\n")
    for r in self.reg_list:
      for bf in r.bf_list:
        if bf.type == "RW" and bf.has_mux == 1:
          f.write("  reg  reg_{0}_mux;\n".format(bf.name.lower()))
    
    ##############################
    # Start each register block
    ##############################
    for r in self.reg_list:
      #print(r.name)
      f.write("\n\n\n  //---------------------------\n  // {0}\n".format(r.name))
      for bf in r.bf_list:
        f.write("  // {0} - {1}\n".format(bf.name, bf.desc))
      f.write("  //---------------------------\n")
      f.write("  wire [31:0] {0}_reg_read;\n".format(r.name))
            
      for bf in r.bf_list:
        bf_width = ""
        if bf.length > 1:
          bf_width = "[{0}:0] ".format(bf.length-1)
        
        #RW reg
        if bf.type == "RW" and bf.has_mux == 0:
          #Skip the mux ones
          if not bf.name.endswith("_mux"):
            f.write("  reg {0:7} reg_{1};\n".format(bf_width, bf.name.lower()))
          
          #Take care of internal wire
          if r.name == "DEBUG_BUS_CTRL" and bf.type == "RW":
            f.write("  wire {0:7} swi_{1};\n".format(bf_width, bf.name.lower()))
        
        #RW with mux
        elif bf.type == "RW" and bf.has_mux == 1:
          f.write("  reg  {0:7} reg_{1};\n".format(bf_width, bf.name.lower()))
      
        elif bf.type == "W1C":
          f.write("  reg  {0:7} reg_w1c_{1};\n".format(bf_width, bf.name.lower()))
          f.write("  wire {0:7} reg_w1c_in_{1}_ff2;\n".format(bf_width, bf.name.lower()))
          f.write("  reg  {0:7} reg_w1c_in_{1}_ff3;\n".format(bf_width, bf.name.lower()))
        
        elif bf.type == "WFIFO":
          if bf.length > 1:
            wdata_index = "[{0}:{1}]".format(str(int(bf.lsb)+int(bf.length)-1), str(bf.lsb))
          else:
            wdata_index = "[{0}]".format(str(bf.lsb))
          f.write("\n")
          f.write("  assign wfifo_{0}      = (RegAddr == 'h{1} && RegWrEn) ? RegWrData{2} : 'd0;\n".format(bf.name.lower(), r.addr_hex, wdata_index))
          f.write("  assign wfifo_winc_{0} = (RegAddr == 'h{1} && RegWrEn);\n".format(bf.name.lower(), r.addr_hex))
        
        elif bf.type == "RFIFO":
          f.write("\n")
          f.write("  assign rfifo_rinc_{0} = (RegAddr == 'h{1} && PENABLE && PSEL && ~(PWRITE || RegWrEn));\n".format(bf.name.lower(), r.addr_hex))
          
        #Special debug bus so just write wire and set the debug bus logic
        elif r.name == "DEBUG_BUS_STATUS" and bf.type == "RO":
          f.write("  reg  {0:7} {1};\n".format(bf_width, bf.name.lower()))
          self.print_debugbus(f)
        
        
      
      ##############################
      #Actual Register design
      #Check if all are RO and skipp if so
      ##############################
      all_are_ro = 1
      atleast_1_rw = 0
      for bf in r.bf_list:
        if bf.type != "RO" and bf.type != "WFIFO" and bf.type != "RFIFO":
          all_are_ro = 0
          if bf.type == "RW":
            atleast_1_rw = 1
      
      if all_are_ro == 0:
        if atleast_1_rw:
          f.write("\n  always @(posedge RegClk or posedge RegReset) begin\n")
          f.write("    if(RegReset) begin\n")
          #Reset
          for bf in r.bf_list:
            #RW reg
            if bf.type == "RW":
              if bf.reset_is_param:
                f.write("      reg_{0:34} <= {1}_RESET_PARAM;\n".format(bf.name.lower(),bf.name.upper()))
              else:
                f.write("      reg_{0:34} <= {1}'h{2};\n".format(bf.name.lower(), bf.length, bf.reset_hex))


          f.write("    end else if(RegAddr == 'h{0} && RegWrEn) begin\n".format(r.addr_hex))
          #Write
          for bf in r.bf_list:
            if bf.length > 1:
              wdata_index = "[{0}:{1}]".format(str(int(bf.lsb)+int(bf.length)-1), str(bf.lsb))
            else:
              wdata_index = "[{0}]".format(str(bf.lsb))

            #RW reg
            if bf.type == "RW":
              f.write("      reg_{0:34} <= RegWrData{1};\n".format(bf.name.lower(), wdata_index))
          
          #Default
          f.write("    end else begin\n".format(r.addr_hex))
          for bf in r.bf_list:
            if bf.type == "RW":
              f.write("      reg_{0:34} <= reg_{0};\n".format(bf.name.lower()))
          
          f.write("    end\n  end\n\n")
        
        ######################
        #W1C logic
        ######################
        for bf in r.bf_list:
            
          if bf.type == "W1C":
            #register portions
            f.write("\n  // {0} W1C Logic\n".format(bf.name.lower()))
            f.write("  always @(posedge RegClk or posedge RegReset) begin\n")
            f.write("    if(RegReset) begin\n")
            f.write("      reg_w1c_{0:33} <= {1}'h{2};\n".format(bf.name.lower(), bf.length, bf.reset_hex))
            f.write("      reg_w1c_in_{0:30} <= {1}'h{2};\n".format((bf.name.lower()+"_ff3"), bf.length, bf.reset_hex))
            f.write("    end else begin\n")
            f.write("      reg_w1c_{0:33} <= RegWrData[{1}] && reg_w1c_{0} && (RegAddr == 'h{2}) && RegWrEn ? 1'b0 : (reg_w1c_in_{0}_ff2 & ~reg_w1c_in_{0}_ff3 ? 1'b1 : reg_w1c_{0});\n".format(bf.name.lower(), bf.lsb, r.addr_hex))  #can only be one bit
            f.write("      reg_w1c_in_{0:30} <= reg_w1c_in_{1};\n".format((bf.name.lower()+"_ff3"), (bf.name.lower()+"_ff2")))
            f.write("    end\n  end\n")
            
            #Demet and rising edge logic
            demet_rise_logic = """
  demet_reset u_demet_reset_{0} (
    .clk     ( {2:30}             ),              
    .reset   ( {3:30}             ),              
    .sig_in  ( w1c_in_{0:30}      ),            
    .sig_out ( reg_w1c_in_{1:30}  )); 

""".format(bf.name.lower(), (bf.name.lower()+"_ff2"), "RegClk", "RegReset")
            f.write(demet_rise_logic)
      
      ##############################
      #Final Assign per reg
      ##############################
      leftover = 32
      for bf in r.bf_list:
        leftover = leftover - bf.length
      
      f.write("  assign {0}_reg_read = {1}".format(r.name, '{'))
      if leftover > 0:
        f.write("{0}'h0,\n".format(str(leftover)))
      
      index = 0
      
      for bf in reversed(r.bf_list):      #this should be in order based on this flow
        if index == len(r.bf_list) - 1:
          endofline = "};"
        else:
          endofline = ","
         
        #tie off reserved 
        if bf.rsvd or bf.type == "WFIFO":
          f.write("          {0}'d0{1} //Reserved\n".format(bf.length, endofline))
        
        #This is just the register value
        elif bf.type == "RW":
          f.write("          reg_{0}{1}\n".format(bf.name.lower(), endofline))
        
        elif bf.type == "W1C":
          f.write("          reg_w1c_{0}{1}\n".format(bf.name.lower(), endofline))
        
        #This is just the input
        elif bf.type == "RO":
          f.write("          {0}{1}\n".format(bf.name.lower(), endofline))
        elif bf.type == "RFIFO":
          f.write("          rfifo_{0}{1}\n".format(bf.name.lower(), endofline))
        
        index = index + 1
      
      f.write("\n")
      #RW Reg assignments
      (last_bscan_bf_chk, last_tdo_name_chk) = r.print_rtl_assign_logic(f, last_bscan_bf, pre=p, block=b)
      if last_tdo_name_chk:
        last_tdo_name = last_tdo_name_chk
      if last_bscan_bf_chk:
        last_bscan_bf = last_bscan_bf_chk
        
      f.write("\n")      
      
    #PRDATA mux
    
    #check for last bscan connection
    #If no BSCAN flops, then this should be None
    if last_tdo_name:
      f.write("  //=======================\n")
      f.write("  // Final BSCAN Connection\n")
      f.write("  //=======================\n")
      f.write("  assign dft_bscan_tdo = {0};\n\n".format(last_tdo_name))
    
    
    if not ahb:
      ################
      # APB
      ################
      prdata_str = """
  
    
  //---------------------------
  // PRDATA Selection
  //---------------------------
  reg [31:0] prdata_sel;
  
  always @(*) begin
    case(RegAddr)
"""
      f.write(prdata_str)
      for r in self.reg_list:
        f.write("      'h{0:4} : prdata_sel = {1}_reg_read;\n".format(r.addr_hex, r.name))
    
      prdata_str = """
      default : prdata_sel = 32'd0;
    endcase
  end
  
  assign PRDATA = prdata_sel;

"""
    
    else:
      ################
      # AHB
      ################
      prdata_str = """
  
    
  //---------------------------
  // PRDATA Selection
  //---------------------------
  reg [31:0] prdata_sel;
  
  always @(*) begin
    if(RegRdEn) begin
      case(RegAddr)
"""
    
      f.write(prdata_str)
      for r in self.reg_list:
        f.write("       'h{0:4} : prdata_sel = {1}_reg_read;\n".format(r.addr_hex, r.name))
    
      prdata_str = """
        default : prdata_sel = 32'd0;
      endcase
    end else begin
      prdata_sel = 32'd0;
    end
  end
    
  
  assign hrdata = prdata_sel;

"""

    f.write(prdata_str)
    
    #RSLVERR response (hey! yea actually supporting this now!)
    if not ahb:
      ################
      # APB
      ################
      prdata_str = """
  
    
  //---------------------------
  // PSLVERR Detection
  //---------------------------
  reg pslverr_pre;
  
  always @(*) begin
    case(RegAddr)
"""
      f.write(prdata_str)
      for r in self.reg_list:
        f.write("      'h{0:4} : pslverr_pre = 1'b0;\n".format(r.addr_hex))
    
      prdata_str = """
      default : pslverr_pre = 1'b1;
    endcase
  end
  
  assign PSLVERR = pslverr_pre;

"""
    else:
      ################
      # AHB
      ################
      prdata_str = """
  
    
  //---------------------------
  // PSLVERR Detection
  //---------------------------
  reg pslverr_pre;
  
  always @(*) begin
    if(RegWrEn || RegRdEn) begin
      case(RegAddr)
"""
      f.write(prdata_str)
      for r in self.reg_list:
        f.write("       'h{0:4} : pslverr_pre = 1'b0;\n".format(r.addr_hex))
    
      prdata_str = """
        default : pslverr_pre = 1'b1;
      endcase
    end else begin
      pslverr_pre = 1'b0;
    end
  end
  
  assign hresp = pslverr_pre ? 2'b01 : 2'b00;

"""
    f.write(prdata_str)
    
    # Debugging Stuff

  
    ################################
    # For BSCAN we want to give some debugging features to capture reg writes
    # so they can be fed back for JTAG testing
    ################################
    if(need_bscan_intf):
      bscan_dbg_str = """
  `ifdef SIMULATION
  
  reg [8*200:1] file_name;
  integer       file;
  initial begin
    if ($value$plusargs("{0}_{1}_BSR_MONITOR=%s", file_name)) begin
      file = $fopen(file_name, "w");
      $display("Starting {0}_{1}_BSR_MONITOR with file: %s", file_name);
      forever begin
        @(posedge RegClk);
        if(RegWrEn) begin
          @(posedge RegClk);  //Wait 1 clock cycle for update
          $fwrite(file, "#Update @ %t\\n", $realtime);
""".format(p.upper(), b.upper())

      f.write(bscan_dbg_str)
      
      jtag_index = 0
      for r in self.reg_list:
        for bf in r.bf_list:
          if bf.bsflop and (bf.type == "RW"): #Only dealing with RW for now
            if bf.length > 1:
              for i in range(bf.length):
                f.write('          $fwrite(file, "%1b // jtag_chain{2} {0}[{1}]\\n", reg_{0}[{1}]);\n'.format(bf.name, i, jtag_index))
                jtag_index += 1
            else:
              f.write('          $fwrite(file, "%1b // jtag_chain{1} {0}\\n", reg_{0});\n'.format(bf.name, jtag_index))
              jtag_index += 1
            
      bscan_dbg_str = """ 
        end
      end
    end  
  end
  `endif
endmodule

"""
      f.write(bscan_dbg_str)
      
    else:
      f.write("endmodule\n")
  
    
    if(need_bscan_intf):
      jtag_bsr="""
      
//JTAG BSR Flop
module {0}_{1}_jtag_bsr(
  input  wire bscan_mode,
  input  wire clockdr,      
  input  wire shiftdr,
  input  wire updatedr,
  input  wire pi,
  output wire po,
  input  wire tdi,
  output wire tdo
);


reg   capture;
wire  capture_in;
reg   update;


wav_clock_mux u_wav_clock_mux_capture_in (
    .clk0    ( pi         ),              
    .clk1    ( tdi        ),              
    .sel     ( shiftdr    ),      
    .clk_out ( capture_in )); 
    
    
always @(posedge clockdr) begin
  capture <= capture_in;
end

always @(posedge updatedr) begin
  update <= capture;
end

assign tdo = capture;

wav_clock_mux u_wav_clock_mux_po (
    .clk0    ( pi         ),              
    .clk1    ( update     ),              
    .sel     ( bscan_mode ),      
    .clk_out ( po         )); 


endmodule
""".format(p, b)
      f.write(jtag_bsr)
    
  
  ################################################
  def print_debugbus(self, f):
    """Called when we get to the debug bus status register"""
    dbb_str = """
  //Debug bus control logic  
  always @(*) begin
    case(swi_debug_bus_ctrl_sel)
"""
    f.write(dbb_str)    
    
    index = 0
    for mux_bf in self.mux_list:
      if mux_bf.length == 32:
        leftover = "{"
      else:
        leftover = "{0}'d0, ".format(32-mux_bf.length)
        leftover = "{"+leftover
      
      f.write("      {0:3} : debug_bus_ctrl_status = {1}swi_{2}_muxed{3};\n".format(("'d"+str(index)), leftover, mux_bf.name.lower(), "}"))
      index += 1
    
    dbb_str = """      default : debug_bus_ctrl_status = 32'd0;
    endcase
  end 
  
"""
    f.write(dbb_str)  
  
  ################################################
  def gen_sphinx_table(self):
    """Returns a Markdown string to be used in Sphinx docs"""
    title   =  "{0} Registers".format(self.base_name)
    mah_str =  "{0}\n".format(title)
    mah_str += "{0}\n".format(len(title) * '=')

    
    for r in self.reg_list:
      name_size   = len("Name ")
      index_size  = 8
      type_size   = 8
      reset_size  = 10
      desc_size   = len("Description ")
      
      for bf in r.bf_list:
        if(len(bf.name) > name_size): name_size = len(bf.name)
        if(len(bf.desc) > desc_size): desc_size = len(bf.desc)
        
      
      reg = "{0}".format(r.name)
      mah_str += "{0}\n{1}\n\n".format(reg, "-"*len(reg))
      addr = "Address: {0}".format(r.get_addr_str())
      mah_str += "{0}\n\n".format(addr)
      mah_str += "Description: {0}\n\n".format(r.desc)
      mah_str += ".. table::\n"
      mah_str += "  :widths: 25 10 10 10 50\n\n"
      mah_str += "  {0} {1} {2} {3} {4}\n".format('='*name_size, '='*index_size, '='*type_size, '='*reset_size, '='*desc_size)
      mah_str += "  %-*s %-*s %-*s %-*s %-*s\n" % (name_size, "Name", index_size, "Index", type_size, "Type", reset_size, "Reset", desc_size, "Description")
      mah_str += "  {0} {1} {2} {3} {4}\n".format('='*name_size, '='*index_size, '='*type_size, '='*reset_size, '='*desc_size)
      
      for bf in r.bf_list:
        mah_str += "  %-*s %-*s %-*s %-*s %-*s\n" % (name_size, bf.name.upper(), index_size, bf.get_index_str(), type_size, bf.type, reset_size, bf.get_reset_hex(), desc_size, bf.desc)
      
      mah_str += "  {0} {1} {2} {3} {4}\n".format('='*name_size, '='*index_size, '='*type_size, '='*reset_size, '='*desc_size)
      mah_str += "\n\n"  
    
    print(mah_str)
  
#  ################################################
#  def create_pdf(self, pdf):
#    """Creates the PDF file for the reg block"""
#    
#    styles=getSampleStyleSheet()
#    
#    line = wp.WavPDFLine()
#    pdf.Story.append(line)
#    pdf.Story.append(Spacer(1, 2))
#    bla = "<b>Register Block:</b> {0}{1}".format(self.name, self.base_name)
#    #pdf.Story.append(Paragraph(wp.wrap_font(bla, '14'), styles["Normal"]))
#    pdf.Story.append(Paragraph(wp.wrap_font(bla, '14'), pdf.head2))
#    pdf.Story.append(Spacer(1, 2))
#    bla = "<b>Base Address  :</b> {0}".format(self.reg_list[0].addr_hex)#self.base_addr)
#    pdf.Story.append(Paragraph(wp.wrap_font(bla, '14'), styles["Normal"]))
#    pdf.Story.append(Spacer(1, 5))
#    pdf.Story.append(line)
#    pdf.Story.append(Spacer(1, 10))
#    
#    
#    for r in self.reg_list:
#      table_data = []
#      table_head = [Paragraph(wp.wrap_font(wp.wrap_bold('Bitfield Name'), '8'), styles['Normal']), 
#                    Paragraph(wp.wrap_font(wp.wrap_bold('Index'), '8'), styles['Normal']), 
#                    Paragraph(wp.wrap_font(wp.wrap_bold('Reset Value'), '8'), styles['Normal']), 
#                    Paragraph(wp.wrap_font(wp.wrap_bold('Type'), '8'), styles['Normal']), 
#                    Paragraph(wp.wrap_font(wp.wrap_bold("Description"), '8'), styles['Normal'])]
#      table_data.append(table_head)
#      
#      if r.desc == '':
#        rdesc = "No description given"
#      else:
#        rdesc = r.desc
#      #pdf.Story.append(Paragraph(wp.wrap_font("<b>"+r.name+"</b>", '12'), styles["Normal"]))
#      pdf.Story.append(Paragraph(wp.wrap_font("<b>"+r.name+"</b>", '12'), pdf.head3))
#      pdf.Story.append(Spacer(1, 2))
#      pdf.Story.append(Paragraph("Address: 0x{0}".format(r.addr_hex), styles["Normal"]))
#      pdf.Story.append(Paragraph("Description: {0}".format(rdesc), styles["Normal"]))
#      
#      #Base TableStyle, we will use add command to add for bitfield types
#      ts = TableStyle([('GRID',           (0,0), (-1,-1), 0.5,  colors.black),         #ALL Cells
#                       ('BACKGROUND',     (0,0), (-1,0),        colors.lightgrey),     #Top Row
#                       ('TOPPADDING',     (0,0), (-1,-1),       1),
#                       ('BOTTOMPADDING',  (0,0), (-1,-1),       1),
#                       ('RIGHTPADDING',   (0,0), (-1,-1),       3),
#                       ('LEFTPADDING',    (0,0), (-1,-1),       3),
#                       ('VALIGN',         (0,0), (-2,-1),       'MIDDLE')])            # Left most coloumn
#      #Start at 1 since header is 0
#      index = 1
#      
#      for bf in r.bf_list:
#        #bf_data = [bf.name, bf.get_index_str(), "{0}'h{1}".format(bf.length, bf.reset_hex), bf.type, bf.desc]
#        #Paragraph is used to help with word wrap
#        if bf.type == 'WFIFO':
#          bf_type_fifo_fix = 'WFIFO(WO)'
#        elif bf.type == 'RFIFO':
#          bf_type_fifo_fix = 'RFIFO(RO)'
#        else:
#          bf_type_fifo_fix = bf.type
#        
#        bf_data = [Paragraph(wp.wrap_font(bf.name, '7'), styles['Normal']), 
#                   Paragraph(wp.wrap_font(bf.get_index_str(), '8'), styles['Normal']), 
#                   Paragraph(wp.wrap_font("{0}'h{1}".format(bf.length, bf.reset_hex), '8'), styles['Normal']), 
#                   Paragraph(wp.wrap_font(bf_type_fifo_fix, '8'), styles['Normal']), 
#                   Paragraph(wp.wrap_font(bf.desc, '7'), styles['Normal'])]
#        table_data.append(bf_data)
#        
#        #Colors because I like em
#        if bf.type == 'RW':
#          ts.add('BACKGROUND', (3,index), (3,index),       self.RW_color)
#        elif bf.type == 'RO' or bf.type == 'RFIFO':
#          ts.add('BACKGROUND', (3,index), (3,index),       self.RO_color)
#        elif bf.type == 'W1C':
#          ts.add('BACKGROUND', (3,index), (3,index),       self.W1C_color)
#        elif bf.type == 'WO' or bf.type == 'WFIFO':
#          ts.add('BACKGROUND', (3,index), (3,index),       self.WO_color)
#        
#        index+=1
#      
#      
#        
#      t=Table(table_data, colWidths=[145,45,60,60,230])
#      t.setStyle(ts)
#                                   
#      pdf.Story.append(t)
#      pdf.Story.append(Spacer(1, 14))
#    
#    #Add PageBreak at the end
#    pdf.Story.append(PageBreak())
  

