class AXI_rst_seqs extends uvm_sequence #(AXI_rst_xtn);

	`uvm_object_utils(AXI_rst_seqs)

	function new (string name = "AXI_rst_seqs");
		super.new(name);
	endfunction

	task body;
		req = AXI_rst_xtn::type_id::create("req");
		
		start_item(req);
		assert(req.randomize() with {aresetn == 1'b0;});
		finish_item(req);

		start_item(req);
		assert(req.randomize() with {aresetn == 1'b1;});
		finish_item(req);

	endtask

endclass

