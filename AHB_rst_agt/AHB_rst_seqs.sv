class AHB_rst_seqs extends uvm_sequence #(AHB_rst_xtn);

	`uvm_object_utils(AHB_rst_seqs)

	function new (string name = "AHB_rst_seqs");
		super.new(name);
	endfunction

	task body;
		req = AHB_rst_xtn::type_id::create("req");

		start_item(req);
		assert(req.randomize() with {hresetn == 1'b0; hready == 1'b1;})
		finish_item(req);
			
		start_item(req);
		assert(req.randomize() with {hresetn == 1'b1; hready == 1'b0;})
		finish_item(req);

	endtask

endclass

