Input File Types
================

When a user runs ``gen_uvm_reg_model``, they pass the ``top level`` block/system file to the script. This top level file will describe all registers
that are to be included in the DUT.

In general, the user will create the top level file by describing various register blocks, with unique names, and address offsets. A user would "instantiate" a
register block by simply providing path to the file that is used for ``gen_regs_py``, or other register generation tools.

TL;DR
-----
Too Long, Didn't Read. If you just want a quick "how do I do..." in the block file:

.. code-block::
  
  MAP:<Name>                                                                 <Starting Address>
  BLK:<File>        <Instance Name>      <Block Prefix>  <Block Name>        <Address Offset>
  SWI:<File>        <Instance Name>                                          <Address Offset>
  DV:<File>         <Instance Name>                                          <Address Offset>
  SYS:<File>        <System Name>                                            <Address Offset>



Block/System File Directives
----------------------------

Environment Variables
+++++++++++++++++++++
Standard Linux Environment Variables can be used inside the block/system files to "neaten" up the files. Normal use cases would be to use an env variable
for the starting location of the workdir where the registers can be found. For example, you have your register in the following directory:

.. code-block:: none
  
  /projects/somechip/john117/regs
    |--/projects/somechip/john117/regs/spi
      |--/projects/somechip/john117/regs/spi/spi_regs.txt
    |--/projects/somechip/john117/regs/i2c
      |--/projects/somechip/john117/regs/i2c/i2c_regs.txt

You may want to set a ``SOMECHIP_REGS`` environment variable to ``/projects/somechip/john117/regs``. 

Environment Variables will follow the ``${<VAR>}`` syntax. If the variable is not set for the user, an error message will appear.

.. caution::
  Use caution when setting ENV variables across multiple projects.

BLK (Blocks)
++++++++++++
``BLK``'s are essentially the most basic level for ``gen_uvm_reg_model``. They are the same input files as the ``gen_regs_py`` tool flow. This is done
to keep a single source input for RTL, DV, and Software.

When defining a ``BLK``, the following Sytax is used for the block/system file:

.. code-block:: none
  
  BLK:<File>        <Instance Name>          <Block Prefix>  <Block Name>        <Address Offset>
  

* ``BLK:`` - A directive to signal to ``gen_reg_uvm_model`` to treat this as a register block for ``gen_regs_py`` to handle
* **File** - File used for ``gen_regs_py`` with register definitions
* **Instance Name** - This is an instance specific name that is given to this block of registers. ``N/A`` can be used to denote no instance name, 
  however, instance names are generally *recommended*.
* **Block Prefix** - This is *generally* the same block prefix used for RTL generation with ``gen_regs_py``. 
* **Block Name** - This is *generally* the same block name used for RTL generation with ``gen_regs_py``. 
* **Address Offset** - This is the address offset for this register block. Use 0x0000 notation (underscores are allowed)

All of these entries are **REQUIRED**. 

Here is an example of a block/system file where I am defining three (3) instances. Two (2) SPI instances, SPI0 and SPI1, and an I2C instance, I2C0. Giving
each a 256byte spacing:

.. code-block:: 
  
  #BLK:File                             Inst Name    Prefix   Block      Offset
  BLK:${TEST_REGS}/spi_regs.txt         SPI0         spi      regs       0x0000
  BLK:${TEST_REGS}/spi_regs.txt         SPI1         spi      regs       0x0100
  BLK:${TEST_REGS}/i2c_regs.txt         I2C0         i2c      regs       0x0200



SWI
+++
A register block in the format of the register input files using SWI format. When an ``SWI`` file is seen, ``gen_uvm_reg_model`` will parse the 
``SWI`` file and construct a register block similar to that of ``BLK`` files. 

A user can declare a ``SWI`` file with the following syntax:

.. code-block:: none

  SWI:<File>      <Instance Name>         <Address Offset>

All of these entries are **REQUIRED**.
  
.. note::
  The inputs **File**, **Instance Name**, and **Address Offset** follow the same definitions as for the ``BLK``


DV (DV blocks)
++++++++++++++
``DV`` components are text files describing register blocks that are *generally* 3rd party IP. These are IPs in which the ``gen_regs_py`` flow was not
used. 


A user can declare a ``DV`` file with the following syntax:

.. code-block:: none

  DV:<File>      <Instance Name>         <Address Offset>

All of these entries are **REQUIRED**.
  
.. note::

  The inputs **File**, **Instance Name**, and **Address Offset** follow the same definitions as for the ``BLK``

Since ``DV`` component files are only a last resort, we will not go into the details of their file types. Please see previously used blocks as an example.



SYS
+++
A register system that has at least one ``BLK``/``DV``/``SWI``/``SYS`` instance. Can instantiate other ``SYS``. 


.. code-block:: none

  SYS:<File>        <System Name>                                            <Address Offset>

* **File** - File with the BLK/DV/SWI/SYS declarations
* **System name** - Name of the system. A prefix is added to all registers under this system with the **System Name**
* **Address Offset** - Base address of this system

This is how a user would build a larger SoC level register block. Let's take the same 3 BLK example from the :ref:`BLK (Blocks)` section.


.. code-block:: none
  
  #This is in a file called "pss.blk"
  #BLK:File                             Inst Name    Prefix   Block      Offset
  BLK:${TEST_REGS}/spi_regs.txt         SPI0         spi      regs       0x0000
  BLK:${TEST_REGS}/spi_regs.txt         SPI1         spi      regs       0x0100
  BLK:${TEST_REGS}/i2c_regs.txt         I2C0         i2c      regs       0x0200
  
Now let's say I need to instantiate this IP 3 times. I could list each of these separately (6 SPIs and 3 I2Cs) or I can instantiate the ``pss.blk``
file as a SYS, and denote the base address

.. code-block:: none

  SYS:pss.blk           PSS0            0x0000    # PSS0_SPI0 -> 0x0000, PSS0_SPI1 -> 0x0100, PSS0_I2C0 -> 0x0200
  SYS:pss.blk           PSS1            0x1000    # PSS1_SPI0 -> 0x1000, PSS1_SPI1 -> 0x1100, PSS1_I2C0 -> 0x1200
  SYS:pss.blk           PSS2            0x2000    # PSS2_SPI0 -> 0x2000, PSS2_SPI1 -> 0x2100, PSS2_I2C0 -> 0x2200


This would generate a register system with where PSS0_SPI0 is at address 0x0000, PSS1_SPI0 is at address 0x1000, and so on.


MAP
+++
Used to create an additional uvm_reg_map. **Any** ``BLK``/``DV``/``SWI``/``SYS`` instances after this declaration will use this ``MAP``. 

A user can declare a ``MAP`` with the following syntax:

.. code-block:: none
  
  MAP:<Name>                                                                 <Starting Address>
  
* **Name** - Name of the map. Will be declared as a uvm_reg_map <Name> in the reg model
* **Starting Address** - Starting address of this map. ALL BLK/SWI/DV files defined after this are addressed with respect to this map

Example:

.. code-block:: none 
  
  MAP:MAP_AHB                                                            0xC000_0000    #Start MAP_AHB with base 0xC000_0000
  BLK:${TEST_REGS}/spi_regs.txt         SPI0         spi      regs       0x0000         #This is now at 0xC000_0000
  BLK:${TEST_REGS}/spi_regs.txt         SPI1         spi      regs       0x0100         #This is now at 0xC000_0100
  BLK:${TEST_REGS}/i2c_regs.txt         I2C0         i2c      regs       0x0200         #This is now at 0xC000_0200

The **DEFAULT** map, which is instantiated if no MAPs are set, is the ``MAP_APB``.

.. warning::
  Only the top level block/system file will have maps applied. This means that if you have ``MAPs`` defined in lower level ``SYS`` files, they will be ignored. 
  Care should be taken when constructing ``SYS`` where multiple ``MAPs`` are needed at the ``Top Level``

