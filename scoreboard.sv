class scoreboard extends uvm_scoreboard;

	`uvm_component_utils(scoreboard)

	uvm_tlm_analysis_fifo #(AXI_xtn) AXI_fifoh;
	uvm_tlm_analysis_fifo #(AXI_rst_xtn) AXI_rst_fifoh;
	uvm_tlm_analysis_fifo #(AHB_xtn) AHB_fifoh;
	uvm_tlm_analysis_fifo #(AHB_rst_xtn) AHB_rst_fifoh;
	uvm_tlm_analysis_fifo #(AXI_xtn) AXI_wdata_fifoh;
	uvm_tlm_analysis_fifo #(AXI_xtn) AXI_rdata_fifoh;

	AXI_rst_xtn axi_rst_xtn;
	AXI_rst_xtn axi_rst_cov;

	AHB_rst_xtn ahb_rst_xtn;
	AHB_rst_xtn ahb_rst_cov;

	AXI_xtn axi_xtn;
	AXI_xtn axi_cov;
	AXI_xtn axi_wdata;
	AXI_xtn axi_rdata;

	AHB_xtn ahb_xtn;
	AHB_xtn ahb_cov;

	AXI_xtn write_data[$];
	AXI_xtn read_data[$];

	covergroup axi_rst_cg;
		option.per_instance = 1;
		AXI_RSTN: coverpoint axi_rst_cov.aresetn {bins RSTN[] = {0, 1};}
	endgroup

	covergroup ahb_rst_cg;
		option.per_instance = 1;
		AHB_RSTN: coverpoint ahb_rst_cov.hresetn {bins RSTN[] = {0, 1};}
	endgroup

	covergroup axi_cg;
		option.per_instance = 1;
		AXI_AWID: coverpoint axi_cov.awid {bins id = {[0:$]};}
		AXI_AWADDR: coverpoint axi_cov.awaddr {bins valid_addr = {[32'h0000_0000:32'hffff_ffff]};}
		AXI_AWLEN: coverpoint axi_cov.awlen {bins AWLEN[] = {[0:15]};}
		AXI_AWSIZE: coverpoint axi_cov.awsize {bins AWSIZE[] = {0, 1, 2, 3};}
		AXI_AWBURST: coverpoint axi_cov.awburst {bins AWBURST[] = {0, 1, 2};}
		
		AXI_WID: coverpoint axi_cov.wid {bins id = {[0:$]};}
		AXI_WLAST: coverpoint axi_cov.wlast {bins wlast[] = {0, 1};}

		AXI_BID: coverpoint axi_cov.bid {bins id = {[0:$]};}
		AXI_BRESP: coverpoint axi_cov.bresp {bins bresp[] = {0, 1};}

		AXI_ARID: coverpoint axi_cov.arid {bins id = {[0:$]};}
		AXI_ARADDR: coverpoint axi_cov.araddr {bins valid_addr = {[32'h0000_0000:32'hffff_ffff]};}
		AXI_ARLEN: coverpoint axi_cov.arlen {bins ARLEN[] = {[0:15]};}
		AXI_ARSIZE: coverpoint axi_cov.arsize {bins ARSIZE[] = {0, 1, 2, 3};}
		AXI_ARBURST: coverpoint axi_cov.arburst {bins ARBURST[] = {0, 1, 2};}
		
		AXI_RID: coverpoint axi_cov.rid {bins id = {[0:$]};}
		AXI_RLAST: coverpoint axi_cov.rlast {bins rlast[] = {0, 1};}
	endgroup

	covergroup axi_wdata_cg with function sample (int i);
		option.per_instance = 1;
		AXI_WDATA: coverpoint axi_cov.wdata[i] {bins data = {[64'h0: 64'hffff_ffff_ffff_ffff]};}
		AXI_WSTRB: coverpoint axi_cov.wstrb[i] {bins strobe[] = {1, 2, 4, 8, 16, 32, 64, 128, 3, 12, 48, 192, 15, 240, 255};}
	endgroup

	covergroup axi_rdata_cg with function sample (int i);
		option.per_instance = 1;
		AXI_RDATA: coverpoint axi_cov.rdata[i] {bins data = {[64'h0: 64'hffff_ffff_ffff_ffff]};}
		AXI_RRESP: coverpoint axi_cov.rresp[i] {bins rresp[] = {0, 1};}
	endgroup

	covergroup ahb_cg;
		option.per_instance = 1;
		AHB_HADDR: coverpoint ahb_cov.haddr {bins valid_addr = {[32'h0: 32'hffff_ffff]};}
		AHB_HWRITE: coverpoint ahb_cov.hwrite {bins HWRITE[] = {0, 1};}
		AHB_HSIZE: coverpoint ahb_cov.hsize {bins HSIZE[] = {0, 1, 2, 3};}
		AHB_HREADY: coverpoint ahb_cov.hready {bins HREADY[] = {0, 1};}
		AHB_HRESP: coverpoint ahb_cov.hresp {bins HRESP[] = {0, 1};}
		AHB_HWDATA: coverpoint ahb_cov.hwdata {bins data = {[64'h0: 64'hffff_ffff_ffff_ffff]};}
		AHB_HRDATA: coverpoint ahb_cov.hrdata {bins data = {[64'h0: 64'hffff_ffff_ffff_ffff]};}
	endgroup

	function new (string name = "scoreboard", uvm_component parent);
		super.new(name, parent);
		// Covergroup Handles
		axi_rst_cg = new;
		ahb_rst_cg = new;
		axi_cg = new;
		axi_wdata_cg = new;
		axi_rdata_cg = new;
		ahb_cg = new;

		// FIFO Handles
		AXI_fifoh = new("AXI_fifoh", this);
		AXI_rst_fifoh = new("AXI_rst_fifoh", this);
		AHB_fifoh = new("AHB_fifoh", this);
		AHB_rst_fifoh = new("AHB_rst_fifoh", this);
		AXI_wdata_fifoh = new("AXI_wdata_fifoh", this);
		AXI_rdata_fifoh = new("AXI_rdata_fifoh", this);
	endfunction

	task run_phase (uvm_phase phase);
		fork
			// Get AXI_RST data
			begin
				AXI_rst_fifoh.get(axi_rst_xtn);
				axi_rst_check(axi_rst_xtn);
				axi_rst_cov = new axi_rst_xtn;
				axi_rst_cg.sample();
			end
			// Get AHB_RST data
			begin
				AHB_rst_fifoh.get(ahb_rst_xtn);
				ahb_rst_check(ahb_rst_xtn);
				ahb_rst_cov = new ahb_rst_xtn;
				ahb_rst_cg.sample();
			end
			// Get AXI data
			begin
				AXI_fifoh.get(axi_xtn);
				axi_cov = new axi_xtn;
				axi_cg.sample();
				foreach (axi_cov.wdata[i])
					axi_wdata_cg.sample(i);
				foreach (axi_cov.rdata[i])
					axi_rdata_cg.sample(i);
			end
			// Get AHB data
			begin
				AHB_fifoh.get(ahb_xtn);
				`uvm_info(get_type_name(), "got ahb data", UVM_LOW)
				ahb_cov = new ahb_xtn;
				compare_data(ahb_xtn);
				ahb_cg.sample();
			end
			// Get write data in AXI
			begin
				AXI_wdata_fifoh.get(axi_wdata);
				`uvm_info(get_type_name(), "got data for wdata queue", UVM_LOW)
				write_data.push_back(axi_wdata);
			end
			// Get read data in AXI
			begin
				AXI_rdata_fifoh.get(axi_rdata);
				read_data.push_back(axi_rdata);
			end
		join
	endtask

	task axi_rst_check (AXI_rst_xtn axi_rst);
		if (axi_rst.aresetn == 1'b0)
			begin
				if (axi_rst.bvalid == 1'b0 && axi_rst.rvalid == 1'b0)
					`uvm_info(get_type_name(), "AXI rst GOOD", UVM_LOW)
				else
					`uvm_fatal(get_type_name(), "AXI rst BAD")
			end
	endtask

	task ahb_rst_check (AHB_rst_xtn ahb_rst);
		if (ahb_rst.hresetn == 1'b0)
			begin
				if (ahb_rst.htrans == 2'b00)
					`uvm_info(get_type_name(), "AHB rst GOOD", UVM_LOW)
				else
					begin
					`uvm_info(get_type_name(), $sformatf("value of htrans = %b", ahb_rst.htrans), UVM_LOW)
					`uvm_fatal(get_type_name(), "AHB rst BAD")
					end
			end
	endtask

	task compare_data (AHB_xtn ahb_xtn);
		AXI_xtn axi_xtn;

		//`uvm_info(get_type_name(), "waiting for htrans to be 2'b10", UVM_LOW)
		//wait(ahb_xtn.hready == 1);
		//`uvm_info(get_type_name(), "htrans is 2'b10", UVM_LOW)

		if (ahb_xtn.hwrite == 1'b1)
			begin	
				`uvm_info(get_type_name(), "waiting for wdata queue", UVM_LOW)
				wait(write_data.size() != 0)
				axi_xtn = write_data.pop_front();
				if (axi_xtn.temp_wdata == ahb_xtn.hwdata)
					begin
						`uvm_info(get_type_name(), "DATA MATCH :)", UVM_LOW)
					end
				else
					begin
						`uvm_info(get_type_name(), $sformatf("DATA MISMATCH :(, axi_wdata = %0h, ahb_wdata = %0h", axi_xtn.temp_wdata, ahb_xtn.hwdata), UVM_LOW)
					end
			end
		else if (ahb_xtn.hwrite == 1'b0)
			begin
				`uvm_info(get_type_name(), "waiting for rdata queue", UVM_LOW)
				wait(read_data.size() != 0)
				axi_xtn = read_data.pop_front();
				if (axi_xtn.temp_rdata == ahb_xtn.hrdata)
					begin
						`uvm_info(get_type_name(), "DATA MATCH :)", UVM_LOW)
					end
				else
					begin
						`uvm_info(get_type_name(), $sformatf("DATA MISMATCH :(, axi_rdata = %0h, ahb_rdata = %0h", axi_xtn.temp_rdata, ahb_xtn.hrdata), UVM_LOW)
					end
			end
	endtask

endclass

