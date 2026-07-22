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
	AHB_free_run_seqs ahb_bg_seqh;

	function new (string name = "AXI_fixed_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	task run_phase (uvm_phase phase);
		super.run_phase(phase);
		seqh = AXI_fixed_seqs::type_id::create("seqh");
		ahb_bg_seqh = AHB_free_run_seqs::type_id::create("ahb_bg_seqh");
		phase.raise_objection(this);
		fork
			ahb_bg_seqh.start(envh.AHB_agth[0].seqrh);
		join_none
		seqh.start(envh.AXI_agth[0].seqrh);
		phase.drop_objection(this);
	endtask

endclass

class AXI_increment_test extends test;

	`uvm_component_utils(AXI_increment_test)

	AXI_inc_seqs axi_inc_seqh;
	AHB_free_run_seqs ahb_bg_seqh;

	function new (string name = "AXI_increment_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	task run_phase (uvm_phase phase);
		super.run_phase(phase);
		axi_inc_seqh = AXI_inc_seqs::type_id::create("axi_inc_seqh");
		ahb_bg_seqh = AHB_free_run_seqs::type_id::create("ahb_bg_seqh");
		phase.raise_objection(this);
		fork
			ahb_bg_seqh.start(envh.AHB_agth[0].seqrh);
		join_none
		axi_inc_seqh.start(envh.AXI_agth[0].seqrh);
		#1000;
		phase.drop_objection(this);
	endtask

endclass

class AXI_wrapped_test extends test;

	`uvm_component_utils(AXI_wrapped_test)

	AXI_wrap_seqs axi_wrap_seqh;
	AHB_free_run_seqs ahb_bg_seqh;

	function new (string name = "AXI_wrapped_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	task run_phase (uvm_phase phase);
		super.run_phase(phase);
		axi_wrap_seqh = AXI_wrap_seqs::type_id::create("axi_wrap_seqh");
		ahb_bg_seqh = AHB_free_run_seqs::type_id::create("ahb_bg_seqh");
		phase.raise_objection(this);
		fork
			ahb_bg_seqh.start(envh.AHB_agth[0].seqrh);
		join_none
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

//=============================================================================
// Burst / length sweep tests.
// Each forks an AHB_free_run_seqs in the background (fork ... join_none) so
// the responder side never runs dry no matter how many beats/bursts the
// foreground AXI sequence issues, then runs the directed sweep to completion
// before dropping the objection.
//=============================================================================

class AXI_fixed_sweep_test extends test;

	`uvm_component_utils(AXI_fixed_sweep_test)

	AXI_fixed_sweep_seqs seqh;
	AHB_free_run_seqs ahb_bg_seqh;

	function new (string name = "AXI_fixed_sweep_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	task run_phase (uvm_phase phase);
		super.run_phase(phase);
		seqh = AXI_fixed_sweep_seqs::type_id::create("seqh");
		ahb_bg_seqh = AHB_free_run_seqs::type_id::create("ahb_bg_seqh");
		phase.raise_objection(this);
		fork
			ahb_bg_seqh.start(envh.AHB_agth[0].seqrh);
		join_none
		seqh.start(envh.AXI_agth[0].seqrh);
		phase.drop_objection(this);
	endtask

endclass

class AXI_inc_sweep_test extends test;

	`uvm_component_utils(AXI_inc_sweep_test)

	AXI_inc_sweep_seqs seqh;
	AHB_free_run_seqs ahb_bg_seqh;

	function new (string name = "AXI_inc_sweep_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	task run_phase (uvm_phase phase);
		super.run_phase(phase);
		seqh = AXI_inc_sweep_seqs::type_id::create("seqh");
		ahb_bg_seqh = AHB_free_run_seqs::type_id::create("ahb_bg_seqh");
		phase.raise_objection(this);
		fork
			ahb_bg_seqh.start(envh.AHB_agth[0].seqrh);
		join_none
		seqh.start(envh.AXI_agth[0].seqrh);
		phase.drop_objection(this);
	endtask

endclass

class AXI_wrap_sweep_test extends test;

	`uvm_component_utils(AXI_wrap_sweep_test)

	AXI_wrap_sweep_seqs seqh;
	AHB_free_run_seqs ahb_bg_seqh;

	function new (string name = "AXI_wrap_sweep_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	task run_phase (uvm_phase phase);
		super.run_phase(phase);
		seqh = AXI_wrap_sweep_seqs::type_id::create("seqh");
		ahb_bg_seqh = AHB_free_run_seqs::type_id::create("ahb_bg_seqh");
		phase.raise_objection(this);
		fork
			ahb_bg_seqh.start(envh.AHB_agth[0].seqrh);
		join_none
		seqh.start(envh.AXI_agth[0].seqrh);
		phase.drop_objection(this);
	endtask

endclass

// The one to run when you want the whole length x burst x size space closed
// in a single test: FIXED sweep, then INCR sweep, then WRAP sweep.
class AXI_all_burst_len_test extends test;

	`uvm_component_utils(AXI_all_burst_len_test)

	AXI_all_burst_len_seqs seqh;
	AHB_free_run_seqs ahb_bg_seqh;

	function new (string name = "AXI_all_burst_len_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	task run_phase (uvm_phase phase);
		super.run_phase(phase);
		seqh = AXI_all_burst_len_seqs::type_id::create("seqh");
		ahb_bg_seqh = AHB_free_run_seqs::type_id::create("ahb_bg_seqh");
		phase.raise_objection(this);
		fork
			ahb_bg_seqh.start(envh.AHB_agth[0].seqrh);
		join_none
		seqh.start(envh.AXI_agth[0].seqrh);
		phase.drop_objection(this);
	endtask

endclass

// Randomized complement to the directed sweep: same background responder,
// but the AXI-side burst/length/size combinations are left to the solver
// across many iterations instead of being deterministically nested.
class AXI_random_burst_len_test extends test;

	`uvm_component_utils(AXI_random_burst_len_test)

	AXI_random_burst_len_seqs seqh;
	AHB_free_run_seqs ahb_bg_seqh;

	function new (string name = "AXI_random_burst_len_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	task run_phase (uvm_phase phase);
		super.run_phase(phase);
		seqh = AXI_random_burst_len_seqs::type_id::create("seqh");
		ahb_bg_seqh = AHB_free_run_seqs::type_id::create("ahb_bg_seqh");
		phase.raise_objection(this);
		fork
			ahb_bg_seqh.start(envh.AHB_agth[0].seqrh);
		join_none
		seqh.start(envh.AXI_agth[0].seqrh);
		phase.drop_objection(this);
	endtask

endclass

// Bonus corner-case test: INCR bursts longer than the 16-deep FIFOs, to
// exercise awready/wready backpressure mid-burst. Write-only (arvalid==0
// in the sequence), so the background AHB responder only needs to service
// the write side here.
class AXI_incr_backpressure_test extends test;

	`uvm_component_utils(AXI_incr_backpressure_test)

	AXI_incr_backpressure_seqs seqh;
	AHB_free_run_seqs ahb_bg_seqh;

	function new (string name = "AXI_incr_backpressure_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	task run_phase (uvm_phase phase);
		super.run_phase(phase);
		seqh = AXI_incr_backpressure_seqs::type_id::create("seqh");
		ahb_bg_seqh = AHB_free_run_seqs::type_id::create("ahb_bg_seqh");
		phase.raise_objection(this);
		fork
			ahb_bg_seqh.start(envh.AHB_agth[0].seqrh);
		join_none
		seqh.start(envh.AXI_agth[0].seqrh);
		phase.drop_objection(this);
	endtask

endclass
