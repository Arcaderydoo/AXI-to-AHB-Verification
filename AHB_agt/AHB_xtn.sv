class AHB_xtn extends uvm_sequence_item;

	`uvm_object_utils(AHB_xtn)

	bit [31:0] haddr;
	bit htrans;
	bit hwrite;
	bit [2:0] hsize;
	bit [2:0] hburst;
	bit [63:0] hwdata;
	bit hbusreq;
	bit hlock;
	
	rand bit [63:0] hrdata;
	rand bit hready;
	rand bit hresp;
	rand bit hgrant;
	rand bit [3:0] hmaster;

	rand bit [7:0] delay_cycles;
	rand enum {NORMAL, WAIT_STATES, ERROR} cases;

	constraint delay_count {delay_cycles inside {[2:10]};}

	function new (string name = "AHB_xtn");
		super.new(name);
	endfunction

	function void do_print(uvm_printer printer);
		printer.print_field("HADDR", haddr, 32, UVM_HEX);
		printer.print_field("HWRITE", hwrite, 1, UVM_BIN);
		printer.print_field("HTRANS", htrans, 2, UVM_BIN);
		printer.print_field("HSIZE", hsize, 3, UVM_DEC);
		printer.print_field("HBURST", hburst, 3, UVM_DEC);
		printer.print_field("HWDATA", hwdata, 64, UVM_HEX);
		printer.print_field("HBUSREQ", hbusreq, 1, UVM_BIN);
		printer.print_field("HLOCK", hlock, 1, UVM_BIN);
		printer.print_field("HREADY", hready, 1, UVM_BIN);
		printer.print_field("HRDATA", hrdata, 64, UVM_HEX);
		printer.print_field("HRESP", hresp, 1, UVM_BIN);
		printer.print_field("HGRANT", hgrant, 1, UVM_BIN);
		printer.print_field("HMASTER", hmaster, 4, UVM_HEX);
	endfunction

endclass
