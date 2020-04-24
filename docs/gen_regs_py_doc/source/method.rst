Methodology
===========
``gen_regs_py`` builds software registers by using the following methodology of "Classes":

::

  Register Blocks
   |-- Registers
        |-- Bitfields
  

Bitfields
  ``Bitfields`` are individual "flops" that are usually used for some specific purpose. For example, you have a software bit that 
  is used to enable a piece of logic. You name this ``logic_enable``. While only a singlebit, there is still room in the 32bit register 
  for additional logic. ``Bitfields`` can be upto 32 bits in size. If you need control over a signal larger than this, you will need to
  create multiple bitfields across registers.



Registers
  ``Registers`` are a collection of ``bitfields`` that comprise a 32bit sfotware register. Registers can be upto 32bits in size, but are 
  not required to be. For example, if you define a single 16bit bitfield in a register, and no other bitfields, only the lower 16 bits are
  accessible. Any reads will result in the top 16 bits returning 16'd0.

Register Blocks
  ``Register Blocks`` are a collection of ``Registers`` and is the essential output of the ``gen_regs_py``. The ``Register Block`` is the
  actual RTL that you will instantiate in your design. These ``Register Blocks`` are then used in other register flows for DV and SW register generation.

.. note::
  When creating registers, you are really creating each bitfield and grouping them in a collection, which is a register. And this collection of registers
  is what constitutes the register block

