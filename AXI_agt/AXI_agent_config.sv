class AXI_agent_config extends uvm_object;

	`uvm_object_utils(AXI_agent_config)

	uvm_active_passive_enum is_active = UVM_ACTIVE;
	virtual axi_if axi_intf;
	

	function new (string name = "AXI_agent_config");
		super.new(name);
	endfunction

endclass

