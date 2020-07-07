"""
wav_register.py
~~~~~~~~~~

A module to implement basic registers for register files


"""
import wav_bitfield
import math
import re
import sys  

class Register():
  ################################################
  def __init__(self, name, addr, desc='', rtype='', notest=False):
  
    self.name    = name.upper()
    self.get_reg_addr(str(addr))
    self.bf_list = []
    self.desc    = desc
    self.rtype   = rtype
    self.notest  = notest     #Used to disable UVM reg tests

  ################################################
  def get_reg_addr(self, addr):
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
    
    else:
      self.print_addr_invalid()
  
    self.addr_dec = v
    self.addr_hex = format(self.addr_dec, 'x')
    
    #This is the ORIGINAL address relative to that block. So it doesn't 
    #take any mappings into account
    self.orig_addr_hex = format(v, 'x')
  
  ################################################
  def print_addr_invalid(self, s):
    print("Error: Address format %s is invalid. Use Verilog Type Radix for addressing" % s)
  
  ################################################
  def get_addr_str(self):
    return hex(self.addr_dec)
  
  ################################################
  def add_offset(self, addr):
    #Remove any underscores, a python2 thing
    addr = re.sub(r'_', '', addr)
    self.addr_dec = self.addr_dec + int(addr, 16)
    self.addr_hex = format(self.addr_dec, 'x')
  
  ################################################
  def add_bf(self, bf, to_front=0):
    """Adds a bitfield object to the BF list. This
       happens in order. Could later add a way to 'insert' 
       according to the index if needed"""
    if to_front:
      self.bf_list.insert(0, bf)
    else:
      self.bf_list.append(bf)
  
  ################################################
  def get_reg_reset_val(self):
    """Goes through the Bitfields and calculates the overall reset value"""
    r = 0
    for bf in self.bf_list:
      r = r + (float(bf.reset_dec) * math.pow(2, float(bf.lsb)))
    r = int(r)
    
    return hex(r)
  
  ################################################
  def get_reg_type(self):
    """Returns the type of reg based on the bitfields"""
    t = 'RO'
    
    all_are_wo = True
    
    #If any are RW, call it a RW
    for bf in self.bf_list:
      if bf.type == 'RW' or bf.type == 'WO' or bf.type == 'RW1C' or bf.type == 'RW1S' or bf.type == 'W1C' or bf.type == 'W1S' or bf.type == 'RC':
        t = 'RW'
        if bf.type != 'WO':
          all_are_wo = False
      if bf.type == 'RO' or bf.type == 'RFIFO':
        all_are_wo = False
    
    
    if all_are_wo:
      t = 'WO'
    
    return t
  
  
  
  
  ################################################
  def check_width(self):
    """Checks that the register does not exceed 32bits"""
  
    total = 0
    for bf in self.bf_list:
      total = total + bf.length
    
    if total > 32:
      print("Error: Register '{}' has more than 32 bits defined. Please fix and rerun".format(self.name))
  
  ################################################  
  #  ___         _          _        
  # | _ \  _ _  (_)  _ _   | |_   ___
  # |  _/ | '_| | | | ' \  |  _| (_-<
  # |_|   |_|   |_| |_||_|  \__| /__/
  ################################################
  
  ################################################
  def print_rtl_assign_logic(self, f, last_bscan_bf=None, pre=None, block=None, clock_mux_name='wav_clock_mux'):
    """This prints out the final assign statments for RW-type registers.
       Also handles the DFT functionality including BSCAN insertion.
       
       BSCAN flop MODULE will be called <prefix>_<block>_jtag_bsr since the reg_block will create it
       externally
       
       TODO: Need to see how we can clean up this function some.
    """
    
    last_tdo_name = None
    
    for bf in self.bf_list:
      f.write('  //-----------------------\n')
      
      if bf.length > 1: mux_array = '[{0}:0]'.format(int(bf.length)-1)
      else:             mux_array = ''
      last_wire = "<something wrong>"   #this will be constantly updated
      
      ##########################
      # RW Register
      ##########################
      if bf.type == "RW":
        default        = 'reg_'+bf.name.lower()
        if bf.has_mux:
          last_wire = "swi_"+bf.name.lower()+"_muxed_pre"
          mux_str = """
  wire {2:6} {3};
  {4} u_{4}_{0}{2} (
    .clk0    ( {0:30}     ),              
    .clk1    ( reg_{0:30} ),              
    .sel     ( reg_{1:30} ),      
    .clk_out ( {3:30}     )); 

""".format(bf.name.lower(), (bf.name.lower()+"_mux"), mux_array, last_wire, clock_mux_name)
          f.write(mux_str)
        else:
          #Ignore _mux reg
          if bf.name.endswith("_mux"):
            continue
          last_wire = "reg_"+bf.name.lower()
        
        ##########################
        # DFT Checks
        # Will use a cascaded system of muxes
        ##########################
        
        # CORE_SCAN
        if bf.core_scan or bf.dftall:
          mux_str = """
  wire {4:6} {5};
  {6} u_{6}_{0}_core_scan_mode{4} (
    .clk0    ( {1:30}     ),              
    .clk1    ( {3:30}     ),              
    .sel     ( {2:30}     ),      
    .clk_out ( {5:30}     )); 

""".format(bf.name.lower(), last_wire, "dft_core_scan_mode", (str(bf.length)+"'d"+str(bf.core_scan) if bf.core_scan else str(bf.length)+"'d"+str(bf.dftall)), mux_array, (default+"_core_scan_mode"), clock_mux_name)
          f.write(mux_str)
          last_wire = default+"_core_scan_mode"
        
        # IDDQ
        if bf.iddq or bf.dftall:
          mux_str = """
  wire {4:6} {5};
  {6} u_{6}_{0}_iddq_mode{4} (
    .clk0    ( {1:30}     ),              
    .clk1    ( {3:30}     ),              
    .sel     ( {2:30}     ),      
    .clk_out ( {5:30}     )); 

""".format(bf.name.lower(), last_wire, "dft_iddq_mode", (str(bf.length)+"'d"+str(bf.iddq) if bf.iddq else str(bf.length)+"'d"+str(bf.dftall)), mux_array, (default+"_iddq_mode"), clock_mux_name)
          f.write(mux_str)
          last_wire = default+"_iddq_mode"
        
        # HIGH-Z
        if bf.hiz or bf.dftall:
          mux_str = """
  wire {4:6} {5};
  {6} u_{6}_{0}_hiz_mode{4} (
    .clk0    ( {1:30}     ),              
    .clk1    ( {3:30}     ),              
    .sel     ( {2:30}     ),      
    .clk_out ( {5:30}     )); 

""".format(bf.name.lower(), last_wire, "dft_hiz_mode", (str(bf.length)+"'d"+str(bf.hiz) if bf.hiz else str(bf.length)+"'d"+str(bf.dftall)), mux_array, (default+"_hiz_mode"), clock_mux_name)
          f.write(mux_str)
          last_wire = default+"_hiz_mode"
        
        # BSCAN
        if bf.bscan or bf.dftall:
          mux_str = """
  wire {4:6} {5};
  {6} u_{6}_{0}_bscan_mode{4} (
    .clk0    ( {1:30}     ),              
    .clk1    ( {3:30}     ),              
    .sel     ( {2:30}     ),      
    .clk_out ( {5:30}     )); 

""".format(bf.name.lower(), last_wire, "dft_bscan_mode", (str(bf.length)+"'d"+str(bf.bscan) if bf.bscan else str(bf.length)+"'d"+str(bf.dftall)), mux_array, (default+"_bscan_mode"), clock_mux_name)
          f.write(mux_str)
          last_wire = default+"_bscan_mode"
        
        
        if bf.bsflop:
          f.write("  wire {0} {1}_tdo;\n".format(mux_array, bf.name.lower()))
          #Get the chain
          if last_bscan_bf:
            if last_bscan_bf.length > 1: bit_index = '[{0}]'.format(str(int(last_bscan_bf.length)-1))
            else:                        bit_index = ''
            head_tdi = '{0}_tdo{1}'.format(last_bscan_bf.name.lower(), bit_index)    #Last one and include the bit index
          else:
            head_tdi = 'dft_bscan_tdi'    #Nothing so this is the first in the chain

          tdi_str = ''
          tdo_str = ''
          whitesp = ' '*19
          if bf.length == 1:
            tdi_str = head_tdi
            tdo_str = '{0}_tdo'.format(bf.name.lower()) 
          else:
            #Need to shift tdis
            tdi_str = '{'+'{0}_tdo[{1}],\n'.format(bf.name.lower(), str(bf.length-2))
            for x in reversed(range(bf.length-1)):
              if x == 0:
                tdi_str += '{0}{1}'.format(whitesp, head_tdi)
                tdi_str += '}'
              else:
                tdi_str += '{0}{1}_tdo[{2}],\n'.format(whitesp, bf.name.lower(), str(x-1)) 

            #tdos
            tdo_str = '{'+'{0}_tdo[{1}],\n'.format(bf.name.lower(), str(bf.length-1))
            for x in reversed(range(bf.length-1)):
              if x == 0:
                tdo_str += '{0}{1}_tdo[{2}]'.format(whitesp, bf.name.lower(), str(x))
                tdo_str += '}'
              else:
                tdo_str += '{0}{1}_tdo[{2}],\n'.format(whitesp, bf.name.lower(), str(x)) 
                
                
          bsr_po  = "{0}_bscan_flop_po".format(bf.name.lower())
          bsr_str = """
  wire {1} {3};
  {6}_{7}_jtag_bsr u_{6}_{7}_jtag_bsr_{0}{1} (   
    .bscan_mode ( dft_bscan_mode                     ),          
    .clockdr    ( dft_bscan_clockdr                  ),          
    .shiftdr    ( dft_bscan_shiftdr                  ),          
    .updatedr   ( dft_bscan_updatedr                 ),               
    .pi         ( {2:30}     ),               
    .po         ( {3:30}     ),               
    .tdi        ( {4:30}     ),                
    .tdo        ( {5:30}     )); 


""".format(bf.name.lower(), mux_array, last_wire, bsr_po, tdi_str, tdo_str, pre, block)
          f.write(bsr_str)
          last_wire = bsr_po
          # Update the last_scan_ bitfield so the next BSR chain knows where to start
          last_bscan_bf= bf
          last_tdo_name=tdo_str
        
        
        
        #Final Assignment to output port
        if bf.has_mux:  f.write("  assign swi_{0}_muxed = {1};\n\n".format(bf.name.lower(), last_wire))
        else:           f.write("  assign swi_{0} = {1};\n\n".format(bf.name.lower(), last_wire))
      
      ##########################
      # RO Register (Mainly any BSCAN checks)
      # Very similar to the RW version, but a few changes
      ##########################
      elif bf.type == "RO":
        if bf.bsflop:
          f.write("  wire {0} {1}_tdo;\n".format(mux_array, bf.name.lower()))
          #Get the chain
          if last_bscan_bf:
            if last_bscan_bf.length > 1: bit_index = '[{0}]'.format(str(int(last_bscan_bf.length)-1))
            else:                        bit_index = ''
            head_tdi = '{0}_tdo{1}'.format(last_bscan_bf.name.lower(), bit_index)    #Last one and include the bit index
          else:
            head_tdi = 'dft_bscan_tdi'    #Nothing so this is the first in the chain

          tdi_str = ''
          tdo_str = ''
          whitesp = ' '*19
          if bf.length == 1:
            tdi_str = head_tdi
            tdo_str = '{0}_tdo'.format(bf.name.lower()) 
          else:
            #Need to shift tdis
            tdi_str = '{'+'{0}_tdo[{1}],\n'.format(bf.name.lower(), str(bf.length-2))
            for x in reversed(range(bf.length-1)):
              if x == 0:
                tdi_str += '{0}{1}'.format(whitesp, head_tdi)
                tdi_str += '}'
              else:
                tdi_str += '{0}{1}_tdo[{2}],\n'.format(whitesp, bf.name.lower(), str(x-1)) 

            #tdos
            tdo_str = '{'+'{0}_tdo[{1}],\n'.format(bf.name.lower(), str(bf.length-1))
            for x in reversed(range(bf.length-1)):
              if x == 0:
                tdo_str += '{0}{1}_tdo[{2}]'.format(whitesp, bf.name.lower(), str(x))
                tdo_str += '}'
              else:
                tdo_str += '{0}{1}_tdo[{2}],\n'.format(whitesp, bf.name.lower(), str(x)) 
                
                
          bsr_str = """
  {6}_{7}_jtag_bsr u_{6}_{7}_jtag_bsr_{0}{1} (
    .bscan_mode ( dft_bscan_mode                     ),          
    .clockdr    ( dft_bscan_clockdr                  ),          
    .shiftdr    ( dft_bscan_shiftdr                  ),          
    .updatedr   ( dft_bscan_updatedr                 ),               
    .pi         ( {2:30}     ),               
    .po         ( {3:30}     ),               
    .tdi        ( {4:30}     ),                
    .tdo        ( {5:30}     )); 


""".format(bf.name.lower(), mux_array, bf.name.lower(), "/*noconn*/", tdi_str, tdo_str, pre, block)
          f.write(bsr_str)
          #last_wire = bsr_po
          # Update the last_scan_ bitfield so the next BSR chain knows where to start
          last_bscan_bf= bf
          last_tdo_name=tdo_str
        
      ##########################
      # W1C....too easy
      ##########################
      elif bf.type == "W1C":
        f.write("  assign w1c_out_{0} = reg_w1c_{0};\n".format(bf.name.lower()))
        
    return (last_bscan_bf, last_tdo_name)


      
        
    
        
  
  ################################################
  def print_uvm_reg_class(self, prefix='', fh=None, mapname='MAP_APB', mapaddr='0x0'):
    """Prints the uvm_reg extension of the reg_model"""
    
    fh.write("class {0}_ extends uvm_reg;\n".format(prefix+self.name))
    fh.write("  `uvm_object_utils({0}_)\n\n".format(prefix+self.name))
    
    for bf in reversed(self.bf_list):
      fh.write("  rand uvm_reg_field {0};\n".format(bf.name))
  
    fh.write('\n')
    fh.write('  function new (string name = "{0}_");\n'.format(prefix+self.name))
    fh.write('    super.new(name, 32, UVM_NO_COVERAGE);\n')
    fh.write('  endfunction\n\n')
    
    fh.write('  //Addr        : {0:10} (Includes Map Offset)\n'.format(self.get_addr_str()))
    fh.write('  //Map         : {0:10}  {1}\n'.format(mapname, mapaddr))
    fh.write('  //Reset       : {0:10}\n'.format(self.get_reg_reset_val()))
    fh.write('  //Description : {0}\n'.format(self.desc))
    
    fh.write('  function void build;\n')
    
    for bf in reversed(self.bf_list):
      #fh.write('    //{:40} LSB: {:2} Size: {:2} Reset: {:10}\n'.format(self.name+'__'+bf.name, bf.lsb, bf.length, bf.get_reset_hex()))
      fh.write('    //Description: {0}\n'.format(bf.desc))
      fh.write('    {0} = uvm_reg_field::type_id::create("{1}"); '.format(bf.name, bf.name))
      fh.write(' //{0:>20}\n'.format(self.name+'__'+bf.name))
      #Convert the WFIFO/RFIFO types into WO/RO
      bft = bf.type
      if bf.type == "WFIFO":
        bft = "WO"
      elif bf.type == "RFIFO":
        bft = "RO"
      fh.write('    {0}.configure(this, {1}, {2}, "{3}", 0, {4}, 1, 1, 0);\n'.format(bf.name, bf.length, bf.lsb, bft, bf.get_reset_hex_verilog()))
    
    fh.write('  endfunction\n');
    fh.write('endclass\n\n');
    
  
    
  ################################################
  def print_info(self, indent=''):
    print('%s-------------------' % indent)
    print('{0}Register: {1:40} Addr: {2:8} {3}'.format(indent, self.name, self.get_addr_str(), 'NO_REG_TEST' if self.notest else ''))
    for b in self.bf_list:
      b.print_info(indent+'  ')

  
  
