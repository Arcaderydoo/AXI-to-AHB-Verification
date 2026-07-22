class env extends uvm_env;

	`uvm_component_utils(env)

	env_config env_cfg;

	AXI_agent AXI_agth[];
	AXI_agent_config AXI_cfg[];
	AXI_rst_agent AXI_rst_agth[];
	AXI_rst_agent_config AXI_rst_cfg[];

	AHB_agent AHB_agth[];
	AHB_agent_config AHB_cfg[];
	AHB_rst_agent AHB_rst_agth[];
	AHB_rst_agent_config AHB_rst_cfg[];
		
	scoreboard sbh[];
	
	function new (string name = "env", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase (uvm_phase phase);
		if (!uvm_config_db #(env_config)::get(this, "", "env_cfg", env_cfg))
			`uvm_fatal(get_type_name(), "cannot get env_cfg!!")
		
		env_cfg.ahb_len.push_front(4);
		
		AXI_cfg = new[env_cfg.no_of_duts];	
		AXI_agth = new[env_cfg.no_of_duts];	
		AXI_rst_cfg = new[env_cfg.no_of_duts];	
		AXI_rst_agth = new[env_cfg.no_of_duts];	

		AHB_cfg = new[env_cfg.no_of_duts];	
		AHB_agth = new[env_cfg.no_of_duts];	
		AHB_rst_cfg = new[env_cfg.no_of_duts];	
		AHB_rst_agth = new[env_cfg.no_of_duts];	

		if (env_cfg.has_scoreboard)
			begin
				sbh = new[env_cfg.no_of_duts];
				foreach(sbh[i])
					sbh[i] = scoreboard::type_id::create($sformatf("sbh[%0d]", i), this);
			end

		for (int i = 0; i < env_cfg.no_of_duts; i++)
			begin
				// AXI agent build
				AXI_cfg[i] = AXI_agent_config::type_id::create($sformatf("AXI_cfg[%0d]", i), this);
				AXI_cfg[i].is_active = UVM_ACTIVE;
				if (!uvm_config_db #(virtual axi_if)::get(this, "", "AXI_if", AXI_cfg[i].axi_intf))
					`uvm_fatal(get_type_name(), "cannot get axi_if for AXI_agent_build")
				
				uvm_config_db #(AXI_agent_config)::set(this, $sformatf("AXI_agth[%0d]", i), "AXI_cfg", AXI_cfg[i]);
				AXI_agth[i] = AXI_agent::type_id::create($sformatf("AXI_agth[%0d]", i), this);

				// AXI reset agent build
				AXI_rst_cfg[i] = AXI_rst_agent_config::type_id::create($sformatf("AXI_rst_cfg[%0d]", i), this);
				AXI_rst_cfg[i].is_active = UVM_ACTIVE;
				if (!uvm_config_db #(virtual axi_if)::get(this, "", "AXI_if", AXI_rst_cfg[i].axi_intf))
					`uvm_fatal(get_type_name(), "cannot get axi_if for AXI_rst_agent_build")	
				if (!uvm_config_db #(virtual axi_rst_if)::get(this, "", "AXI_rst_if", AXI_rst_cfg[i].axi_rst_intf))
					`uvm_fatal(get_type_name(), "cannot get axi_rst_if for AXI_rst_agent_build")
				
				uvm_config_db #(AXI_rst_agent_config)::set(this, $sformatf("AXI_rst_agth[%0d]", i), "AXI_rst_cfg", AXI_rst_cfg[i]);
				AXI_rst_agth[i] = AXI_rst_agent::type_id::create($sformatf("AXI_rst_agth[%0d]", i), this);

				// AHB agent build
				AHB_cfg[i] = AHB_agent_config::type_id::create($sformatf("AHB_cfg[%0d]", i), this);
				AHB_cfg[i].is_active = UVM_ACTIVE;
				if (!uvm_config_db #(virtual ahb_if)::get(this, "", "AHB_if", AHB_cfg[i].ahb_intf))
					`uvm_fatal(get_type_name(), "cannot get ahb_if for AHB_agent build")
				
				uvm_config_db #(AHB_agent_config)::set(this, $sformatf("AHB_agth[%0d]", i), "AHB_cfg", AHB_cfg[i]);
				AHB_agth[i] = AHB_agent::type_id::create($sformatf("AHB_agth[%0d]", i), this);

				// AHB reset agent build
				AHB_rst_cfg[i] = AHB_rst_agent_config::type_id::create($sformatf("AHB_rst_cfg[%0d]", i), this);
				AHB_rst_cfg[i].is_active = UVM_ACTIVE;
				if (!uvm_config_db #(virtual ahb_if)::get(this, "", "AHB_if", AHB_rst_cfg[i].ahb_intf))
					`uvm_fatal(get_type_name(), "cannot get ahb_if for AHB_rst_agent build")
				if (!uvm_config_db #(virtual ahb_rst_if)::get(this,"", "AHB_rst_if", AHB_rst_cfg[i].ahb_rst_intf))
					`uvm_fatal(get_type_name(), "cannot get ahb_rst_if for ahb_rst_agent build")
		
				uvm_config_db #(AHB_rst_agent_config)::set(this, $sformatf("AHB_rst_agth[%0d]", i), "AHB_rst_cfg", AHB_rst_cfg[i]);
				AHB_rst_agth[i] = AHB_rst_agent::type_id::create($sformatf("AHB_rst_agth[%0d]", i), this);
			end
		
	endfunction

	function void connect_phase (uvm_phase phase);
		if (env_cfg.has_scoreboard)
			for (int i = 0; i < env_cfg.no_of_duts; i++)
				begin
					AXI_agth[i].monh.AXI_mon_port.connect(sbh[i].AXI_fifoh.analysis_export);
					AXI_rst_agth[i].monh.AXI_rst_mon_port.connect(sbh[i].AXI_rst_fifoh.analysis_export);
					AHB_agth[i].monh.AHB_mon_port.connect(sbh[i].AHB_fifoh.analysis_export);
					AHB_rst_agth[i].monh.AHB_rst_mon_port.connect(sbh[i].AHB_rst_fifoh.analysis_export);
					AXI_agth[i].monh.AXI_wdata_mon_port.connect(sbh[i].AXI_wdata_fifoh.analysis_export);
					AXI_agth[i].monh.AXI_rdata_mon_port.connect(sbh[i].AXI_rdata_fifoh.analysis_export);
				end
	endfunction

endclass

