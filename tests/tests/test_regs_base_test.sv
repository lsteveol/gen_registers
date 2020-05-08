class test_regs_base_test extends uvm_test;
  
  
  gr_apb_env#(test_reg_model)    apb_env;
  
  `uvm_component_utils(test_regs_base_test)
  
  function new(string name = "test_regs_base_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction 
  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    apb_env    = gr_apb_env#(test_reg_model)::type_id::create("apb_env", this);
    
    
  endfunction
  
  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_table_printer printer;
    `uvm_info(get_type_name(),$psprintf("Printing the test topology :\n%s", this.sprint(printer)), UVM_LOW)
  endfunction
  
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction
  
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    //set a drain-time for the environment if desired
    phase.phase_done.set_drain_time(this, 50);

    `uvm_info(get_type_name(),$psprintf("Delay 200ns before running for reset time."), UVM_MEDIUM);
    #200ns;
    
  endtask

endclass
