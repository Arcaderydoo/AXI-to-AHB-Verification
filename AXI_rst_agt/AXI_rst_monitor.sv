class AXI_rst_monitor extends uvm_monitor;

	`uvm_component_utils(AXI_rst_monitor)

	virtual axi_rst_if vif1;
	virtual axi_if vif2;
	uvm_analysis_port #(AXI_rst_xtn) AXI_rst_mon_port;
	AXI_rst_xtn xtn;

	function new (string name = "AXI_rst_monitor", uvm_component parent);
		super.new(name, parent);
		AXI_rst_mon_port = new("AXI_rst_mon_port", this);
	endfunction

	function void build_phase (uvm_phase phase);
		if (!uvm_config_db #(virtual axi_rst_if)::get(this, "", "AXI_rst_if", vif1))
			`uvm_fatal(get_type_name(), "Cannot get AXI_rst_if")
		if (!uvm_config_db #(virtual axi_if)::get(this, "", "AXI_if", vif2))
			`uvm_fatal(get_type_name(), "Cannot get AXI_if")
	endfunction
	
	task run_phase (uvm_phase phase);
		forever begin
			collect_data();
		end
	endtask

	task collect_data();	
		xtn = AXI_rst_xtn::type_id::create("xtn");
		
		@(vif1.axi_rst_mon_cb)
		@(vif1.axi_rst_mon_cb)
		xtn.aresetn = vif1.aresetn;
		xtn.rvalid = vif2.rvalid;
		xtn.bvalid = vif2.bvalid;
	
		//`uvm_info(get_type_name(), "Data in AXI RST MONITOR", UVM_LOW)
		//xtn.print();
		AXI_rst_mon_port.write(xtn);
	endtask
	
endclass

