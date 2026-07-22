class AHB_rst_driver extends uvm_driver #(AHB_rst_xtn);

	`uvm_component_utils(AHB_rst_driver)

	virtual ahb_rst_if vif1;
	virtual ahb_if vif2;

	function new (string name = "AHB_rst_driver", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase (uvm_phase phase);
		if (!uvm_config_db #(virtual ahb_rst_if)::get(this, "", "AHB_rst_if", vif1))
			`uvm_fatal(get_type_name(), "cannot get ahb_rst_if!!")
		if (!uvm_config_db #(virtual ahb_if)::get(this, "", "AHB_if", vif2))
			`uvm_fatal(get_type_name(), "cannot get ahb_if!!")
	endfunction

	task run_phase (uvm_phase phase);
		forever begin
			seq_item_port.get_next_item(req);
			`uvm_info(get_type_name(), "Data in AHB_rst_driver", UVM_LOW)
			req.print();
			send_to_dut(req);
			seq_item_port.item_done();
		end
	endtask

	task send_to_dut(AHB_rst_xtn xtn);
		@(vif1.ahb_rst_drv_cb)
		vif1.hresetn <= xtn.hresetn;
		//vif2.hready <= xtn.hready;
		@(vif1.ahb_rst_drv_cb);
	endtask

endclass

