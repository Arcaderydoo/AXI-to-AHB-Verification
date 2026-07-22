class AXI_monitor extends uvm_monitor;

	`uvm_component_utils(AXI_monitor)

	virtual axi_if axi_intf;
	
	uvm_analysis_port #(AXI_xtn) AXI_mon_port;
	uvm_analysis_port #(AXI_xtn) AXI_wdata_mon_port;
	uvm_analysis_port #(AXI_xtn) AXI_rdata_mon_port;

	// AXI_xtn xtn;
	AXI_xtn aw_xtn;
	AXI_xtn w_xtn;
	AXI_xtn b_xtn;
	AXI_xtn ar_xtn;
	AXI_xtn r_xtn;
	AXI_xtn write_data_xtn;
	AXI_xtn read_data_xtn; 	
	AXI_xtn write_ch [$];
	AXI_xtn read_ch [$];

	semaphore aw_sem = new(1);
	semaphore w_sem = new(1);
	semaphore aw_w_sem = new();
	semaphore b_sem = new(1);
	semaphore w_b_sem = new();

	semaphore ar_sem = new(1);
	semaphore r_sem = new(1);
	semaphore ar_r_sem = new();	
	
	function new (string name = "AXI_monitor", uvm_component parent);
		super.new(name, parent);
		AXI_mon_port = new("AXI_mon_port", this);
		AXI_wdata_mon_port = new("AXI_wdata_mon_port", this);
		AXI_rdata_mon_port = new("AXI_rdata_mon_port", this);
	endfunction

	function void build_phase (uvm_phase phase);
		if (!uvm_config_db #(virtual axi_if)::get(this, "", "AXI_if", axi_intf))
			`uvm_fatal(get_type_name(), "cannot get axi_if in AXI_monitor")
	endfunction

	task run_phase (uvm_phase phase);
		forever begin
			collect_data();
		end
	endtask
	
	task collect_data();
		fork
			begin
				// AW Channel
				aw_sem.get(1);
				`uvm_info(get_type_name(), "AW Channel method started", UVM_LOW)
				aw_channel();
				`uvm_info(get_type_name(), "AW Channel method ended", UVM_LOW)
				aw_w_sem.put(1);
				aw_sem.put(1);
			end
			begin
				// W Channel
				w_sem.get(1);
				aw_w_sem.get(1);
				`uvm_info(get_type_name(), "W Channel method started", UVM_LOW)
				w_channel(write_ch.pop_front());
				`uvm_info(get_type_name(), "W Channel method ended", UVM_LOW)
				w_b_sem.put(1);
				w_sem.put(1);
			end
			begin
				// B Channel
				b_sem.get(1);
				w_b_sem.get(1);
				`uvm_info(get_type_name(), "B Channel method started", UVM_LOW)
				b_channel(write_ch.pop_front());
				`uvm_info(get_type_name(), "B Channel method ended", UVM_LOW)
				b_sem.put(1);
			end
			begin
				// AR Channel
				ar_sem.get(1);
				`uvm_info(get_type_name(), "AR Channel method started", UVM_LOW)
				ar_channel();
				`uvm_info(get_type_name(), "AR Channel method ended", UVM_LOW)
				ar_r_sem.put(1);
				ar_sem.put(1);
			end
			begin
				// R Channel
				r_sem.get(1);
				ar_r_sem.get(1);
				`uvm_info(get_type_name(), "R Channel method started", UVM_LOW)
				r_channel(read_ch.pop_front());
				`uvm_info(get_type_name(), "R Channel method ended", UVM_LOW)
				r_sem.put(1);
			end
		join_any
	endtask

	task aw_channel();
		aw_xtn = AXI_xtn::type_id::create("aw_xtn");
		//aw_xtn = xtn;		

		wait(axi_intf.awvalid && axi_intf.awready)
		
		aw_xtn.awid = axi_intf.awid;
		aw_xtn.awvalid = axi_intf.awvalid;
		aw_xtn.awready = axi_intf.awready;
		aw_xtn.awlen = axi_intf.awlen;
		aw_xtn.awsize = axi_intf.awsize;
		aw_xtn.awburst = axi_intf.awburst;
		aw_xtn.awaddr = axi_intf.awaddr;
		
		write_ch.push_back(aw_xtn);
		
		`uvm_info(get_type_name(), "AW Channel - WRITE DATA in AXI MONITOR", UVM_LOW)
		aw_xtn.print();
		@(axi_intf.axi_mon_cb);

	endtask

	task w_channel(AXI_xtn xtn);
		w_xtn = AXI_xtn::type_id::create("w_xtn");
		w_xtn = xtn;

		w_xtn.wdata = new[w_xtn.awlen + 1];
		w_xtn.wstrb = new[w_xtn.awlen + 1];

		foreach (w_xtn.wdata[i])
			begin
				wait (axi_intf.wvalid && axi_intf.wready)

				w_xtn.wid = axi_intf.wid;
				w_xtn.wdata[i] = axi_intf.wdata;
				w_xtn.wstrb[i] = axi_intf.wstrb;
				w_xtn.wlast = axi_intf.wlast;
				w_xtn.wvalid = axi_intf.wvalid;
				w_xtn.wready = axi_intf.wready;
				
				write_data_xtn = AXI_xtn::type_id::create("write_data_xtn");
				write_data_xtn.temp_wdata[7:0] = axi_intf.wstrb[0] ? axi_intf.wdata[7:0] : 8'b0;
				write_data_xtn.temp_wdata[15:8] = axi_intf.wstrb[1] ? axi_intf.wdata[15:8] : 8'b0;
				write_data_xtn.temp_wdata[23:16] = axi_intf.wstrb[2] ? axi_intf.wdata[23:16] : 8'b0;
				write_data_xtn.temp_wdata[31:24] = axi_intf.wstrb[3] ? axi_intf.wdata[31:24] : 8'b0;
				write_data_xtn.temp_wdata[39:32] = axi_intf.wstrb[4] ? axi_intf.wdata[39:32] : 8'b0;
				write_data_xtn.temp_wdata[47:40] = axi_intf.wstrb[5] ? axi_intf.wdata[47:40] : 8'b0;
				write_data_xtn.temp_wdata[55:48] = axi_intf.wstrb[6] ? axi_intf.wdata[55:48] : 8'b0;
				write_data_xtn.temp_wdata[63:56] = axi_intf.wstrb[7] ? axi_intf.wdata[63:56] : 8'b0;

				@(axi_intf.axi_mon_cb);
				
				AXI_wdata_mon_port.write(write_data_xtn);
			end

		write_ch.push_back(w_xtn);

		`uvm_info(get_type_name(), "W Channel - WRITE DATA in AXI MONITOR", UVM_LOW)
		w_xtn.print();

	endtask

	task b_channel (AXI_xtn xtn);
		b_xtn = AXI_xtn::type_id::create("b_xtn");
		b_xtn = xtn;
		
		wait (axi_intf.bvalid && axi_intf.bready)
		
		b_xtn.bvalid = axi_intf.bvalid;
		b_xtn.bready = axi_intf.bready;
		b_xtn.bid = axi_intf.bid;
		b_xtn.bresp = axi_intf.bresp;

		@(axi_intf.axi_mon_cb);

		AXI_mon_port.write(b_xtn);
		`uvm_info(get_type_name(), "B Channel - WRITE DATA in AXI MONITOR", UVM_LOW)
		b_xtn.print();

	endtask

	task ar_channel();
		ar_xtn = AXI_xtn::type_id::create("ar_xtn");

		wait (axi_intf.arvalid && axi_intf.arready)
		
		ar_xtn.arid = axi_intf.arid;
		ar_xtn.araddr = axi_intf.araddr;
		ar_xtn.arlen = axi_intf.arlen;
		ar_xtn.arsize = axi_intf.arsize;
		ar_xtn.arburst = axi_intf.arburst;
		ar_xtn.arvalid = axi_intf.arvalid;
		ar_xtn.arready = axi_intf.arready;

		@(axi_intf.axi_mon_cb);
		read_ch.push_back(ar_xtn);
		`uvm_info(get_type_name(), "AR CHANNEL - READ DATA in AXI MONITOR", UVM_LOW)
		ar_xtn.print();

	endtask

	task r_channel (AXI_xtn xtn);
		r_xtn = AXI_xtn::type_id::create("r_xtn");
		r_xtn = xtn;
		r_xtn.rdata = new[r_xtn.arlen + 1];
		r_xtn.rresp = new[r_xtn.arlen + 1];
		
		foreach(r_xtn.rdata[i])
			begin
				wait (axi_intf.rvalid && axi_intf.rready)
				r_xtn.rid = axi_intf.rid;
				r_xtn.rdata[i] = axi_intf.rdata;
				r_xtn.rresp[i] = axi_intf.rresp;
				r_xtn.rlast = axi_intf.rlast;
				r_xtn.rready = axi_intf.rready;
				r_xtn.rvalid = axi_intf.rvalid;

				read_data_xtn = AXI_xtn::type_id::create("read_data_xtn");
				read_data_xtn.temp_rdata = axi_intf.rdata;

				@(axi_intf.axi_mon_cb);
				AXI_rdata_mon_port.write(read_data_xtn);
			end
		
		`uvm_info(get_type_name(), "R CHANNEL - READ DATA in AXI MONITOR", UVM_LOW)
		r_xtn.print();
		AXI_mon_port.write(r_xtn);
			
	endtask

endclass

