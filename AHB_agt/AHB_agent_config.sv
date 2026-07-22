class AHB_agent_config extends uvm_object;

	`uvm_object_utils(AHB_agent_config)

	uvm_active_passive_enum is_active = UVM_ACTIVE;

	virtual ahb_if ahb_intf;

	function new (string name = "AHB_agent_config");
		super.new(name);
	endfunction

endclass

