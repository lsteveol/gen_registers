//===================================================================
//
// Copyright (C) Wavious 2019 - All Rights Reserved
//
// Unauthorized copying of this file, via any medium is strictly prohibited
//
// Created by sbridges on November/11/2019 at 13:18:06
//
// wav_reg_model_lss.sv
//
//===================================================================



// System:  @ 0x0
//   RegBlock: SPI0_(SPI_REGS)                          @ 0x0
//   RegBlock: SPI1_(SPI_REGS)                          @ 0x100
//   RegBlock: I2C0_(I2C_REGS)                          @ 0x200



// RegBlock SPI0_
class SPI0_SPI_REGS_ENABLE_ extends uvm_reg;
  `uvm_object_utils(SPI0_SPI_REGS_ENABLE_)

  rand uvm_reg_field CLOCK_GATE;
  rand uvm_reg_field SPI_EN;

  function new (string name = "SPI0_SPI_REGS_ENABLE_");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  //Addr        : 0x0        (Includes Map Offset)
  //Map         : MAP_APB     0x0
  //Reset       : 0x1       
  //Description : 
  function void build;
    //Description: 
    CLOCK_GATE = uvm_reg_field::type_id::create("CLOCK_GATE");  //SPI_REGS_ENABLE__CLOCK_GATE
    CLOCK_GATE.configure(this, 1, 1, "RW", 0, 'h0, 1, 1, 0);
    //Description: 
    SPI_EN = uvm_reg_field::type_id::create("SPI_EN");  //SPI_REGS_ENABLE__SPI_EN
    SPI_EN.configure(this, 1, 0, "RW", 0, 'h1, 1, 1, 0);
  endfunction
endclass

class SPI0_SPI_REGS_CONTROLS_ extends uvm_reg;
  `uvm_object_utils(SPI0_SPI_REGS_CONTROLS_)

  rand uvm_reg_field CPHA;
  rand uvm_reg_field CPOL;
  rand uvm_reg_field SS_POLARITY;

  function new (string name = "SPI0_SPI_REGS_CONTROLS_");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  //Addr        : 0x4        (Includes Map Offset)
  //Map         : MAP_APB     0x0
  //Reset       : 0x0       
  //Description : 
  function void build;
    //Description: 
    CPHA = uvm_reg_field::type_id::create("CPHA");  //SPI_REGS_CONTROLS__CPHA
    CPHA.configure(this, 1, 2, "RW", 0, 'h0, 1, 1, 0);
    //Description: 
    CPOL = uvm_reg_field::type_id::create("CPOL");  //SPI_REGS_CONTROLS__CPOL
    CPOL.configure(this, 1, 1, "RW", 0, 'h0, 1, 1, 0);
    //Description: 
    SS_POLARITY = uvm_reg_field::type_id::create("SS_POLARITY");  //SPI_REGS_CONTROLS__SS_POLARITY
    SS_POLARITY.configure(this, 1, 0, "RW", 0, 'h0, 1, 1, 0);
  endfunction
endclass

class SPI0_SPI_REGS_INTERRUPT_ extends uvm_reg;
  `uvm_object_utils(SPI0_SPI_REGS_INTERRUPT_)

  rand uvm_reg_field TRANSACTION_COMP_INT_EN;
  rand uvm_reg_field TRANSACTION_COMP;

  function new (string name = "SPI0_SPI_REGS_INTERRUPT_");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  //Addr        : 0x8        (Includes Map Offset)
  //Map         : MAP_APB     0x0
  //Reset       : 0x2       
  //Description : 
  function void build;
    //Description: 
    TRANSACTION_COMP_INT_EN = uvm_reg_field::type_id::create("TRANSACTION_COMP_INT_EN");  //SPI_REGS_INTERRUPT__TRANSACTION_COMP_INT_EN
    TRANSACTION_COMP_INT_EN.configure(this, 1, 1, "RW", 0, 'h1, 1, 1, 0);
    //Description: 
    TRANSACTION_COMP = uvm_reg_field::type_id::create("TRANSACTION_COMP");  //SPI_REGS_INTERRUPT__TRANSACTION_COMP
    TRANSACTION_COMP.configure(this, 1, 0, "W1C", 0, 'h0, 1, 1, 0);
  endfunction
endclass

class SPI0_SPI_REGS_WDATA_ extends uvm_reg;
  `uvm_object_utils(SPI0_SPI_REGS_WDATA_)

  rand uvm_reg_field WDATA;

  function new (string name = "SPI0_SPI_REGS_WDATA_");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  //Addr        : 0xc        (Includes Map Offset)
  //Map         : MAP_APB     0x0
  //Reset       : 0x0       
  //Description : 
  function void build;
    //Description: 
    WDATA = uvm_reg_field::type_id::create("WDATA");  //SPI_REGS_WDATA__WDATA
    WDATA.configure(this, 8, 0, "WO", 0, 'h0, 1, 1, 0);
  endfunction
endclass

class SPI0_SPI_REGS_RDATA_ extends uvm_reg;
  `uvm_object_utils(SPI0_SPI_REGS_RDATA_)

  rand uvm_reg_field RDATA;

  function new (string name = "SPI0_SPI_REGS_RDATA_");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  //Addr        : 0x10       (Includes Map Offset)
  //Map         : MAP_APB     0x0
  //Reset       : 0x0       
  //Description : 
  function void build;
    //Description: 
    RDATA = uvm_reg_field::type_id::create("RDATA");  //SPI_REGS_RDATA__RDATA
    RDATA.configure(this, 8, 0, "RO", 0, 'h0, 1, 1, 0);
  endfunction
endclass

class SPI0_SPI_REGS_STATUS_ extends uvm_reg;
  `uvm_object_utils(SPI0_SPI_REGS_STATUS_)

  rand uvm_reg_field FSM_STATE;

  function new (string name = "SPI0_SPI_REGS_STATUS_");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  //Addr        : 0x14       (Includes Map Offset)
  //Map         : MAP_APB     0x0
  //Reset       : 0x0       
  //Description : 
  function void build;
    //Description: 
    FSM_STATE = uvm_reg_field::type_id::create("FSM_STATE");  //SPI_REGS_STATUS__FSM_STATE
    FSM_STATE.configure(this, 3, 0, "RO", 0, 'h0, 1, 1, 0);
  endfunction
endclass

// RegBlock SPI1_
class SPI1_SPI_REGS_ENABLE_ extends uvm_reg;
  `uvm_object_utils(SPI1_SPI_REGS_ENABLE_)

  rand uvm_reg_field CLOCK_GATE;
  rand uvm_reg_field SPI_EN;

  function new (string name = "SPI1_SPI_REGS_ENABLE_");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  //Addr        : 0x100      (Includes Map Offset)
  //Map         : MAP_APB     0x0
  //Reset       : 0x1       
  //Description : 
  function void build;
    //Description: 
    CLOCK_GATE = uvm_reg_field::type_id::create("CLOCK_GATE");  //SPI_REGS_ENABLE__CLOCK_GATE
    CLOCK_GATE.configure(this, 1, 1, "RW", 0, 'h0, 1, 1, 0);
    //Description: 
    SPI_EN = uvm_reg_field::type_id::create("SPI_EN");  //SPI_REGS_ENABLE__SPI_EN
    SPI_EN.configure(this, 1, 0, "RW", 0, 'h1, 1, 1, 0);
  endfunction
endclass

class SPI1_SPI_REGS_CONTROLS_ extends uvm_reg;
  `uvm_object_utils(SPI1_SPI_REGS_CONTROLS_)

  rand uvm_reg_field CPHA;
  rand uvm_reg_field CPOL;
  rand uvm_reg_field SS_POLARITY;

  function new (string name = "SPI1_SPI_REGS_CONTROLS_");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  //Addr        : 0x104      (Includes Map Offset)
  //Map         : MAP_APB     0x0
  //Reset       : 0x0       
  //Description : 
  function void build;
    //Description: 
    CPHA = uvm_reg_field::type_id::create("CPHA");  //SPI_REGS_CONTROLS__CPHA
    CPHA.configure(this, 1, 2, "RW", 0, 'h0, 1, 1, 0);
    //Description: 
    CPOL = uvm_reg_field::type_id::create("CPOL");  //SPI_REGS_CONTROLS__CPOL
    CPOL.configure(this, 1, 1, "RW", 0, 'h0, 1, 1, 0);
    //Description: 
    SS_POLARITY = uvm_reg_field::type_id::create("SS_POLARITY");  //SPI_REGS_CONTROLS__SS_POLARITY
    SS_POLARITY.configure(this, 1, 0, "RW", 0, 'h0, 1, 1, 0);
  endfunction
endclass

class SPI1_SPI_REGS_INTERRUPT_ extends uvm_reg;
  `uvm_object_utils(SPI1_SPI_REGS_INTERRUPT_)

  rand uvm_reg_field TRANSACTION_COMP_INT_EN;
  rand uvm_reg_field TRANSACTION_COMP;

  function new (string name = "SPI1_SPI_REGS_INTERRUPT_");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  //Addr        : 0x108      (Includes Map Offset)
  //Map         : MAP_APB     0x0
  //Reset       : 0x2       
  //Description : 
  function void build;
    //Description: 
    TRANSACTION_COMP_INT_EN = uvm_reg_field::type_id::create("TRANSACTION_COMP_INT_EN");  //SPI_REGS_INTERRUPT__TRANSACTION_COMP_INT_EN
    TRANSACTION_COMP_INT_EN.configure(this, 1, 1, "RW", 0, 'h1, 1, 1, 0);
    //Description: 
    TRANSACTION_COMP = uvm_reg_field::type_id::create("TRANSACTION_COMP");  //SPI_REGS_INTERRUPT__TRANSACTION_COMP
    TRANSACTION_COMP.configure(this, 1, 0, "W1C", 0, 'h0, 1, 1, 0);
  endfunction
endclass

class SPI1_SPI_REGS_WDATA_ extends uvm_reg;
  `uvm_object_utils(SPI1_SPI_REGS_WDATA_)

  rand uvm_reg_field WDATA;

  function new (string name = "SPI1_SPI_REGS_WDATA_");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  //Addr        : 0x10c      (Includes Map Offset)
  //Map         : MAP_APB     0x0
  //Reset       : 0x0       
  //Description : 
  function void build;
    //Description: 
    WDATA = uvm_reg_field::type_id::create("WDATA");  //SPI_REGS_WDATA__WDATA
    WDATA.configure(this, 8, 0, "WO", 0, 'h0, 1, 1, 0);
  endfunction
endclass

class SPI1_SPI_REGS_RDATA_ extends uvm_reg;
  `uvm_object_utils(SPI1_SPI_REGS_RDATA_)

  rand uvm_reg_field RDATA;

  function new (string name = "SPI1_SPI_REGS_RDATA_");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  //Addr        : 0x110      (Includes Map Offset)
  //Map         : MAP_APB     0x0
  //Reset       : 0x0       
  //Description : 
  function void build;
    //Description: 
    RDATA = uvm_reg_field::type_id::create("RDATA");  //SPI_REGS_RDATA__RDATA
    RDATA.configure(this, 8, 0, "RO", 0, 'h0, 1, 1, 0);
  endfunction
endclass

class SPI1_SPI_REGS_STATUS_ extends uvm_reg;
  `uvm_object_utils(SPI1_SPI_REGS_STATUS_)

  rand uvm_reg_field FSM_STATE;

  function new (string name = "SPI1_SPI_REGS_STATUS_");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  //Addr        : 0x114      (Includes Map Offset)
  //Map         : MAP_APB     0x0
  //Reset       : 0x0       
  //Description : 
  function void build;
    //Description: 
    FSM_STATE = uvm_reg_field::type_id::create("FSM_STATE");  //SPI_REGS_STATUS__FSM_STATE
    FSM_STATE.configure(this, 3, 0, "RO", 0, 'h0, 1, 1, 0);
  endfunction
endclass

// RegBlock I2C0_
class I2C0_I2C_REGS_ENABLE_ extends uvm_reg;
  `uvm_object_utils(I2C0_I2C_REGS_ENABLE_)

  rand uvm_reg_field CLOCK_GATE;
  rand uvm_reg_field I2C_EN;

  function new (string name = "I2C0_I2C_REGS_ENABLE_");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  //Addr        : 0x200      (Includes Map Offset)
  //Map         : MAP_APB     0x0
  //Reset       : 0x1       
  //Description : 
  function void build;
    //Description: 
    CLOCK_GATE = uvm_reg_field::type_id::create("CLOCK_GATE");  //I2C_REGS_ENABLE__CLOCK_GATE
    CLOCK_GATE.configure(this, 1, 1, "RW", 0, 'h0, 1, 1, 0);
    //Description: 
    I2C_EN = uvm_reg_field::type_id::create("I2C_EN");  //I2C_REGS_ENABLE__I2C_EN
    I2C_EN.configure(this, 1, 0, "RW", 0, 'h1, 1, 1, 0);
  endfunction
endclass

class I2C0_I2C_REGS_INTERRUPT_ extends uvm_reg;
  `uvm_object_utils(I2C0_I2C_REGS_INTERRUPT_)

  rand uvm_reg_field TRANSACTION_COMP_INT_EN;
  rand uvm_reg_field TRANSACTION_COMP;

  function new (string name = "I2C0_I2C_REGS_INTERRUPT_");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  //Addr        : 0x204      (Includes Map Offset)
  //Map         : MAP_APB     0x0
  //Reset       : 0x2       
  //Description : 
  function void build;
    //Description: 
    TRANSACTION_COMP_INT_EN = uvm_reg_field::type_id::create("TRANSACTION_COMP_INT_EN");  //I2C_REGS_INTERRUPT__TRANSACTION_COMP_INT_EN
    TRANSACTION_COMP_INT_EN.configure(this, 1, 1, "RW", 0, 'h1, 1, 1, 0);
    //Description: 
    TRANSACTION_COMP = uvm_reg_field::type_id::create("TRANSACTION_COMP");  //I2C_REGS_INTERRUPT__TRANSACTION_COMP
    TRANSACTION_COMP.configure(this, 1, 0, "W1C", 0, 'h0, 1, 1, 0);
  endfunction
endclass

class I2C0_I2C_REGS_SLAVE_ADDR_ extends uvm_reg;
  `uvm_object_utils(I2C0_I2C_REGS_SLAVE_ADDR_)

  rand uvm_reg_field SLAVE_ADDR;

  function new (string name = "I2C0_I2C_REGS_SLAVE_ADDR_");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  //Addr        : 0x208      (Includes Map Offset)
  //Map         : MAP_APB     0x0
  //Reset       : 0x5b      
  //Description : 
  function void build;
    //Description: 
    SLAVE_ADDR = uvm_reg_field::type_id::create("SLAVE_ADDR");  //I2C_REGS_SLAVE_ADDR__SLAVE_ADDR
    SLAVE_ADDR.configure(this, 10, 0, "RW", 0, 'h5b, 1, 1, 0);
  endfunction
endclass

class I2C0_I2C_REGS_WDATA_ extends uvm_reg;
  `uvm_object_utils(I2C0_I2C_REGS_WDATA_)

  rand uvm_reg_field WDATA;

  function new (string name = "I2C0_I2C_REGS_WDATA_");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  //Addr        : 0x20c      (Includes Map Offset)
  //Map         : MAP_APB     0x0
  //Reset       : 0x0       
  //Description : 
  function void build;
    //Description: 
    WDATA = uvm_reg_field::type_id::create("WDATA");  //I2C_REGS_WDATA__WDATA
    WDATA.configure(this, 8, 0, "WO", 0, 'h0, 1, 1, 0);
  endfunction
endclass

class I2C0_I2C_REGS_RDATA_ extends uvm_reg;
  `uvm_object_utils(I2C0_I2C_REGS_RDATA_)

  rand uvm_reg_field RDATA;

  function new (string name = "I2C0_I2C_REGS_RDATA_");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  //Addr        : 0x210      (Includes Map Offset)
  //Map         : MAP_APB     0x0
  //Reset       : 0x0       
  //Description : 
  function void build;
    //Description: 
    RDATA = uvm_reg_field::type_id::create("RDATA");  //I2C_REGS_RDATA__RDATA
    RDATA.configure(this, 8, 0, "RO", 0, 'h0, 1, 1, 0);
  endfunction
endclass

class I2C0_I2C_REGS_STATUS_ extends uvm_reg;
  `uvm_object_utils(I2C0_I2C_REGS_STATUS_)

  rand uvm_reg_field FSM_STATE;

  function new (string name = "I2C0_I2C_REGS_STATUS_");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  //Addr        : 0x214      (Includes Map Offset)
  //Map         : MAP_APB     0x0
  //Reset       : 0x0       
  //Description : 
  function void build;
    //Description: 
    FSM_STATE = uvm_reg_field::type_id::create("FSM_STATE");  //I2C_REGS_STATUS__FSM_STATE
    FSM_STATE.configure(this, 3, 0, "RO", 0, 'h0, 1, 1, 0);
  endfunction
endclass

class wav_reg_model_lss extends wav_reg_model;
  `uvm_object_utils(wav_reg_model_lss)

  //RegBlock SPI0_
  rand SPI0_SPI_REGS_ENABLE_                              SPI0_SPI_REGS_ENABLE;
  rand SPI0_SPI_REGS_CONTROLS_                            SPI0_SPI_REGS_CONTROLS;
  rand SPI0_SPI_REGS_INTERRUPT_                           SPI0_SPI_REGS_INTERRUPT;
  rand SPI0_SPI_REGS_WDATA_                               SPI0_SPI_REGS_WDATA;
  rand SPI0_SPI_REGS_RDATA_                               SPI0_SPI_REGS_RDATA;
  rand SPI0_SPI_REGS_STATUS_                              SPI0_SPI_REGS_STATUS;

  //RegBlock SPI1_
  rand SPI1_SPI_REGS_ENABLE_                              SPI1_SPI_REGS_ENABLE;
  rand SPI1_SPI_REGS_CONTROLS_                            SPI1_SPI_REGS_CONTROLS;
  rand SPI1_SPI_REGS_INTERRUPT_                           SPI1_SPI_REGS_INTERRUPT;
  rand SPI1_SPI_REGS_WDATA_                               SPI1_SPI_REGS_WDATA;
  rand SPI1_SPI_REGS_RDATA_                               SPI1_SPI_REGS_RDATA;
  rand SPI1_SPI_REGS_STATUS_                              SPI1_SPI_REGS_STATUS;

  //RegBlock I2C0_
  rand I2C0_I2C_REGS_ENABLE_                              I2C0_I2C_REGS_ENABLE;
  rand I2C0_I2C_REGS_INTERRUPT_                           I2C0_I2C_REGS_INTERRUPT;
  rand I2C0_I2C_REGS_SLAVE_ADDR_                          I2C0_I2C_REGS_SLAVE_ADDR;
  rand I2C0_I2C_REGS_WDATA_                               I2C0_I2C_REGS_WDATA;
  rand I2C0_I2C_REGS_RDATA_                               I2C0_I2C_REGS_RDATA;
  rand I2C0_I2C_REGS_STATUS_                              I2C0_I2C_REGS_STATUS;

  //Reg Map Declarations
  uvm_reg_map MAP_APB;

  function new (string name = "wav_reg_model_lss");
    super.new(name);
  endfunction

  function void build();

    MAP_APB      = create_map("MAP_APB", 32'h0, 4, UVM_LITTLE_ENDIAN);
    this.SPI0_SPI_REGS_ENABLE = SPI0_SPI_REGS_ENABLE_::type_id::create("SPI0_SPI_REGS_ENABLE");
    this.SPI0_SPI_REGS_ENABLE.build();
    this.SPI0_SPI_REGS_ENABLE.configure(this);
    this.SPI0_SPI_REGS_ENABLE.add_hdl_path_slice("SPI0_SPI_REGS_ENABLE", 32'h0, 32);
    MAP_APB.add_reg(SPI0_SPI_REGS_ENABLE, 32'h0, "RW");

    this.SPI0_SPI_REGS_CONTROLS = SPI0_SPI_REGS_CONTROLS_::type_id::create("SPI0_SPI_REGS_CONTROLS");
    this.SPI0_SPI_REGS_CONTROLS.build();
    this.SPI0_SPI_REGS_CONTROLS.configure(this);
    this.SPI0_SPI_REGS_CONTROLS.add_hdl_path_slice("SPI0_SPI_REGS_CONTROLS", 32'h4, 32);
    MAP_APB.add_reg(SPI0_SPI_REGS_CONTROLS, 32'h4, "RW");

    this.SPI0_SPI_REGS_INTERRUPT = SPI0_SPI_REGS_INTERRUPT_::type_id::create("SPI0_SPI_REGS_INTERRUPT");
    this.SPI0_SPI_REGS_INTERRUPT.build();
    this.SPI0_SPI_REGS_INTERRUPT.configure(this);
    this.SPI0_SPI_REGS_INTERRUPT.add_hdl_path_slice("SPI0_SPI_REGS_INTERRUPT", 32'h8, 32);
    MAP_APB.add_reg(SPI0_SPI_REGS_INTERRUPT, 32'h8, "RW");

    this.SPI0_SPI_REGS_WDATA = SPI0_SPI_REGS_WDATA_::type_id::create("SPI0_SPI_REGS_WDATA");
    this.SPI0_SPI_REGS_WDATA.build();
    this.SPI0_SPI_REGS_WDATA.configure(this);
    this.SPI0_SPI_REGS_WDATA.add_hdl_path_slice("SPI0_SPI_REGS_WDATA", 32'hc, 32);
    MAP_APB.add_reg(SPI0_SPI_REGS_WDATA, 32'hc, "WO");

    this.SPI0_SPI_REGS_RDATA = SPI0_SPI_REGS_RDATA_::type_id::create("SPI0_SPI_REGS_RDATA");
    this.SPI0_SPI_REGS_RDATA.build();
    this.SPI0_SPI_REGS_RDATA.configure(this);
    this.SPI0_SPI_REGS_RDATA.add_hdl_path_slice("SPI0_SPI_REGS_RDATA", 32'h10, 32);
    MAP_APB.add_reg(SPI0_SPI_REGS_RDATA, 32'h10, "RO");

    this.SPI0_SPI_REGS_STATUS = SPI0_SPI_REGS_STATUS_::type_id::create("SPI0_SPI_REGS_STATUS");
    this.SPI0_SPI_REGS_STATUS.build();
    this.SPI0_SPI_REGS_STATUS.configure(this);
    this.SPI0_SPI_REGS_STATUS.add_hdl_path_slice("SPI0_SPI_REGS_STATUS", 32'h14, 32);
    MAP_APB.add_reg(SPI0_SPI_REGS_STATUS, 32'h14, "RO");

    this.SPI1_SPI_REGS_ENABLE = SPI1_SPI_REGS_ENABLE_::type_id::create("SPI1_SPI_REGS_ENABLE");
    this.SPI1_SPI_REGS_ENABLE.build();
    this.SPI1_SPI_REGS_ENABLE.configure(this);
    this.SPI1_SPI_REGS_ENABLE.add_hdl_path_slice("SPI1_SPI_REGS_ENABLE", 32'h100, 32);
    MAP_APB.add_reg(SPI1_SPI_REGS_ENABLE, 32'h100, "RW");

    this.SPI1_SPI_REGS_CONTROLS = SPI1_SPI_REGS_CONTROLS_::type_id::create("SPI1_SPI_REGS_CONTROLS");
    this.SPI1_SPI_REGS_CONTROLS.build();
    this.SPI1_SPI_REGS_CONTROLS.configure(this);
    this.SPI1_SPI_REGS_CONTROLS.add_hdl_path_slice("SPI1_SPI_REGS_CONTROLS", 32'h104, 32);
    MAP_APB.add_reg(SPI1_SPI_REGS_CONTROLS, 32'h104, "RW");

    this.SPI1_SPI_REGS_INTERRUPT = SPI1_SPI_REGS_INTERRUPT_::type_id::create("SPI1_SPI_REGS_INTERRUPT");
    this.SPI1_SPI_REGS_INTERRUPT.build();
    this.SPI1_SPI_REGS_INTERRUPT.configure(this);
    this.SPI1_SPI_REGS_INTERRUPT.add_hdl_path_slice("SPI1_SPI_REGS_INTERRUPT", 32'h108, 32);
    MAP_APB.add_reg(SPI1_SPI_REGS_INTERRUPT, 32'h108, "RW");

    this.SPI1_SPI_REGS_WDATA = SPI1_SPI_REGS_WDATA_::type_id::create("SPI1_SPI_REGS_WDATA");
    this.SPI1_SPI_REGS_WDATA.build();
    this.SPI1_SPI_REGS_WDATA.configure(this);
    this.SPI1_SPI_REGS_WDATA.add_hdl_path_slice("SPI1_SPI_REGS_WDATA", 32'h10c, 32);
    MAP_APB.add_reg(SPI1_SPI_REGS_WDATA, 32'h10c, "WO");

    this.SPI1_SPI_REGS_RDATA = SPI1_SPI_REGS_RDATA_::type_id::create("SPI1_SPI_REGS_RDATA");
    this.SPI1_SPI_REGS_RDATA.build();
    this.SPI1_SPI_REGS_RDATA.configure(this);
    this.SPI1_SPI_REGS_RDATA.add_hdl_path_slice("SPI1_SPI_REGS_RDATA", 32'h110, 32);
    MAP_APB.add_reg(SPI1_SPI_REGS_RDATA, 32'h110, "RO");

    this.SPI1_SPI_REGS_STATUS = SPI1_SPI_REGS_STATUS_::type_id::create("SPI1_SPI_REGS_STATUS");
    this.SPI1_SPI_REGS_STATUS.build();
    this.SPI1_SPI_REGS_STATUS.configure(this);
    this.SPI1_SPI_REGS_STATUS.add_hdl_path_slice("SPI1_SPI_REGS_STATUS", 32'h114, 32);
    MAP_APB.add_reg(SPI1_SPI_REGS_STATUS, 32'h114, "RO");

    this.I2C0_I2C_REGS_ENABLE = I2C0_I2C_REGS_ENABLE_::type_id::create("I2C0_I2C_REGS_ENABLE");
    this.I2C0_I2C_REGS_ENABLE.build();
    this.I2C0_I2C_REGS_ENABLE.configure(this);
    this.I2C0_I2C_REGS_ENABLE.add_hdl_path_slice("I2C0_I2C_REGS_ENABLE", 32'h200, 32);
    MAP_APB.add_reg(I2C0_I2C_REGS_ENABLE, 32'h200, "RW");

    this.I2C0_I2C_REGS_INTERRUPT = I2C0_I2C_REGS_INTERRUPT_::type_id::create("I2C0_I2C_REGS_INTERRUPT");
    this.I2C0_I2C_REGS_INTERRUPT.build();
    this.I2C0_I2C_REGS_INTERRUPT.configure(this);
    this.I2C0_I2C_REGS_INTERRUPT.add_hdl_path_slice("I2C0_I2C_REGS_INTERRUPT", 32'h204, 32);
    MAP_APB.add_reg(I2C0_I2C_REGS_INTERRUPT, 32'h204, "RW");

    this.I2C0_I2C_REGS_SLAVE_ADDR = I2C0_I2C_REGS_SLAVE_ADDR_::type_id::create("I2C0_I2C_REGS_SLAVE_ADDR");
    this.I2C0_I2C_REGS_SLAVE_ADDR.build();
    this.I2C0_I2C_REGS_SLAVE_ADDR.configure(this);
    this.I2C0_I2C_REGS_SLAVE_ADDR.add_hdl_path_slice("I2C0_I2C_REGS_SLAVE_ADDR", 32'h208, 32);
    MAP_APB.add_reg(I2C0_I2C_REGS_SLAVE_ADDR, 32'h208, "RW");

    this.I2C0_I2C_REGS_WDATA = I2C0_I2C_REGS_WDATA_::type_id::create("I2C0_I2C_REGS_WDATA");
    this.I2C0_I2C_REGS_WDATA.build();
    this.I2C0_I2C_REGS_WDATA.configure(this);
    this.I2C0_I2C_REGS_WDATA.add_hdl_path_slice("I2C0_I2C_REGS_WDATA", 32'h20c, 32);
    MAP_APB.add_reg(I2C0_I2C_REGS_WDATA, 32'h20c, "WO");

    this.I2C0_I2C_REGS_RDATA = I2C0_I2C_REGS_RDATA_::type_id::create("I2C0_I2C_REGS_RDATA");
    this.I2C0_I2C_REGS_RDATA.build();
    this.I2C0_I2C_REGS_RDATA.configure(this);
    this.I2C0_I2C_REGS_RDATA.add_hdl_path_slice("I2C0_I2C_REGS_RDATA", 32'h210, 32);
    MAP_APB.add_reg(I2C0_I2C_REGS_RDATA, 32'h210, "RO");

    this.I2C0_I2C_REGS_STATUS = I2C0_I2C_REGS_STATUS_::type_id::create("I2C0_I2C_REGS_STATUS");
    this.I2C0_I2C_REGS_STATUS.build();
    this.I2C0_I2C_REGS_STATUS.configure(this);
    this.I2C0_I2C_REGS_STATUS.add_hdl_path_slice("I2C0_I2C_REGS_STATUS", 32'h214, 32);
    MAP_APB.add_reg(I2C0_I2C_REGS_STATUS, 32'h214, "RO");

    this.lock_model();
  endfunction
endclass
