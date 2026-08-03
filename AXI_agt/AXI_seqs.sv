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

class AXI_write_fixed_seqs extends AXI_base_seqs;

	`uvm_object_utils(AXI_write_fixed_seqs)

	function new (string name = "AXI_write_fixed_seqs");
		super.new(name);
	endfunction

	task body;
		super.body();	

		start_item(req);
		assert(req.randomize with {awvalid == 1'b1; wvalid == 1'b1; arvalid == 1'b0; awsize == 3'd0; awburst == 2'b00; awlen == len; awaddr == 32'haa;  bready == 1'b1; rready == 1'b0;});
		finish_item(req);

	endtask

endclass

class AXI_write_inc_seqs extends AXI_base_seqs;

	`uvm_object_utils(AXI_write_inc_seqs)

	function new (string name = "AXI_write_inc_seqs");
		super.new(name);
	endfunction

	task body;
		super.body();	
		start_item(req);
		assert(req.randomize with {awvalid == 1'b1; awburst == 2'b01; awlen == len; awsize == 3'd1;
		wvalid == 1'b1; arvalid == 1'b0; bready == 1'b1; rready == 1'b0;});
		finish_item(req);
	endtask

endclass


class AXI_write_wrap_seqs extends AXI_base_seqs;

	`uvm_object_utils(AXI_write_wrap_seqs)

	function new (string name = "AXI_write_wrap_seqs");
		super.new(name);
	endfunction

	task body;
		super.body();	
		start_item(req);
		assert(req.randomize with {awvalid == 1'b1; awaddr == 2000; awburst == 2'b10; awlen == len; awsize == 3'd2;
		wvalid == 1'b1; arvalid == 1'b0; araddr == 2000; arlen == len; arsize == 3'd0; arburst == 2'b10;  bready == 1'b1; rready == 1'b0;});
		finish_item(req);
	endtask

endclass

class AXI_read_fixed_seqs extends AXI_base_seqs;

	`uvm_object_utils(AXI_read_fixed_seqs)

	function new (string name = "AXI_read_fixed_seqs");
		super.new(name);
	endfunction

	task body;
		super.body();
		start_item(req);
		assert(req.randomize with {awvalid == 1'b0; awlen == 0; wvalid == 1'b0; bready == 1'b0; arvalid == 1'b1; araddr == 2000; arlen == len; arsize == 3'd1; arburst == 2'b00; rready == 1'b1;});
		finish_item(req);
	endtask

endclass

class AXI_read_increment_seqs extends AXI_base_seqs;

	`uvm_object_utils(AXI_read_increment_seqs)

	function new (string name = "AXI_read_increment_seqs");
		super.new(name);
	endfunction

	task body;
		super.body();
		start_item(req);
		assert(req.randomize with {awvalid == 1'b0; awlen == 0; wvalid == 1'b0; bready == 1'b0; arvalid == 1'b1; araddr == 2000; arlen == len; arsize == 3'd2; arburst == 2'b01; rready == 1'b1;});
		finish_item(req);
	endtask

endclass

