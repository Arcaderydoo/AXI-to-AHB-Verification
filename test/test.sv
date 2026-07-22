class test extends uvm_test;

	`uvm_component_utils(test)

	env_config env_cfg;
	env envh;
	int len;

	AXI_rst_seqs axi_rst_seqh;
	AHB_rst_seqs ahb_rst_seqh;

	function new (string name = "test", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		env_cfg = env_config::type_id::create("env_cfg", this);
		env_cfg.no_of_duts = 1;
		env_cfg.has_scoreboard = 1;
		env_cfg.has_virtual_sequencer = 0;
		
		uvm_config_db #(env_config)::set(this, "*", "env_cfg", env_cfg);

		len = 4;
		uvm_config_db #(int)::set(this, "*", "len", len);
		
		envh = env::type_id::create("env", this);
	endfunction

	function void end_of_elaboration_phase (uvm_phase phase);
		uvm_top.print_topology;
	endfunction

	task run_phase (uvm_phase phase);
		axi_rst_seqh = AXI_rst_seqs::type_id::create("axi_rst_seqh");
		ahb_rst_seqh = AHB_rst_seqs::type_id::create("ahb_rst_seqh");
		phase.raise_objection(this);
		fork
		axi_rst_seqh.start(envh.AXI_rst_agth[0].seqrh);
		ahb_rst_seqh.start(envh.AHB_rst_agth[0].seqrh);
		join
		phase.drop_objection(this);
	endtask

endclass

class AXI_rst_test extends test;

	`uvm_component_utils(AXI_rst_test)

	AXI_rst_seqs axi_rst_seqh;

	function new (string name = "AXI_rst_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	task run_phase (uvm_phase phase);
		axi_rst_seqh = AXI_rst_seqs::type_id::create("axi_rst_seqh");
		phase.raise_objection(this, get_type_name());
		axi_rst_seqh.start(envh.AXI_rst_agth[0].seqrh);
		phase.drop_objection(this, get_type_name());
	endtask

endclass

class AHB_rst_test extends test;

	`uvm_component_utils(AHB_rst_test)

	AHB_rst_seqs ahb_rst_seqh;

	function new (string name = "AHB_rst_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	task run_phase (uvm_phase phase);
		ahb_rst_seqh = AHB_rst_seqs::type_id::create("ahb_rst_seqh");
		phase.raise_objection(this, get_type_name());
		ahb_rst_seqh.start(envh.AHB_rst_agth[0].seqrh);
		phase.drop_objection(this, get_type_name());
	endtask

endclass

class AXI_fixed_test extends test;

	`uvm_component_utils(AXI_fixed_test)

	AXI_fixed_seqs seqh;

	function new (string name = "AXI_fixed_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	task run_phase (uvm_phase phase);
		super.run_phase(phase);
		seqh = AXI_fixed_seqs::type_id::create("seqh");
		phase.raise_objection(this);
		seqh.start(envh.AXI_agth[0].seqrh);
		phase.drop_objection(this);
	endtask

endclass

class AXI_increment_test extends test;

	`uvm_component_utils(AXI_increment_test)

	AXI_inc_seqs axi_inc_seqh;

	function new (string name = "AXI_increment_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	task run_phase (uvm_phase phase);
		super.run_phase(phase);
		axi_inc_seqh = AXI_inc_seqs::type_id::create("axi_inc_seqh");
		phase.raise_objection(this);
		axi_inc_seqh.start(envh.AXI_agth[0].seqrh);
		#1000;
		phase.drop_objection(this);
	endtask

endclass

class AXI_wrapped_test extends test;

	`uvm_component_utils(AXI_wrapped_test)

	AXI_wrap_seqs axi_wrap_seqh;

	function new (string name = "AXI_wrapped_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	task run_phase (uvm_phase phase);
		super.run_phase(phase);
		axi_wrap_seqh = AXI_wrap_seqs::type_id::create("axi_wrap_seqh");
		phase.raise_objection(this);
		axi_wrap_seqh.start(envh.AXI_agth[0].seqrh);
		#1000;
		phase.drop_objection(this);
	endtask

endclass

class AHB_normal_test extends test;
	
	`uvm_component_utils(AHB_normal_test)

	AXI_wrap_seqs axi_wrap_seqh;
	AHB_normal_seqs ahb_normal_seqh;

	function new (string name = "AHB_normal_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	task run_phase (uvm_phase phase);
		super.run_phase(phase);
		axi_wrap_seqh = AXI_wrap_seqs::type_id::create("axi_wrap_seqh");
		ahb_normal_seqh = AHB_normal_seqs::type_id::create("ahb_normal_seqh");
		phase.raise_objection(this);
		fork
			axi_wrap_seqh.start(envh.AXI_agth[0].seqrh);
			ahb_normal_seqh.start(envh.AHB_agth[0].seqrh);
		join
		#10000;
		phase.drop_objection(this);
	endtask

endclass
