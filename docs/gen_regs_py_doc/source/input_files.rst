Input Register File
===================
``gen_regs_py`` uses basic text files for describing registers. There are no requirements for file extensions, only that the
file is readable.


Syntax
------
The ``gen_regs_py`` utilizes a flexible syntax strategy to allow for simple to complex register schemes to be implemented.

.. note::
  For simplicity sake, we will show the most common register formats here and describe more complex usage scenarios in the
  register/bitfields types page


Register Declaration
++++++++++++++++++++
A register declaration will follow this syntax

::

  <REGNAME>       <REGTYPE>    <{NO_REG_TEST}>   <DESCRIPTION>



.. table::
  :widths: 15, 12, 30

  +---------------+----------+-----------------------------------------------------------------------------------+
  | REGNAME       | Required | Name of the register. Must be unique to all other register for this block         |
  +---------------+----------+-----------------------------------------------------------------------------------+
  | REGTYPE       | Required | Base type of register. Must be RW or RO and denotes the `default` bitfield types  |
  +---------------+----------+-----------------------------------------------------------------------------------+
  | {NO_REG_TEST} | Optional | When ``{NO_REG_TEST}`` is defined, DV output files will result in this register   |
  |               |          | being excluded from register testing                                              |
  +---------------+----------+-----------------------------------------------------------------------------------+
  | DESCRIPTION   | Optional | Description of register. Must be on one line                                      |
  +---------------+----------+-----------------------------------------------------------------------------------+

.. note::
  You may notice that there is no **address** declaration. This is because ``gen_regs_py`` will automatically assign
  addresses based on the location of the register in the file. The first register is assigned address 0x00, the second, 
  address 0x04, and so on. 
  
  If a user wants to place certain registers at certain addresses, the user would want to manually place the registers
  in the correct order. Reserved registers can be created by declaring a register and setting one or more bits as "reserved".
  
  ::
    
    REG1        RW
      bf1       1'b0
    
    RSVRD0      RW        //No registers are generated but the space is reserved
      reserved  1'b0
    
    REG_AT_X8   RW
      bf2


Bitfield Declaration
++++++++++++++++++++
A bitfield declaration will follow this syntax

::

  <BFNAME>       <BFRESET>    <BFTYPE> <{DFT}>  <DESCRIPTION>

.. table::
  :widths: 15, 12, 30
  
  +---------------+----------+-----------------------------------------------------------------------------------+
  | BFNAME        | Required | Name of the bitfield. Must be unique to all other bitefields for this block       |
  +---------------+----------+-----------------------------------------------------------------------------------+
  | BFRESET       | Required | Denotes the width and reset value of this bitfield. Number prior to radix denotes |
  |               |          | the width, while the value after the width is assigned the reset value.           +
  |               |          |                                                                                   |
  +---------------+----------+-----------------------------------------------------------------------------------+
  | BFTYPE        | Optional | Allows user to force a particular bitfield type for this register, regardless of  |
  |               |          | how the ``REGTYPE`` is defined.                                                   |
  +---------------+----------+-----------------------------------------------------------------------------------+
  | {DFT}         | Optional | Creates DFT related overrides                                                     |
  +---------------+----------+-----------------------------------------------------------------------------------+
  | DESCRIPTION   | Optional | Description of bitfield. Not required. Must be on one line                        |
  +---------------+----------+-----------------------------------------------------------------------------------+
  
.. note ::

  Bitfields defined with BFNAME ``reserved`` are treated as reserved bitfield allocations. ``gen_regs_py`` will not 
  create a bitfield for these location, and these locations always read back all zeros. The ``reserved`` bitfield 
  keyword can be used multiple times.

Comments
++++++++
Lines beginning with ``#`` are treated as comments and not parsed


Putting it all together
+++++++++++++++++++++++
This is the general structure of each register in the input file

::

  <REGNAME>       <REGTYPE>                 <{NO_REG_TEST}>   <DESCRIPTION>
    <BFNAME>      <BFRESET>    <BFTYPE>     <{DFT}>           <DESCRIPTION>
    <BFNAME>      <BFRESET>    <BFTYPE>     <{DFT}>           <DESCRIPTION>
    <BFNAME>      <BFRESET>    <BFTYPE>     <{DFT}>           <DESCRIPTION>


Here is a simple example of a register block with three registers being created. We have ``REG1`` in which we define 
as RW and define two bitfields, which are each RW. We have ``AREADONLYREG`` which we define as RO and define a single
bitfield which in turn is a RO bitfield. And finally we have ``RWREG_WITH_RO`` which we have defined as RW, however we
also define a bitfield as RO which will force the bitfield ``somerobf`` to a RO bitfield

::

  REG1                RW                      This is the first register
    bf1               5'b0                    A description
    bf2               4'h3                    Look how I use 'h         

  AREADONLYREG        RO
    some_status_in    1'b0                    A signal I want to observe  

  RWREG_WITH_RO       RW
    somerwbf          1'b0                    This is a RW bitfield
    somerobf          3'd0      RO            But this one is read-only
    


