"""
wav_reg_mem.py
~~~~~~~~~~

A module to implement a memory for uvm_reg_model


"""
import re
import math
import sys

class RegMem(object):
  
  ################################################
  def __init__(self, base_name='', depth=0, width=0, mapname='MAP_APB', mapaddr='0x0'):
      
    self.name           = base_name.upper()     
    self.mapname        = mapname
    #Remove any underscores, python2 issue
    self.base_addr      = 0
    mapaddr             = re.sub(r'_', '', mapaddr)
    self.mapaddr        = mapaddr
    self.addrw          = '32'
    
    self.depth          = depth       #Number of bytes (regardless of width)
    self.width          = width       #width (have this match the 

  ################################################
  def add_prefix(self, prefix):
    """Adds a prefix to the name"""
    self.name = prefix.upper()+'_'+self.name
  
  ################################################
  def set_addrw(self, addrw):
    """Sets the addrw of this regblock"""
    self.addrw = addrw
  
  ################################################
  def update_mem_with_new_base(self, newbase):
    """Goes through each register and updates the address based on new base
       Value passed should be hex"""
    self.base_addr = newbase
  
  ################################################
  def print_uvm_mem_class(self, fh=None):
    
    fh.write("class {0}_ extends uvm_mem;\n".format(self.name));
    fh.write("  `uvm_object_utils({0}_)\n\n".format(self.name));
    fh.write("  function new (string name = \"{0}_\");\n".format(self.name));
    fh.write("    super.new(name, {0}, 32, \"RW\");\n".format(self.depth));
    fh.write("  endfunction\n");
    fh.write("endclass\n\n");
  
  
  ################################################
  def print_uvm_reg_model_top_mem(self, fh=None):
    
    fh.write("  {0}_ {0};\n".format(self.name))
    
  ################################################
  def print_uvm_reg_model_create(self, fh=None):
    
    fh.write('    this.{0} = {0}_::type_id::create("{0}");\n'.format(self.name))
    fh.write('    this.{0}.configure(this);\n'.format(self.name))
    fh.write('    this.{0}.add_hdl_path_slice("{0}", {1}\'h{2}, 32);\n'.format(self.name, self.addrw, re.sub(r'0x', '', hex(int(self.base_addr, 16)))))
    fh.write('    {0}.add_mem({1}, {2}\'h{3}, "RW");\n\n'.format(self.mapname, self.name, self.addrw, re.sub(r'0x', '', hex(int(self.base_addr, 16)))))
