class AXI_driver extends uvm_driver #(AXI_xtn);

	`uvm_component_utils(AXI_driver)
	
	AXI_xtn xtn;
	AXI_xtn aw_ch[$];
	AXI_xtn w_ch[$];
	AXI_xtn b_ch[$];
	AXI_xtn ar_ch[$];
	AXI_xtn r_ch[$];

	virtual axi_if axi_intf;

	function new (string name = "AXI_driver", uvm_component parent);
		super.new(name, parent);
	endfunction

	semaphore aw_sem = new(1);
	semaphore w_sem = new (1);
	semaphore aw_w_sem = new();
	semaphore b_sem = new (1);
	semaphore w_b_sem = new();
	
	semaphore ar_sem = new(1);
	semaphore r_sem = new(1);
	semaphore ar_r_sem = new();

	function void build_phase (uvm_phase phase);
		if (!uvm_config_db #(virtual axi_if)::get(this, "", "AXI_if", axi_intf))
			`uvm_fatal(get_type_name(), "cannot get axi_if in AXI_driver")
	endfunction

	task run_phase (uvm_phase phase);
		forever begin
			seq_item_port.get_next_item(req);
			send_to_dut(req);
			`uvm_info(get_type_name(), "Data in AXI driver", UVM_LOW)
			req.print();
			seq_item_port.item_done();
		end
	endtask

	task send_to_dut (AXI_xtn xtn);
		// Store req in queues to not override in outstanding requests
		aw_ch.push_back(xtn);
		w_ch.push_back(xtn);
		b_ch.push_back(xtn);
		ar_ch.push_back(xtn);
		r_ch.push_back(xtn);
		
		// fork ... join_any for parallel execution
		fork
			begin
				// AW Channel
				aw_sem.get(1);
				`uvm_info(get_type_name(), "aw_channel method started", UVM_LOW)
				aw_channel(aw_ch.pop_front());
				`uvm_info(get_type_name(), "aw_channel method ended", UVM_LOW)
				aw_w_sem.put(1);
				aw_sem.put(1);
			end
			begin
				// W Channel
				w_sem.get(1);
				aw_w_sem.get(1);
				`uvm_info(get_type_name(), "w_channel method started", UVM_LOW)
				w_channel(w_ch.pop_front());
				`uvm_info(get_type_name(), "w_channel method ended", UVM_LOW)
				w_b_sem.put(1);
				w_sem.put(1);
			end
			begin
				// B Channel
				b_sem.get(1);
				w_b_sem.get(1);
				`uvm_info(get_type_name(), "b_channel method started", UVM_LOW)
				b_channel(b_ch.pop_front());
				`uvm_info(get_type_name(), "b_channel method ended", UVM_LOW)
				b_sem.put(1);
			end
			begin
				// AR Channel
				ar_sem.get(1);
				ar_channel(ar_ch.pop_front());
				ar_r_sem.put(1);
				ar_sem.put(1);
			end
			begin
				// R Channel
				r_sem.get(1);
				ar_r_sem.get(1);
				r_channel(r_ch.pop_front());
				r_sem.put(1);
			end
		join_any	
	endtask

	task aw_channel (AXI_xtn xtn);
		@(axi_intf.axi_drv_cb);
		axi_intf.axi_drv_cb.awvalid <= xtn.awvalid;
		axi_intf.axi_drv_cb.awid <= xtn.awid;
		axi_intf.axi_drv_cb.awaddr <= xtn.awaddr;
		axi_intf.axi_drv_cb.awlen <= xtn.awlen;
		axi_intf.axi_drv_cb.awsize <= xtn.awsize;
		axi_intf.axi_drv_cb.awburst <= xtn.awburst;
		@(axi_intf.axi_drv_cb);
		wait(axi_intf.axi_drv_cb.awready)
		axi_intf.axi_drv_cb.awvalid <= 1'b0;
		repeat (xtn.delay_cycles)
		@(axi_intf.axi_drv_cb);
	endtask

	task w_channel (AXI_xtn xtn);
		foreach(xtn.wdata[i])
			begin
				//@(axi_intf.axi_drv_cb.axi_drv_cb);
				axi_intf.axi_drv_cb.wvalid <= xtn.wvalid;
				axi_intf.axi_drv_cb.wdata <= xtn.wdata[i];
				axi_intf.axi_drv_cb.wstrb <= xtn.wstrb[i];
				axi_intf.axi_drv_cb.wid <= xtn.wid;
				if (i == xtn.awlen)
					axi_intf.axi_drv_cb.wlast <= 1'b1;
				else
					axi_intf.axi_drv_cb.wlast <= 1'b0;
				@(axi_intf.axi_drv_cb);
				wait(axi_intf.axi_drv_cb.wready)
				axi_intf.axi_drv_cb.wvalid <= 1'b0;
				axi_intf.axi_drv_cb.wlast <= 1'b0;
				@(axi_intf.axi_drv_cb);
				repeat (xtn.delay_cycles)
				@(axi_intf.axi_drv_cb);
			end
	endtask

	task b_channel (AXI_xtn xtn);
		@(axi_intf.axi_drv_cb);
		axi_intf.axi_drv_cb.bready <= xtn.bready;
		@(axi_intf.axi_drv_cb);
		`uvm_info(get_type_name(), "Inside b_channel driving logic - waiting for bvalid", UVM_LOW)
		wait(axi_intf.axi_drv_cb.bvalid);
		axi_intf.axi_drv_cb.bready <= 1'b0;
		repeat (xtn.delay_cycles)
		@(axi_intf.axi_drv_cb);
	endtask

	task ar_channel (AXI_xtn xtn);
		@(axi_intf.axi_drv_cb);
		axi_intf.axi_drv_cb.arvalid <= xtn.arvalid;
		axi_intf.axi_drv_cb.arid <= xtn.arid;
		axi_intf.axi_drv_cb.arlen <= xtn.arlen;
		axi_intf.axi_drv_cb.arsize <= xtn.arsize;
		axi_intf.axi_drv_cb.arburst <= xtn.arburst;	
		@(axi_intf.axi_drv_cb);
		wait(axi_intf.axi_drv_cb.arready)
		axi_intf.axi_drv_cb.arvalid <= 1'b0;
		repeat (xtn.delay_cycles)
		@(axi_intf.axi_drv_cb);
	endtask
	
	task r_channel (AXI_xtn xtn);
		@(axi_intf.axi_drv_cb);
		axi_intf.axi_drv_cb.rready <= xtn.rready;
		@(axi_intf.axi_drv_cb);
		wait(axi_intf.axi_drv_cb.rvalid)
		axi_intf.axi_drv_cb.rready	<= 1'b0;
		repeat (xtn.delay_cycles)
		@(axi_intf.axi_drv_cb);
	endtask

endclass

