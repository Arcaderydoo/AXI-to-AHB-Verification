package top_pkg;

	import uvm_pkg::*;
	`include "uvm_macros.svh"

	`include "env_config.sv"

	`include "AXI_xtn.sv"
	`include "AXI_seqs.sv"
	`include "AXI_sequencer.sv"
	`include "AXI_driver.sv"
	`include "AXI_monitor.sv"
	`include "AXI_agent_config.sv"
	`include "AXI_agent.sv"

	`include "AXI_rst_xtn.sv"
	`include "AXI_rst_seqs.sv"
	`include "AXI_rst_sequencer.sv"
	`include "AXI_rst_driver.sv"
	`include "AXI_rst_monitor.sv"
	`include "AXI_rst_agent_config.sv"
	`include "AXI_rst_agent.sv"

	`include "AHB_xtn.sv"
	`include "AHB_seqs.sv"
	`include "AHB_sequencer.sv"
	`include "AHB_driver.sv"
	`include "AHB_monitor.sv"
	`include "AHB_agent_config.sv"
	`include "AHB_agent.sv"

	`include "AHB_rst_xtn.sv"
	`include "AHB_rst_seqs.sv"
	`include "AHB_rst_sequencer.sv"
	`include "AHB_rst_driver.sv"
	`include "AHB_rst_monitor.sv"
	`include "AHB_rst_agent_config.sv"
	`include "AHB_rst_agent.sv"
	
	`include "scoreboard.sv"
	`include "env.sv"

	`include "test.sv"

endpackage
