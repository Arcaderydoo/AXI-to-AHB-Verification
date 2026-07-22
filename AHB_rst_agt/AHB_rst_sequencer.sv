class AHB_rst_sequencer extends uvm_sequencer #(AHB_rst_xtn);

	`uvm_component_utils(AHB_rst_sequencer)

	function new (string name = "AHB_rst_sequencer", uvm_component parent);
		super.new(name, parent);
	endfunction

endclass

