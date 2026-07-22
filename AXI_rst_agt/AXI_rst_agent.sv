class AXI_rst_agent extends uvm_agent;

	`uvm_component_utils(AXI_rst_agent)

	AXI_rst_driver drvh;
	AXI_rst_sequencer seqrh;
	AXI_rst_monitor monh;
	AXI_rst_agent_config AXI_rst_cfg;

	function new (string name = "AXI_rst_agent", uvm_component parent);
		super.new(name, parent);
	endfunction 

	function void build_phase (uvm_phase phase);
		if (!uvm_config_db #(AXI_rst_agent_config)::get(this, "", "AXI_rst_cfg", AXI_rst_cfg))
			`uvm_fatal(get_type_name(), "cannot get AXI_rst_cfg in agent!")
	
		uvm_config_db #(virtual axi_if)::set(this, "monh", "AXI_if", AXI_rst_cfg.axi_intf);
		uvm_config_db #(virtual axi_rst_if)::set(this, "monh", "AXI_rst_if", AXI_rst_cfg.axi_rst_intf);
		monh = AXI_rst_monitor::type_id::create("monh", this);

		if (AXI_rst_cfg.is_active == UVM_ACTIVE)
			begin
				uvm_config_db #(virtual axi_if)::set(this, "drvh", "AXI_if", AXI_rst_cfg.axi_intf);
				drvh = AXI_rst_driver::type_id::create("drvh", this);
				seqrh = AXI_rst_sequencer::type_id::create("seqrh", this);
			end
	endfunction

	function void connect_phase (uvm_phase phase);
		if (AXI_rst_cfg.is_active == UVM_ACTIVE)
			begin
				drvh.seq_item_port.connect(seqrh.seq_item_export);
			end
	endfunction

endclass

