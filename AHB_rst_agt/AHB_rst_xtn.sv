class AHB_rst_xtn extends uvm_sequence_item;

	`uvm_object_utils(AHB_rst_xtn)

	rand bit hresetn;
	rand bit hready;
	logic [1:0] htrans;

	function new (string name = "AHB_rst_xtn");
		super.new(name);
	endfunction

	function void do_print(uvm_printer printer);
		printer.print_field("HRESETn", hresetn, 1, UVM_BIN);
		printer.print_field("HREADY", hready, 1, UVM_BIN);
		printer.print_field("HTRANS", htrans, 2, UVM_BIN);
	endfunction

endclass

