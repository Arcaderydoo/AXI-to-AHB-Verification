class AXI_base_seqs extends uvm_sequence #(AXI_xtn);

	`uvm_object_utils(AXI_base_seqs)
	
	int len;

	function new (string name = "AXI_base_seqs");
		super.new(name);
		req = AXI_xtn::type_id::create("req");
	endfunction

	task body;
		if (!uvm_config_db #(int)::get(null, get_full_name(), "len", len))
			`uvm_info(get_full_name(), "cannot get length in AXI_seqs", UVM_LOW)
	endtask

endclass

class AXI_fixed_seqs extends AXI_base_seqs;

	`uvm_object_utils(AXI_fixed_seqs)

	function new (string name = "AXI_fixed_seqs");
		super.new(name);
	endfunction

	task body;
		super.body();	

		start_item(req);
		assert(req.randomize with {awvalid == 1'b1; wvalid == 1'b1; arvalid == 1'b1; awsize == 3'b000; awlen == len; awaddr == 2000;  bready == 1'b1; rready == 1'b1;});
		finish_item(req);

	endtask

endclass

class AXI_inc_seqs extends AXI_base_seqs;

	`uvm_object_utils(AXI_inc_seqs)

	function new (string name = "AXI_inc_seqs");
		super.new(name);
	endfunction

	task body;
		super.body();	
		start_item(req);
		assert(req.randomize with {awvalid == 1'b1; awburst == 2'b01; awlen == len; awsize == 3'd3;
		wvalid == 1'b1; arvalid == 1'b1; bready == 1'b1; rready == 1'b1;});
		finish_item(req);
	endtask

endclass


class AXI_wrap_seqs extends AXI_base_seqs;

	`uvm_object_utils(AXI_wrap_seqs)

	function new (string name = "AXI_wrap_seqs");
		super.new(name);
	endfunction

	task body;
		super.body();	
		start_item(req);
		assert(req.randomize with {awvalid == 1'b1; awaddr == 2000; awburst == 2'b10; awlen == len; awsize == 3'd0;
		wvalid == 1'b1; arvalid == 1'b1; bready == 1'b1; rready == 1'b1;});
		finish_item(req);
	endtask

endclass

