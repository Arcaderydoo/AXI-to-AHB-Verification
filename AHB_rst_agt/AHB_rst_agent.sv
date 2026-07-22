class AHB_rst_agent extends uvm_agent;

	`uvm_component_utils(AHB_rst_agent)

	AHB_rst_driver drvh;
	AHB_rst_sequencer seqrh;
	AHB_rst_monitor monh;
	AHB_rst_agent_config AHB_rst_cfg;

	function new (string name = "AHB_rst_agent", uvm_component parent);
		super.new(name, parent);
	endfunction 

	function void build_phase (uvm_phase phase);
		if (!uvm_config_db #(AHB_rst_agent_config)::get(this, "", "AHB_rst_cfg", AHB_rst_cfg))
			`uvm_fatal(get_type_name(), "cannot get AHB_rst_cfg in agent!")

		uvm_config_db #(virtual ahb_if)::set(this, "monh", "AHB_if", AHB_rst_cfg.ahb_intf);
		uvm_config_db #(virtual ahb_rst_if)::set(this, "monh", "AHB_rst_if", AHB_rst_cfg.ahb_rst_intf);
		monh = AHB_rst_monitor::type_id::create("monh", this);

		if (AHB_rst_cfg.is_active == UVM_ACTIVE)
			begin
				uvm_config_db #(virtual ahb_if)::set(this, "drvh", "AHB_if", AHB_rst_cfg.ahb_intf);
				uvm_config_db #(virtual ahb_rst_if)::set(this, "drvh", "AHB_rst_if", AHB_rst_cfg.ahb_rst_intf);
				drvh = AHB_rst_driver::type_id::create("drvh", this);
				seqrh = AHB_rst_sequencer::type_id::create("seqrh", this);
			end
	endfunction

	function void connect_phase (uvm_phase phase);
		if (AHB_rst_cfg.is_active == UVM_ACTIVE)
			begin
				drvh.seq_item_port.connect(seqrh.seq_item_export);
			end
	endfunction

endclass

