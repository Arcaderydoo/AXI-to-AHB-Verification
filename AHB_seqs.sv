class AHB_base_seqs extends uvm_sequence #(AHB_xtn);

	`uvm_object_utils(AHB_base_seqs)

	int len;

	function new (string name = "AHB_base_seqs");
		super.new(name);
		req = AHB_xtn::type_id::create("req");
	endfunction

	task body;
		if (!uvm_config_db #(int)::get(null, get_full_name(), "len", len))
			`uvm_info(get_full_name(), "cannot get length in AHB_seqs", UVM_LOW)
	endtask

endclass

class AHB_normal_seqs extends AHB_base_seqs;
	
	`uvm_object_utils(AHB_normal_seqs)

	function new (string name = "AHB_normal_seqs");
		super.new(name);
	endfunction

	task body;
		super.body();

		repeat (2 * len + 1) begin
			start_item(req);
			assert(req.randomize() with {delay_cycles == 4; cases == NORMAL;});
			finish_item(req);
		end
	endtask

endclass

class AHB_wait_seqs extends AHB_base_seqs;
	
	`uvm_object_utils(AHB_wait_seqs)

	function new (string name = "AHB_wait_seqs");
		super.new(name);
	endfunction

	task body;
		super.body();

		repeat (2 * len + 1) begin
			start_item(req);
			assert(req.randomize() with {delay_cycles == 4; cases == WAIT_STATES;});
			finish_item(req);
		end
	endtask

endclass

class AHB_err_seqs extends AHB_base_seqs;
	
	`uvm_object_utils(AHB_err_seqs)

	function new (string name = "AHB_err_seqs");
		super.new(name);
	endfunction

	task body;
		super.body();

		repeat (2 * len + 1) begin
			start_item(req);
			assert(req.randomize() with {delay_cycles == 4; cases == ERROR;});
			finish_item(req);
		end
	endtask

endclass

// Background AHB responder for the burst/length sweep tests: keeps supplying
// NORMAL (no wait-state) responses indefinitely so it can service an AXI
// sequence of any length or transaction count without needing a shared
// global 'len' to size the repeat count. Intended to be started with
// fork ... join_none and simply left running until the test drops its
// objection; there is no dependency on the config_db 'len' at all.
class AHB_free_run_seqs extends AHB_base_seqs;

	`uvm_object_utils(AHB_free_run_seqs)

	function new (string name = "AHB_free_run_seqs");
		super.new(name);
	endfunction

	task body;
		forever begin
			start_item(req);
			assert(req.randomize() with {delay_cycles inside {[2:6]}; cases == NORMAL;});
			finish_item(req);
		end
	endtask

endclass

