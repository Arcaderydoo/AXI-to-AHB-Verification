class AXI_rst_driver extends uvm_driver #(AXI_rst_xtn);
	`uvm_component_utils(AXI_rst_driver)

	virtual axi_rst_if vif;

	function new (string name = "AXI_rst_driver", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase (uvm_phase phase);
		if (!uvm_config_db #(virtual axi_rst_if)::get(this, "", "AXI_rst_if", vif))
			`uvm_fatal(get_type_name(), "Cannot get AXI_rst_if")
	endfunction

	task run_phase (uvm_phase phase);
		forever begin
			seq_item_port.get_next_item(req);
			`uvm_info(get_type_name(), "Data in driver", UVM_LOW)
			req.print();
			send_to_dut(req);
			seq_item_port.item_done();
		end
	endtask

	task send_to_dut (AXI_rst_xtn xtn);
		@(vif.axi_rst_drv_cb)
		vif.aresetn <= xtn.aresetn;
		@(vif.axi_rst_drv_cb);
	endtask

endclass

