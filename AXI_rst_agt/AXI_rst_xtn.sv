class AXI_rst_xtn extends uvm_sequence_item;

	`uvm_object_utils(AXI_rst_xtn)

	rand bit aresetn;
	
	logic bvalid;
	logic rvalid;

	function new (string name = "AXI_rst_xtn");
		super.new(name);
	endfunction

	function void do_print(uvm_printer printer);
		printer.print_field("ARESETn", aresetn, 1, UVM_BIN);
		printer.print_field("BVALID", bvalid, 1, UVM_BIN);
		printer.print_field("RVALID", rvalid, 1, UVM_BIN);
	endfunction
	
endclass
