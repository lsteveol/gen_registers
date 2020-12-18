"""
wav_swi.py
~~~~~~~~~~

A module for SWI files. This is mainly used to 
convert from SWI to our regblock formats


"""



import re
#import wav_bitfield as wbf
from wav_bitfield import *
#import wav_register as wr
from wav_register import *
from wav_reg_block import *
from pyparsing import *
import os


class SwiBlock(RegBlock):
  
  ################################################
  def __init__(self, filename, base_name='', mapname='MAP_APB', mapaddr='0x0'):
    RegBlock.__init__(self, base_name=base_name, mapname=mapname, mapaddr=mapaddr)
    self.filename = filename
    self.swi_module_name = ''
    
    self.parse_file()
    
  
  ################################################
  def parse_file(self):
    
    
    #Grammar
    # Module name
    mkey    = Literal('MODULE')
    mname   = Word(alphanums+'_').setResultsName('name')
    module  = mkey + mname
    
    # Register
    rname   = Word(alphanums+'_').setResultsName('name')
    #raddr   = (Literal('0x') + (Word(nums+'ABCDEFabcdef')).setResultsName('val')).setResultsName('addr')
    raddr   = (oneOf("0x 0X") + (Word(nums+'ABCDEFabcdef')).setResultsName('val')).setResultsName('addr')
    rtype   = oneOf("RW R W1C WC W1T").setResultsName('type')
    
    rnotst  = Optional(Literal('NO_REG_TEST')).setResultsName('reg_no_test')
    #rdesc   = Optional(Regex(".*")).setResultsName('desc')
    rdesc   = QuotedString('"').setResultsName('desc')
    
    
    reg     = rname + raddr + rtype + rdesc + rnotst
    
    # Bitfield
    bfname  = Word(alphanums+'_').setResultsName('name')
    bfind   = Word(alphanums+':').setResultsName('index')
    #bfrst   = (Literal('DEF=0x') + (Word(nums+'ABCDEFabcdef')).setResultsName('val')).setResultsName('reset') 
    bfrst   = (oneOf("DEF=0x DEF=0X") + (Word(nums+'ABCDEFabcdef')).setResultsName('val')).setResultsName('reset') 
    bfdesc  = Optional(Regex(".*")).setResultsName('desc')
    bf      = bfname + bfind + bfrst + bfdesc
    
    curreg = None
    #curlsb = 0
    
    try:
      os.path.isfile(self.filename)
    except FileNotFoundError:
      print("Error: SWI file {} doesn't seem to exist!".format(self.filename))
      set_err()
    else:
      with open(self.filename) as f:
        linenum = 1
        for line in f:
          line = line.rstrip("\n\r")
          if not line.startswith("#") and line.strip():
            
            #######################
            # Module name
            #######################
            try:
              m = module.parseString(line)
              if m:
                self.name = m.name.upper()+'_'    #Need to figure out why I need this extra underscore?
                self.swi_module_name = self.name
            except ParseException:
              pass
            
            
            #######################
            # Register Def
            #######################
            try:
              #raddr.setDebug()
              r = reg.parseString(line)
              if r:
                if curreg:
                  self.add_reg(curreg, bypass_bf_chk=1) #Disable check for SWI
                r_type_fix = "RW"
                if r['type'] == "R":
                  r_type_fix = "RO"
                elif r['type'] == "WC":
                  #r_type_fix = "WC"
                  r_type_fix = "WO"     #Fix for reg model build
                elif r['type'] == "W1C":
                  r_type_fix = "W1C"
                elif r['type'] == "W1T":
                  #r_type_fix = "W1T"
                  r_type_fix = "WO"     #Fix for reg model build
                
                notest = False
                if r.reg_no_test:
                  notest = True
                
                curreg = Register(r['name'], ("'h"+str(r['addr']['val'])), desc=r['desc'], rtype=r_type_fix, notest=notest)
                #curreg = Register(r['name'], ("'h"+str(r.addr.val)), desc=r['desc'], rtype=r_type_fix)
                  
            except ParseException:
              pass
            
            #######################
            # Bitfield
            #######################
            try:
              b = bf.parseString(line)
              if b:
                if not b['name']: print("ERROR: No bitfield name for line: {}".format(line))
                if not b['index']:  print("ERROR: No bitfield index for line: {}".format(line))
                if not b['reset']:  print("ERROR: No bitfield reset for line: {}".format(line))
                bfdesc = b.bfdesc if b.bfdesc else ''
                
                # Fix reset and length as well as lsb
                msb = -1
                m = re.search('([0-9]+):([0-9]+)', b['index'])
                if m:
                  msb = m.group(1)
                  lsb = m.group(2)
                else:
                  lsb = b['index']
                
                length = 1
                if msb != -1:
                  length = int(msb) - int(lsb) + 1
                
                bfreset = str(length)+"'h"+b['reset']['val']
                
                bftype = curreg.rtype
                
                curbf = Bitfield(b['name'], lsb, bftype, bfreset, desc=bfdesc)
                curreg.add_bf(curbf)
                  
            except ParseException:
              pass
        
        #final reg
        self.add_reg(curreg, bypass_bf_chk=1)

#  ################################################
#  def print_info(self):
#    print("module {}".format(self.name))
#    
#    for r in self.reg_list:
#      pass
#    
#    RegBlock.print_info(self)
