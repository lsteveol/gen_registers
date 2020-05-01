"""
wav_reg_system.py
~~~~~~~~~~

A module to implement a collection of register blocks.
This is used to describe an SoC, subsystem, or portion
of a subsystem. Basically any collection of register blocks
consitutes a reg_system


rb_list is a dictionary of RegBlocks/RegSystems
The {key : val} pair is:
  key = Address in HEX (Stored as an INT)
  val = RegBlock/RegSystem Class


"""
import wav_reg_block as wrb
from collections import OrderedDict
import wav_print as wp
import sys
import re


#For PDF Gen
#from reportlab.lib.enums import TA_JUSTIFY
#from reportlab.lib.pagesizes import letter
#from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Image, Table, TableStyle, PageBreak
#from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
#from reportlab.lib.units import inch
#from reportlab.lib import colors

class RegSystem():
  
  def __init__(self, base_addr="'d0", name=''):
    self.name     = name
    self.set_base_addr(str(base_addr))
    self.rb_list  = OrderedDict()
  
    self.map_dict = OrderedDict()
    
    self.addrw    = '32'
    
  
  ################################################
  def set_base_addr(self, addr):
    """Converts the address based on the radix"""
    
    #### BINARY
    if "'b" in addr:
      s = addr.split("'b");
      if len(s) != 2:
        self.print_addr_invalid(addr)
      v = int(s[1], 2)
      
    #### HEX
    elif "'h" in addr:
      s = addr.split("'h");
      if len(s) != 2:
        self.print_addr_invalid(addr)
      v = int(s[1], 16)
      
    #### Decimal
    elif "'d" in addr:
      s = addr.split("'d");
      if len(s) != 2:
        self.print_addr_invalid(addr)
      v = int(s[1])   
    
    #### 0x nomenclature, we will treat
    elif "0x" in addr:
      s = addr.split("0x");
      v = int(s[1], 16) 
    
    else:
      self.print_addr_invalid()
  
    self.addr_dec = v
    self.addr_hex = format(self.addr_dec, 'x')
    
  ################################################
  def get_base_addr_str(self):
    return hex(self.addr_dec)
  
  ################################################
  def add_global_prefix(self, prefix):
    """Adds a prefix to the name"""
    self.name = prefix.upper()+'_'+self.name
    for key in self.rb_list:
      if isinstance(self.rb_list[key], wrb.RegBlock):
        self.rb_list[key].add_prefix(prefix)
      else:
        self.rb_list[key].add_global_prefix(prefix)
  
  
  ################################################
  def print_addr_invalid(self, s):
    print("Error: Address format %s is invalid. Use Verilog Type Radix for addressing" % s)
  
  
  ################################################
  def add_reg_block(self, key, rb):
    """Adds a RegBlock to the System. The Key is the address of the regblock
       RELATIVE to the BASE ADDR"""
       
    if key in self.rb_list:
      print("Error: Address %s is already defined for another RegBlock: %s!" % (str(key), rb.name))
      print("       Please Resolve. Exiting....")
      sys.exit(1)
    self.rb_list[key] = rb
    
    #Update the regblocks addresses
    self.rb_list[key].update_regs_with_new_base(key)
  
  
  ################################################
  def add_reg_system(self, key, system, is_top=1, dbg=0):
    """Adds a RegSystem to the System. Same as add_reg_block, the address is the key.
       This is used to import sub-system blocks into a higher level system"""
    
    if dbg:
      print("DBG: (add_reg_system) adding system: {0} addr: {1} to system:{2}".format(system.name, system.addr_hex, self.name))
    
    #Go through and see if system or regblock and add
    #delve into this again if system
    for rb in system.rb_list:
      if isinstance(system.rb_list[rb], RegSystem):
        system.add_reg_system(system.rb_list[rb].get_base_addr_str(), system.rb_list[rb], is_top=is_top, dbg=dbg)
        #pass
      else:
        #if rb in self.rb_list:
          #print("Warn: System: %s - Key %s is already defined for RegSystem: %s!" % (self.name, str(key), system.name))
          #print("       Please Resolve. Exiting....")
          #self.print_info()
          #sys.exit(1)
        if system.name != "" and is_top == 1:
          system.rb_list[rb].add_prefix(system.name)
        
    
    self.rb_list[key] = system
    
  
  
    
    
  
  ################################################
  def get_all_maps(self, is_top=1, top_map_dict=None):
    """Traverses the RegBlocks and retrieves all of the maps in the system.
       It will then do some error checking to ensure no maps are defined with
       different addresses (i.e. MAP_APB is not 0x0 and 0x1000). Cases like
       this will require a separate map
       
       When a system is seen, recursively go through the sub-system and pass
       a pointer to the top system map_dict for adding/checking MAPs
       """
    
    if is_top:
      top_map_dict = self.map_dict
    
    err = None
    for key in self.rb_list:
      if isinstance(self.rb_list[key], wrb.RegBlock):
        # Top Level
        if is_top:
          if self.rb_list[key].mapname in self.map_dict:
            if self.map_dict[self.rb_list[key].mapname] != self.rb_list[key].mapaddr:
              print("Error: MAP->ADDR Collision!")
              print("       Map: {0} is already defined at {1}, it is being redefined at {2} for RegBlock".format(self.rb_list[key].mapname,\
                                                               self.map_dict[self.rb_list[key].mapname], self.rb_list[key].mapaddr, self.rb_list[key].name))
              err = True
          else:
            self.map_dict[self.rb_list[key].mapname] = self.rb_list[key].mapaddr
            
        #Sub System  
        else:
          if self.rb_list[key].mapname in top_map_dict:
            if top_map_dict[self.rb_list[key].mapname] != self.rb_list[key].mapaddr:
              print("Error: MAP->ADDR Collision!")
              print("       Map: {0} is already defined at {1}, it is being redefined at {2} for RegBlock".format(self.rb_list[key].mapname,\
                                                               self.map_dict[self.rb_list[key].mapname], self.rb_list[key].mapaddr, self.rb_list[key].name))
              err = True
          else:
            top_map_dict[self.rb_list[key].mapname] = self.rb_list[key].mapaddr
            
      else:
        #Drill down into another System
        err = self.rb_list[key].get_all_maps(is_top=0, top_map_dict=top_map_dict)
    
    return err
  
  ################################################
  def set_addrw(self, addrw):
    """Goes through all of th reg_blocks in the system and updates the addw"""
    
    # Update this addrw pointer
    self.addrw = addrw
       
    for key in self.rb_list:
      if isinstance(self.rb_list[key], wrb.RegBlock):
        self.rb_list[key].set_addrw(addrw)
      else:
        self.rb_list[key].set_addrw(addrw)
  
  
  ################################################  
  #  ___         _          _        
  # | _ \  _ _  (_)  _ _   | |_   ___
  # |  _/ | '_| | | | ' \  |  _| (_-<
  # |_|   |_|   |_| |_||_|  \__| /__/
  ################################################
  

  ################################################
  def print_info(self, indent='', depth=0):
    """Prints info about the RegSystem, depth can determine how far down"""
    
    for key in self.rb_list:
      if isinstance(self.rb_list[key], wrb.RegBlock):
        print("Block: {0:25}  Addr: {1:8}".format(self.rb_list[key].name, key))
        self.rb_list[key].print_info('  ')
      else:
        print("System:{0:25}  Addr: {1:8}".format(self.rb_list[key].name, key))
        self.rb_list[key].print_info('  ')
  
  ################################################
  def print_topology(self, f=None, indent='//'):
    """Prints the topology of the System"""
    
    f.write('{0} System: {1} @ 0x{2}\n'.format(indent, self.name, self.addr_hex))
    indent=indent+'  '
    for key in self.rb_list:
      if isinstance(self.rb_list[key], wrb.RegBlock):
        f.write('{0} RegBlock: {1:40} @ 0x{2}\n'.format(indent, \
                        (self.rb_list[key].name+'('+self.rb_list[key].base_name+')'), self.rb_list[key].reg_list[0].addr_hex))
        
      else:
        self.rb_list[key].print_topology(f=f, indent=indent+'  ')
    
    
    
  ################################################
  def print_uvm_reg_model(self, uvm_rm):
    """Prints the uvm_reg_model and associated information. This should
       really only be called from the top level RegSystem"""
    
    #Some error checking
    if self.get_all_maps():
      sys.exit(1)
    
    uvm_file = uvm_rm+'.sv'
    with open(uvm_file, 'w') as f:
      head = wp.print_verilog_c_script_header(uvm_file)
      f.write(head)
      
      self.print_topology(f=f)
      f.write('\n\n\n')
      self.print_uvm_reg_class(f)
      self.print_uvm_reg_model_top(f, uvm_rm)
  
  

  ################################################
  def print_uvm_reg_class(self, f):
    """Prints the top level of the uvm reg file (where each register is created)
       as it's own class. Will call functions in the reg_block to perform this
       operation"""
       
    for key in self.rb_list:
      if isinstance(self.rb_list[key], wrb.RegBlock):
        self.rb_list[key].print_uvm_reg_class(f)
      else:
        self.rb_list[key].print_uvm_reg_class(f)
  
  
  
  ################################################
  def print_uvm_reg_model_no_reg_test(self, uvm_rm_nrt):
    """Prints the uvm_reg_model NO_REG_TEST"""
    
    #Some error checking
    if self.get_all_maps():
      sys.exit(1)
    
    uvm_file = uvm_rm_nrt+'.svh'
    with open(uvm_file, 'w') as f:
      head = wp.print_verilog_c_script_header(uvm_file)
      f.write(head)
      f.write('\n\n\n')
      self.print_uvm_reg_no_reg_test(f)
  
  ################################################
  def print_uvm_reg_no_reg_test(self, f):
    """Prints the list of registers that should not be tested"""
       
    for key in self.rb_list:
      if isinstance(self.rb_list[key], wrb.RegBlock):
        self.rb_list[key].print_uvm_reg_no_reg_test(f)
      else:
        self.rb_list[key].print_uvm_reg_no_reg_test(f)
        
  
  
  
  ################################################
  def print_ch_file(self, f):
    """Prints the top level of the C Header file"""
       
    for key in self.rb_list:
      if isinstance(self.rb_list[key], wrb.RegBlock):
        self.rb_list[key].print_ch_file(f)
      else:
        self.rb_list[key].print_ch_file(f)
  
  ################################################
  def print_uvm_reg_model_top(self, f, reg_model_name=None, is_top=1):
    """Prints the top level of the uvm reg file (where each the wav_reg_model is extended)
       as it's own class. Will call functions in the reg_block to perform this
       operation"""  
    
    if is_top:
      #f.write('class {0} extends wav_reg_model;\n'.format(reg_model_name))
      f.write('class {0} extends uvm_reg_block;\n'.format(reg_model_name))
      f.write('  `uvm_object_utils({0})\n\n'.format(reg_model_name))
    
    for key in self.rb_list:
      if isinstance(self.rb_list[key], wrb.RegBlock):
        self.rb_list[key].print_uvm_reg_model_top_register(f)
      else:
        self.rb_list[key].print_uvm_reg_model_top(f, is_top=0)
      
    # MAPs/new func
    if is_top:
      f.write('  //Reg Map Declarations\n')
      for name in self.map_dict:
        f.write('  uvm_reg_map {0};\n'.format(name))
      f.write('\n')
    
      #new func
      f.write('  function new (string name = "{0}");\n'.format(reg_model_name))
      f.write('    super.new(name);\n  endfunction\n\n')
      f.write('  function void build();\n\n')
      
      for name in self.map_dict:
        addr_v = re.sub(r'0x', '', self.map_dict[name])
        f.write('    {0:12} = create_map("{1}", {2}\'h{3}, 4, UVM_LITTLE_ENDIAN);\n'.format(name, name, self.addrw, addr_v))
    
      for key in self.rb_list:
        self.rb_list[key].print_uvm_reg_model_create(f)
      
      f.write('    this.lock_model();\n  endfunction\nendclass\n')
    
  ################################################
  def print_uvm_reg_model_create(self, f):
    
    for key in self.rb_list:
      if isinstance(self.rb_list[key], wrb.RegBlock):
        self.rb_list[key].print_uvm_reg_model_create(f)
      else:
        self.rb_list[key].print_uvm_reg_model_create(f)
      
  
#  ################################################
#  def create_pdf(self, pdf, is_top=1):
#    """Creates the PDF file for the reg system"""
#    
#    styles=getSampleStyleSheet()
#    
#    pdf.Story.append(Paragraph("System: {0}".format(self.name), pdf.head1))
#    
#    for key in self.rb_list:
#      if isinstance(self.rb_list[key], wrb.RegBlock):
#        self.rb_list[key].create_pdf(pdf)
#      else:
#        #Create a new page break to indicate start of System
#        if not is_top:
#          pdf.Story.append(PageBreak())
#          
#        self.rb_list[key].create_pdf(pdf, is_top=0)
