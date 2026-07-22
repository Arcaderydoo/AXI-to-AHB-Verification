class env_config extends uvm_object;
	
	`uvm_object_utils(env_config)
	
	function new (string name = "env_config");
		super.new(name);
	endfunction

	int no_of_duts = 1;
	int has_scoreboard = 1;
	int has_virtual_sequencer = 0;
	int ahb_len [$];

endclass

