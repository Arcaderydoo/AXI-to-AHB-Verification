class AHB_driver extends uvm_driver #(AHB_xtn);

	`uvm_component_utils(AHB_driver)

	virtual ahb_if.AHB_DRV_MP ahb_intf;

	function new (string name = "AHB_driver", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase (uvm_phase phase);
		if (!uvm_config_db #(virtual ahb_if.AHB_DRV_MP)::get(this, "", "ahb_if", ahb_intf))
			`uvm_fatal(get_type_name(), "cannot get ahb_intf in AHB driver!")
	endfunction

	task run_phase (uvm_phase phase);
		forever begin
			seq_item_port.get_next_item(req);
			`uvm_info(get_type_name(), "Data in AHB Driver", UVM_LOW)
			req.print();
			send_to_dut(req);
			seq_item_port.item_done();
		end
	endtask

	task send_to_dut (AHB_xtn xtn);
		 ahb_intf.ahb_drv_cb.hmaster <= 4'h0;

		if (xtn.cases == 0)
			begin
				if (ahb_intf.ahb_drv_cb.hwrite)
					begin
						ahb_intf.ahb_drv_cb.hready <= 1'b1;
						ahb_intf.ahb_drv_cb.hresp <= 2'b00;
						@(ahb_intf.ahb_drv_cb);
						ahb_intf.ahb_drv_cb.hready <= 1'b1;
						ahb_intf.ahb_drv_cb.hresp <= 2'b00;
						//@(ahb_intf.ahb_drv_cb);
					end
				else
					begin
						ahb_intf.ahb_drv_cb.hready <= 1'b1;
						ahb_intf.ahb_drv_cb.hresp <= 2'b00;
						ahb_intf.ahb_drv_cb.hrdata <= xtn.hrdata;
						@(ahb_intf.ahb_drv_cb);
						ahb_intf.ahb_drv_cb.hready <= 1'b1;
						ahb_intf.ahb_drv_cb.hresp <= 2'b00;
						ahb_intf.ahb_drv_cb.hrdata <= xtn.hrdata;
						//@(ahb_intf.ahb_drv_cb);
					end
			end
		else if (xtn.cases == 1)
			begin
				if (ahb_intf.ahb_drv_cb.hwrite)
					begin
						ahb_intf.ahb_drv_cb.hready <= 1'b0;
						repeat (xtn.delay_cycles) @(ahb_intf.ahb_drv_cb);
						ahb_intf.ahb_drv_cb.hready <= 1'b1;
						ahb_intf.ahb_drv_cb.hresp <= 2'b00;
						@(ahb_intf.ahb_drv_cb);
						ahb_intf.ahb_drv_cb.hready <= 1'b1;
						ahb_intf.ahb_drv_cb.hresp <= 2'b00;
						//@(ahb_intf.ahb_drv_cb);
						@(ahb_intf.ahb_drv_cb);
						ahb_intf.ahb_drv_cb.hready <= 1'b0;
					end
				else
					begin
						ahb_intf.ahb_drv_cb.hready <= 1'b0;
						repeat (xtn.delay_cycles) @(ahb_intf.ahb_drv_cb);
						ahb_intf.ahb_drv_cb.hready <= 1'b1;
						ahb_intf.ahb_drv_cb.hresp <= 2'b00;	
						ahb_intf.ahb_drv_cb.hrdata <= xtn.hrdata;
						@(ahb_intf.ahb_drv_cb);
						ahb_intf.ahb_drv_cb.hready <= 1'b1;
						ahb_intf.ahb_drv_cb.hresp <= 2'b00;	
						ahb_intf.ahb_drv_cb.hrdata <= xtn.hrdata;
						//@(ahb_intf.ahb_drv_cb);
						@(ahb_intf.ahb_drv_cb);
						ahb_intf.ahb_drv_cb.hready <= 1'b0;
					end
			end
		else if (xtn.cases == 2)
			begin	
				if (ahb_intf.ahb_drv_cb.hwrite)
					begin
						@(ahb_intf.ahb_drv_cb);
						if (ahb_intf.ahb_drv_cb.htrans == 2'b10)
							begin
								ahb_intf.ahb_drv_cb.hready <= 1'b0;
								ahb_intf.ahb_drv_cb.hresp <= 2'b01;	
								@(ahb_intf.ahb_drv_cb);
								ahb_intf.ahb_drv_cb.hready <= 1'b1;
								ahb_intf.ahb_drv_cb.hresp <= 2'b01;	
								@(ahb_intf.ahb_drv_cb);
								ahb_intf.ahb_drv_cb.hready <= 1'b0;
							end
						else
							begin
								@(ahb_intf.ahb_drv_cb);
								@(ahb_intf.ahb_drv_cb);
								ahb_intf.ahb_drv_cb.hready <= 1'b1;
								ahb_intf.ahb_drv_cb.hresp <= 2'b00;	
								@(ahb_intf.ahb_drv_cb);
								ahb_intf.ahb_drv_cb.hready <= 1'b0;
							end
					end
				else
					begin
						@(ahb_intf.ahb_drv_cb);
						if (ahb_intf.ahb_drv_cb.htrans == 2'b10)
							begin
								ahb_intf.ahb_drv_cb.hready <= 1'b0;
								ahb_intf.ahb_drv_cb.hresp <= 2'b01;	
								@(ahb_intf.ahb_drv_cb);
								ahb_intf.ahb_drv_cb.hready <= 1'b1;
								ahb_intf.ahb_drv_cb.hresp <= 2'b01;	
								@(ahb_intf.ahb_drv_cb);
								ahb_intf.ahb_drv_cb.hready <= 1'b0;
							end
						else
							begin
								@(ahb_intf.ahb_drv_cb);
								@(ahb_intf.ahb_drv_cb);
								ahb_intf.ahb_drv_cb.hready <= 1'b1;
								ahb_intf.ahb_drv_cb.hresp <= 2'b00;	
								@(ahb_intf.ahb_drv_cb);
								@(ahb_intf.ahb_drv_cb);
								ahb_intf.ahb_drv_cb.hready <= 1'b0;
							end
					end
			end
	endtask

endclass

