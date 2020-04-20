"""
wav_bitfield.py
~~~~~~~~~~

A module to implement basic bitfields for register files


Supports RW, RO, WO, W1C (Write 1 to Clear), W1S (Write 1 to Set), RC (Read to Clear)

"""

import re
import math
import sys

class Bitfield():
  
  ################################################
  def __init__(self, name, lsb, type, reset, desc="", rsvd=None):
    self.name           = name
    self.lsb            = lsb
    self.length         = 1         # Don't know yet
    self.type           = type.upper()
    self.desc           = desc
    self.reset_is_param = False
    
    self.check_reset_val(reset)
    self.check_reset_against_type()
    
    #Has mux will be set by the parser
    self.has_mux  = 0
    self.err      = 0
    
    self.pwrdn    = None
    self.rsvd     = None
    
    self.register = None
    
    #DFT Settings
    #Set these after the bitfield is created, if they need to be set
    self.dftall   = None
    self.core_scan= None
    self.iddq     = None
    self.hiz      = None
    self.bscan    = None
    self.bsflop   = None
  
  ################################################
  def check_reset_val(self, reset_str):
    """Checks the assigned reset value against the length and radix
       This allows you to assign the value however and can be used
       across different scripts. Still maintains a Verilog style 
       syntax"""
    
    
    ### Parameter (do this first since b/d/h also in here)
    if "'PAR:" in reset_str:
      s = reset_str.split("'PAR:");
      
      if len(s) != 2:
        self.print_reset_invalid(reset_str)
      
      l = int(s[0])
      # Go through and figure out if b/d/h for val
      if "'b" in s[1]:
        val = re.sub("'b", "", s[1])
        v = int(val, 2)
      elif "'h" in s[1]:
        val = re.sub("'h", "", s[1])
        v = int(val, 16)
      elif "'d" in s[1]:
        val = re.sub("'d", "", s[1])
        v = int(val)
      else:
        self.print_reset_invalid(reset_str)
       
      self.reset_is_param = True
      
    #### BINARY
    elif "'b" in reset_str:
      s = reset_str.split("'b");
      if len(s) != 2:
        self.print_reset_invalid(reset_str)
        
      l = int(s[0])
      v = int(s[1], 2)
      
    #### HEX
    elif "'h" in reset_str:
      s = reset_str.split("'h");
      
      if len(s) != 2:
        self.print_reset_invalid(reset_str)
      
      l = int(s[0])
      v = int(s[1], 16)
      
    #### Decimal
    elif "'d" in reset_str:
      s = reset_str.split("'d");
      
      if len(s) != 2:
        self.print_reset_invalid(reset_str)
      
      l = int(s[0])
      v = int(s[1])   
    
    
    
    else:
      self.print_reset_invalid(reset_str)
      
    
    #All good
    m = int(math.pow(2,l) - 1)
    if(v > m):
      self.print_reset_too_large(reset_str)

    self.length     = l
    self.reset_dec  = v
    self.reset_hex  = format(self.reset_dec, 'x')
    
    if self.length > 1 and self.type == "W1C":
      print("Error: You have defined a W1C bitfield ({0}) that is larger than 1bit. This is not supported. Fix".format(self.name))
      sys.exit(1)
  
  ################################################
  def print_reset_invalid(self, s):
    print('Error! Reset Val of (', s,') is not valid format for', self.name)
    exit(1)
  
  ################################################
  def print_reset_too_large(self, s ):
    print('Error! Reset Val of (', s,') is not valid (too large) for', self.name)
    exit(1)
    
  ################################################
  def get_reset_hex(self):
    return hex(self.reset_dec)
  
  ################################################
  def has_dft(self):
    if self.dftall or self.iddq or self.hiz or self.bscan or self.bsflop or self.core_scan:
      return True
    else:
      return False
  
  ################################################
  def get_index_str(self):
    if self.length > 1:
      index = "[{0}:{1}]".format(str(int(self.lsb)+int(self.length)-1), str(self.lsb))
    else:
      index = "[{0}]".format(str(self.lsb))
    
    return index
  
  ################################################
  def get_reset_hex_verilog(self):
    return "'h{0}".format(self.reset_hex)
      
  ################################################
  def check_reset_against_type(self):
    pass
    #if self.type == 'RO' or self.type == 'WO' or self.type == 'W1C' or self.type == 'W1S' or self.type == 'RC':
    #  if self.reset_dec != 0 :
    #    print("Info: You have declared {} as non-RW but given a reset val, it will be defaulted to 0".format(self.name))
    #    self.reset_dec = 0
    #    self.reset_hex = format(self.reset_dec, 'x')
  
  
  ################################################   
  def print_verilog(self):
    """Prints the verilog component of the bitfield"""
    
  
  ################################################   
  def print_verilog_define(self):
    """Prints the addr_defines.vh component of the bitfield"""  
    
    
  ################################################
  def print_info(self, indent=''):
    """Primarily a debug function to check contents"""
    print("{0}{1:25} {2:2} {3:2} {4:3} 0x{5:8} Mux:{6}".format(indent, self.name, self.lsb, self.length, self.type, self.reset_hex, self.has_mux))
    dftstr = None
    if self.dftall:
      dftstr = 'DFTALL:{0}'.format(self.dftall)
    if self.iddq:
      dftstr += ' IDDQ:{0}'.format(self.iddq)
    if self.hiz:
      dftstr += ' HIZ:{0}'.format(self.hiz)
    if self.bscan:
      dftstr += ' BSCAN:{0}'.format(self.bscan)
    if self.bsflop:
      dftstr += ' Has BSCAN FLOP'
    if dftstr:
      print('{0}{1}'.format(indent, dftstr))
