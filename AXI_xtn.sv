class AXI_xtn extends uvm_sequence_item;

	`uvm_object_utils(AXI_xtn)

	// Write Address Channel Signals (AW)
	rand bit [7:0] awid;
	rand bit [31:0] awaddr;
	rand bit [7:0]	awlen;
	rand bit [2:0] awsize;
	rand bit [1:0] awburst;
	rand bit awvalid;
	bit awready;

	// Write Data Channel Signals (W)
	rand bit [7:0] wid;
	rand bit [63:0] wdata []; //Dynamic to denote multiple data in single transfer
	rand bit [7:0] wstrb []; //Dynamic to denote multiple data byte line position in single transfer
	rand bit wlast;
	rand bit wvalid;
	bit wready;

	// Write Response Channel Signals (B)
	bit [7:0] bid;
	bit [1:0] bresp;
	bit bvalid;
	rand bit bready;

	// Read Address Channel Signals (AR)
	rand bit [7:0] arid;
	rand bit [31:0] araddr;
	rand bit [7:0] arlen;
	rand bit [2:0] arsize;
	rand bit [1:0] arburst;
	rand bit arvalid;
	bit arready;

	// Read Data Channel Signals (R)
	bit [7:0] rid;
	bit [63:0] rdata []; // Dynamic to denote multiple data in single transfer
	bit [1:0] rresp[];
	bit rlast;
	bit rvalid;
	rand bit rready;

	// Additional variable for accessibilty
	bit [63:0] temp_wdata;
	bit [63:0] temp_rdata;
	int delay_cycles = 1;

	// ID remains same for write channels and read channels
	constraint write_id {wid == awid; bid == awid;}
	constraint read_id {rid == arid;}
	
	// Valid burst sizes (0 == FIXED, 1 == INCR, 2 == WRAP)
	constraint write_burst {awburst inside {0, 1, 2};}
	constraint read_burst {arburst inside {0, 1, 2};}

	// Valid sizes (maximum number of bytes in transfer) [Here, 64 bits == 8 bytes]
	constraint write_size {awsize inside {0, 1, 2, 3};}
	constraint read_size {arsize inside {0, 1, 2, 3};}

	// AXI4: WRAP burst length must be exactly 2, 4, 8 or 16 beats (awlen/arlen == 1,3,7,15)
	constraint write_wrap_len_legal {(awburst == 2'b10) -> awlen inside {1, 3, 7, 15};}
	constraint read_wrap_len_legal  {(arburst == 2'b10) -> arlen inside {1, 3, 7, 15};}

	// AXI4: WRAP start address must be aligned to the *whole wrap window*
	// (size_in_bytes * burst_length), not just to the transfer size.
	constraint write_align {(awburst == 2'b10) -> (awaddr % ((1 << awsize) * (awlen + 1)) == 0);}
	constraint read_align  {(arburst == 2'b10) -> (araddr % ((1 << arsize) * (arlen + 1)) == 0);}

	// Assign size to wdata based on awlen (No of transfers)
	constraint wdata_len {wdata.size() == awlen + 1;}

	function new (string name = "AXI_xtn");
		super.new(name);
	endfunction

	function void post_randomize();
		
		int j = 0;
		bit [31:0] start_addr = awaddr;
		int num_of_bytes = 2 ** awsize;
		int burst_len = awlen + 1;
		bit [31:0] aligned_addr = (start_addr/num_of_bytes) * num_of_bytes;
		wstrb = new[awlen+1];

		for (int i = (start_addr % 8); i < (aligned_addr % 8) + num_of_bytes; i++)
			begin
				wstrb [j][i] = 1'b1;
			end

		for (int l = 1; l < burst_len; l++)
			begin
				aligned_addr = aligned_addr + num_of_bytes;
				j++;
				for (int k = (aligned_addr % 8); k < (aligned_addr % 8) + num_of_bytes; k++)
					wstrb [j][k] = 1'b1;
			end

	endfunction

	function void do_print(uvm_printer printer);
		printer.print_field("AWID", awid, 8, UVM_DEC);
		printer.print_field("AWADDR", awaddr, 32, UVM_HEX);
		printer.print_field("AWLEN", awlen, 8, UVM_DEC);
		printer.print_field("AWSIZE", awsize, 3, UVM_DEC);
		printer.print_field("AWBURST", awburst, 2, UVM_DEC);
		printer.print_field("AWVALID", awvalid, 1, UVM_BIN);
		printer.print_field("AWREADY", awready, 1, UVM_BIN);
		
		printer.print_field("WID", wid, 8, UVM_DEC);
		foreach (wdata[i])
			printer.print_field($sformatf("WDATA[%0d]", i), wdata[i], 64, UVM_HEX);
		foreach (wstrb[i])
			printer.print_field($sformatf("WSTRB[%0d]", i), wstrb[i], 8, UVM_BIN);
		printer.print_field("WLAST", wlast, 1, UVM_BIN);
		printer.print_field("WVALID", wvalid, 1, UVM_BIN);
		printer.print_field("WREADY", wready, 1, UVM_BIN);

		printer.print_field("BID", bid, 8, UVM_DEC);
		printer.print_field("BRESP", bresp, 1, UVM_BIN);
		printer.print_field("BVALID", bvalid, 1, UVM_BIN);
		printer.print_field("BREADY", bready, 1, UVM_BIN);
		
		printer.print_field("ARID", arid, 8, UVM_DEC);
		printer.print_field("ARADDR", araddr, 32, UVM_DEC);
		printer.print_field("ARLEN", arlen, 8, UVM_DEC);
		printer.print_field("ARSIZE", arsize, 3, UVM_DEC);
		printer.print_field("ARBURST", arburst, 2, UVM_DEC);
		printer.print_field("ARVALID", arvalid, 1, UVM_BIN);
		printer.print_field("ARREADY", arready, 1, UVM_BIN);

		printer.print_field("RID", rid, 8, UVM_DEC);
		foreach (rdata[i])
			printer.print_field($sformatf("RDATA[%0d]", i), rdata[i], 64, UVM_DEC);
		foreach (rresp[i])
			printer.print_field($sformatf("RRESP[%0d]", i), rresp[i], 2, UVM_DEC);
		printer.print_field("RLAST", rlast, 1, UVM_BIN);
		printer.print_field("RVALID", rvalid, 1, UVM_BIN);
		printer.print_field("RREADY", rready, 1, UVM_BIN);
		
	endfunction

endclass

