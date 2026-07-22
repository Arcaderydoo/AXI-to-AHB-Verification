class AHB_monitor extends uvm_monitor;

	`uvm_component_utils(AHB_monitor)

	virtual ahb_if.AHB_MON_MP ahb_intf;
	uvm_analysis_port #(AHB_xtn) AHB_mon_port;
	AHB_xtn xtn;

	function new (string name = "AHB_monitor", uvm_component parent);
		super.new(name, parent);
		AHB_mon_port = new("AHB_mon_port", this);
	endfunction

	function void build_phase (uvm_phase phase);
		if (!uvm_config_db #(virtual ahb_if.AHB_MON_MP)::get(this, "", "ahb_if", ahb_intf))
			`uvm_fatal(get_type_name(), "cannot get ahb_if for AHB monitor!")
	endfunction

	task run_phase (uvm_phase phase);
		forever
			collect_data();
	endtask

	task collect_data();
		xtn = AHB_xtn::type_id::create("ahb_xtn");
	
		//@(ahb_intf.ahb_mon_cb);
		`uvm_info(get_type_name(), "inside task, before wait", UVM_LOW)
		wait (ahb_intf.ahb_mon_cb.hready && ahb_intf.ahb_mon_cb.htrans == 2'b10);
		`uvm_info(get_type_name(), "inside task, after wait", UVM_LOW)
		xtn.haddr = ahb_intf.ahb_mon_cb.haddr;
		xtn.htrans = ahb_intf.ahb_mon_cb.htrans;
		xtn.hwrite = ahb_intf.ahb_mon_cb.hwrite;
		xtn.hsize = ahb_intf.ahb_mon_cb.hsize;
		xtn.hburst = ahb_intf.ahb_mon_cb.hburst;
		xtn.hready = ahb_intf.ahb_mon_cb.hready;
		xtn.hresp = ahb_intf.ahb_mon_cb.hresp;


		if (ahb_intf.ahb_mon_cb.hwrite)
			begin
				@(ahb_intf.ahb_mon_cb);
				`uvm_info(get_type_name(), "inside hwrite monitor, before wait", UVM_LOW)
				wait(ahb_intf.ahb_mon_cb.hready)
				`uvm_info(get_type_name(), "inside hwrite monitor, after wait", UVM_LOW)
				xtn.hwdata = ahb_intf.ahb_mon_cb.hwdata;
				//@(ahb_intf.ahb_mon_cb);
				AHB_mon_port.write(xtn);
			end
		else
			begin
				@(ahb_intf.ahb_mon_cb);
				wait(ahb_intf.ahb_mon_cb.hready)
				xtn.hrdata = ahb_intf.ahb_mon_cb.hrdata;
				//@(ahb_intf.ahb_mon_cb);
				AHB_mon_port.write(xtn);
			end

		`uvm_info(get_type_name(), $sformatf("Monitor Data: \n %p", xtn.sprint()), UVM_LOW)
	endtask

endclass

