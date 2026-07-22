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

