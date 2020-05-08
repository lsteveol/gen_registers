//===================================================================
//
// Created by sbridges on May/08/2020 at 07:07:04
//
// test_reg_model.sv
//
//===================================================================



// System:  @ 0x0
//   RegBlock: (MY_REG)                                 @ 0x0



// RegBlock 
class MY_REG_REG1_ extends uvm_reg;
  `uvm_object_utils(MY_REG_REG1_)

  rand uvm_reg_field RW_BF2_MUX;
  rand uvm_reg_field RW_BF2;
  rand uvm_reg_field RW_BF1;

  function new (string name = "MY_REG_REG1_");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  //Addr        : 0x0        (Includes Map Offset)
  //Map         : MAP_APB     0x0
  //Reset       : 0x8       
  //Description : 
  function void build;
    //Description: 
    RW_BF2_MUX = uvm_reg_field::type_id::create("RW_BF2_MUX");  //MY_REG_REG1__RW_BF2_MUX
    RW_BF2_MUX.configure(this, 1, 4, "RW", 0, 'h0, 1, 1, 0);
    //Description: rw_bf2 description
    RW_BF2 = uvm_reg_field::type_id::create("RW_BF2");  // MY_REG_REG1__RW_BF2
    RW_BF2.configure(this, 3, 1, "RW", 0, 'h4, 1, 1, 0);
    //Description: rw_bf1 description
    RW_BF1 = uvm_reg_field::type_id::create("RW_BF1");  // MY_REG_REG1__RW_BF1
    RW_BF1.configure(this, 1, 0, "RW", 0, 'h0, 1, 1, 0);
  endfunction
endclass

class MY_REG_REG2_ extends uvm_reg;
  `uvm_object_utils(MY_REG_REG2_)

  rand uvm_reg_field REG2_RO_BF2;
  rand uvm_reg_field REG2_RW_BF2;
  rand uvm_reg_field REG2_RO_BF1;
  rand uvm_reg_field REG2_RW_BF1;

  function new (string name = "MY_REG_REG2_");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  //Addr        : 0x4        (Includes Map Offset)
  //Map         : MAP_APB     0x0
  //Reset       : 0x2000    
  //Description : 
  function void build;
    //Description: 
    REG2_RO_BF2 = uvm_reg_field::type_id::create("REG2_RO_BF2");  //MY_REG_REG2__REG2_RO_BF2
    REG2_RO_BF2.configure(this, 1, 14, "RO", 0, 'h0, 1, 1, 0);
    //Description: 
    REG2_RW_BF2 = uvm_reg_field::type_id::create("REG2_RW_BF2");  //MY_REG_REG2__REG2_RW_BF2
    REG2_RW_BF2.configure(this, 1, 13, "RW", 0, 'h1, 1, 1, 0);
    //Description: 
    REG2_RO_BF1 = uvm_reg_field::type_id::create("REG2_RO_BF1");  //MY_REG_REG2__REG2_RO_BF1
    REG2_RO_BF1.configure(this, 5, 8, "RO", 0, 'h0, 1, 1, 0);
    //Description: 
    REG2_RW_BF1 = uvm_reg_field::type_id::create("REG2_RW_BF1");  //MY_REG_REG2__REG2_RW_BF1
    REG2_RW_BF1.configure(this, 8, 0, "RW", 0, 'h0, 1, 1, 0);
  endfunction
endclass

class MY_REG_REG3_ extends uvm_reg;
  `uvm_object_utils(MY_REG_REG3_)

  rand uvm_reg_field MY_WFIFO_REG;

  function new (string name = "MY_REG_REG3_");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  //Addr        : 0x8        (Includes Map Offset)
  //Map         : MAP_APB     0x0
  //Reset       : 0x0       
  //Description : 
  function void build;
    //Description: 
    MY_WFIFO_REG = uvm_reg_field::type_id::create("MY_WFIFO_REG");  //MY_REG_REG3__MY_WFIFO_REG
    MY_WFIFO_REG.configure(this, 8, 0, "WO", 0, 'h0, 1, 1, 0);
  endfunction
endclass

class MY_REG_REG4_ extends uvm_reg;
  `uvm_object_utils(MY_REG_REG4_)

  rand uvm_reg_field MY_RFIFO_REG;

  function new (string name = "MY_REG_REG4_");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  //Addr        : 0xc        (Includes Map Offset)
  //Map         : MAP_APB     0x0
  //Reset       : 0x0       
  //Description : 
  function void build;
    //Description: 
    MY_RFIFO_REG = uvm_reg_field::type_id::create("MY_RFIFO_REG");  //MY_REG_REG4__MY_RFIFO_REG
    MY_RFIFO_REG.configure(this, 8, 0, "RO", 0, 'h0, 1, 1, 0);
  endfunction
endclass

class MY_REG_REG5_ extends uvm_reg;
  `uvm_object_utils(MY_REG_REG5_)

  rand uvm_reg_field MY_W1C_BF;

  function new (string name = "MY_REG_REG5_");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  //Addr        : 0x10       (Includes Map Offset)
  //Map         : MAP_APB     0x0
  //Reset       : 0x0       
  //Description : 
  function void build;
    //Description: 
    MY_W1C_BF = uvm_reg_field::type_id::create("MY_W1C_BF");  //MY_REG_REG5__MY_W1C_BF
    MY_W1C_BF.configure(this, 1, 0, "W1C", 0, 'h0, 1, 1, 0);
  endfunction
endclass

class MY_REG_DEBUG_BUS_CTRL_ extends uvm_reg;
  `uvm_object_utils(MY_REG_DEBUG_BUS_CTRL_)

  rand uvm_reg_field DEBUG_BUS_CTRL_SEL;

  function new (string name = "MY_REG_DEBUG_BUS_CTRL_");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  //Addr        : 0x14       (Includes Map Offset)
  //Map         : MAP_APB     0x0
  //Reset       : 0x0       
  //Description : Debug observation bus selection for signals that have a mux override
  function void build;
    //Description: Select signal for DEBUG_BUS_CTRL
    DEBUG_BUS_CTRL_SEL = uvm_reg_field::type_id::create("DEBUG_BUS_CTRL_SEL");  //MY_REG_DEBUG_BUS_CTRL__DEBUG_BUS_CTRL_SEL
    DEBUG_BUS_CTRL_SEL.configure(this, 1, 0, "RW", 0, 'h0, 1, 1, 0);
  endfunction
endclass

class MY_REG_DEBUG_BUS_STATUS_ extends uvm_reg;
  `uvm_object_utils(MY_REG_DEBUG_BUS_STATUS_)

  rand uvm_reg_field DEBUG_BUS_CTRL_STATUS;

  function new (string name = "MY_REG_DEBUG_BUS_STATUS_");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  //Addr        : 0x18       (Includes Map Offset)
  //Map         : MAP_APB     0x0
  //Reset       : 0x0       
  //Description : Debug observation bus for signals that have a mux override
  function void build;
    //Description: Status output for DEBUG_BUS_STATUS
    DEBUG_BUS_CTRL_STATUS = uvm_reg_field::type_id::create("DEBUG_BUS_CTRL_STATUS");  //MY_REG_DEBUG_BUS_STATUS__DEBUG_BUS_CTRL_STATUS
    DEBUG_BUS_CTRL_STATUS.configure(this, 32, 0, "RO", 0, 'h0, 1, 1, 0);
  endfunction
endclass

class test_reg_model extends uvm_reg_block;
  `uvm_object_utils(test_reg_model)

  //RegBlock 
  rand MY_REG_REG1_                                       MY_REG_REG1;
  rand MY_REG_REG2_                                       MY_REG_REG2;
  rand MY_REG_REG3_                                       MY_REG_REG3;
  rand MY_REG_REG4_                                       MY_REG_REG4;
  rand MY_REG_REG5_                                       MY_REG_REG5;
  rand MY_REG_DEBUG_BUS_CTRL_                             MY_REG_DEBUG_BUS_CTRL;
  rand MY_REG_DEBUG_BUS_STATUS_                           MY_REG_DEBUG_BUS_STATUS;

  //Reg Map Declarations
  uvm_reg_map MAP_APB;

  function new (string name = "test_reg_model");
    super.new(name);
  endfunction

  function void build();

    MAP_APB      = create_map("MAP_APB", 32'h0, 4, UVM_LITTLE_ENDIAN);
    this.MY_REG_REG1 = MY_REG_REG1_::type_id::create("MY_REG_REG1");
    this.MY_REG_REG1.build();
    this.MY_REG_REG1.configure(this);
    this.MY_REG_REG1.add_hdl_path_slice("MY_REG_REG1", 32'h0, 32);
    MAP_APB.add_reg(MY_REG_REG1, 32'h0, "RW");

    this.MY_REG_REG2 = MY_REG_REG2_::type_id::create("MY_REG_REG2");
    this.MY_REG_REG2.build();
    this.MY_REG_REG2.configure(this);
    this.MY_REG_REG2.add_hdl_path_slice("MY_REG_REG2", 32'h4, 32);
    MAP_APB.add_reg(MY_REG_REG2, 32'h4, "RW");

    //THIS REG HAS BEEN DEFINED AS NO_REG_TEST
    this.MY_REG_REG3 = MY_REG_REG3_::type_id::create("MY_REG_REG3");
    this.MY_REG_REG3.build();
    this.MY_REG_REG3.configure(this);
    this.MY_REG_REG3.add_hdl_path_slice("MY_REG_REG3", 32'h8, 32);
    MAP_APB.add_reg(MY_REG_REG3, 32'h8, "WO");

    uvm_resource_db#(bit)::set(.scope("REG::*MY_REG_REG3"), .name("NO_REG_TESTS"), .val(1), .accessor(this));
    this.MY_REG_REG4 = MY_REG_REG4_::type_id::create("MY_REG_REG4");
    this.MY_REG_REG4.build();
    this.MY_REG_REG4.configure(this);
    this.MY_REG_REG4.add_hdl_path_slice("MY_REG_REG4", 32'hc, 32);
    MAP_APB.add_reg(MY_REG_REG4, 32'hc, "RO");

    this.MY_REG_REG5 = MY_REG_REG5_::type_id::create("MY_REG_REG5");
    this.MY_REG_REG5.build();
    this.MY_REG_REG5.configure(this);
    this.MY_REG_REG5.add_hdl_path_slice("MY_REG_REG5", 32'h10, 32);
    MAP_APB.add_reg(MY_REG_REG5, 32'h10, "RW");

    this.MY_REG_DEBUG_BUS_CTRL = MY_REG_DEBUG_BUS_CTRL_::type_id::create("MY_REG_DEBUG_BUS_CTRL");
    this.MY_REG_DEBUG_BUS_CTRL.build();
    this.MY_REG_DEBUG_BUS_CTRL.configure(this);
    this.MY_REG_DEBUG_BUS_CTRL.add_hdl_path_slice("MY_REG_DEBUG_BUS_CTRL", 32'h14, 32);
    MAP_APB.add_reg(MY_REG_DEBUG_BUS_CTRL, 32'h14, "RW");

    this.MY_REG_DEBUG_BUS_STATUS = MY_REG_DEBUG_BUS_STATUS_::type_id::create("MY_REG_DEBUG_BUS_STATUS");
    this.MY_REG_DEBUG_BUS_STATUS.build();
    this.MY_REG_DEBUG_BUS_STATUS.configure(this);
    this.MY_REG_DEBUG_BUS_STATUS.add_hdl_path_slice("MY_REG_DEBUG_BUS_STATUS", 32'h18, 32);
    MAP_APB.add_reg(MY_REG_DEBUG_BUS_STATUS, 32'h18, "RO");

    this.lock_model();
  endfunction
endclass
