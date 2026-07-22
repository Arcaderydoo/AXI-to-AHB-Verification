class AHB_rst_monitor extends uvm_monitor;

	`uvm_component_utils(AHB_rst_monitor)

	uvm_analysis_port #(AHB_rst_xtn) AHB_rst_mon_port;
	virtual ahb_rst_if ahb_rst_intf;
	virtual ahb_if ahb_intf;
	AHB_rst_xtn xtn;

	function new (string name = "AHB_rst_monitor", uvm_component parent);
		super.new(name, parent);
		AHB_rst_mon_port = new("AHB_rst_mon_port", this);
	endfunction

	function void build_phase (uvm_phase phase);
		if (!uvm_config_db #(virtual ahb_if)::get(this, "", "AHB_if", ahb_intf))
			`uvm_fatal(get_type_name(), "cannot get ahb_if!!!")
		if (!uvm_config_db #(virtual ahb_rst_if)::get(this, "", "AHB_rst_if", ahb_rst_intf))
			`uvm_fatal(get_type_name(), "cannot get ahb_rst_if!!!")
		xtn = AHB_rst_xtn::type_id::create("xtn");
	endfunction

	task run_phase (uvm_phase phase);
		forever begin
			collect_data();
		end
	endtask

	task collect_data();	
		@(ahb_rst_intf.ahb_rst_mon_cb)
		@(ahb_rst_intf.ahb_rst_mon_cb)
		xtn.hresetn = ahb_rst_intf.hresetn;
		xtn.hready = ahb_intf.hready;
		xtn.htrans = ahb_intf.htrans;

		//`uvm_info(get_type_name(), "Data in AHB RST MONITOR", UVM_LOW)
		//xtn.print();
		AHB_rst_mon_port.write(xtn);
		
	endtask

endclass

