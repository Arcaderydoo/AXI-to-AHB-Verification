class AHB_agent extends uvm_agent;

	`uvm_component_utils(AHB_agent)

	AHB_driver drvh;
	AHB_sequencer seqrh;
	AHB_monitor monh;
	AHB_agent_config AHB_cfg;

	function new (string name = "AHB_agent", uvm_component parent);
		super.new(name, parent);
	endfunction 

	function void build_phase (uvm_phase phase);
		if (!uvm_config_db #(AHB_agent_config)::get(this, "", "AHB_cfg", AHB_cfg))
			`uvm_fatal(get_type_name(), "cannot get AHB_cfg in agent!")

		uvm_config_db #(virtual ahb_if.AHB_MON_MP)::set(this, "monh", "ahb_if", AHB_cfg.ahb_intf.AHB_MON_MP);
		monh = AHB_monitor::type_id::create("monh", this);

		if (AHB_cfg.is_active == UVM_ACTIVE)
			begin
				uvm_config_db #(virtual ahb_if.AHB_DRV_MP)::set(this, "drvh", "ahb_if", AHB_cfg.ahb_intf.AHB_DRV_MP);
				drvh = AHB_driver::type_id::create("drvh", this);
				seqrh = AHB_sequencer::type_id::create("seqrh", this);
			end
	endfunction

	function void connect_phase (uvm_phase phase);
		if (AHB_cfg.is_active == UVM_ACTIVE)
			begin
				drvh.seq_item_port.connect(seqrh.seq_item_export);
			end
	endfunction

endclass

