class AXI_rst_sequencer extends uvm_sequencer #(AXI_rst_xtn);

	`uvm_component_utils(AXI_rst_sequencer)

	function new (string name = "AXI_rst_sequencer", uvm_component parent);
		super.new(name, parent);
	endfunction

endclass

