module top;

	import uvm_pkg::*;
	`include "uvm_macros.svh"
	import top_pkg::*;

	bit aclk, hclk;
	always #5 aclk = ~aclk;
	always #7 hclk = ~hclk;

	axi_if axi_intf (aclk);
	axi_rst_if axi_rst_intf (aclk);
	ahb_if ahb_intf (aclk);
	ahb_rst_if ahb_rst_intf (aclk);
	
	axi2ahb_bridge_top DUT (
	aclk,
	axi_rst_intf.aresetn,
	hclk,
	ahb_rst_intf.hresetn,

	//axi side
	//aw channel
	axi_intf.awid,
	axi_intf.awaddr,
	axi_intf.awlen,
	axi_intf.awsize,
	axi_intf.awburst,
	axi_intf.awvalid,
	axi_intf.awready,
	//w channel
	axi_intf.wid,
	axi_intf.wdata,
	axi_intf.wstrb,
	axi_intf.wlast,
	axi_intf.wvalid,
	axi_intf.wready,
	//ar channel
	axi_intf.arid,
	axi_intf.araddr,
	axi_intf.arlen,
	axi_intf.arsize,
	axi_intf.arburst,
	axi_intf.arvalid,
	axi_intf.arready,
	//b response
	axi_intf.bid,
	axi_intf.bresp,
	axi_intf.bvalid,
	axi_intf.bready,
	//r response
	axi_intf.rid,
	axi_intf.rdata,
	axi_intf.rresp,
	axi_intf.rlast,
	axi_intf.rvalid,
	axi_intf.rready,

	//ahb_side
	//ahb output
	ahb_intf.haddr,
	ahb_intf.htrans,
	ahb_intf.hwrite,
	ahb_intf.hsize,
	ahb_intf.hburst,
	ahb_intf.hwdata,
	ahb_intf.hbusreq,
	ahb_intf.hlock,
	//ahb input
	ahb_intf.hrdata,
	ahb_intf.hready,
	ahb_intf.hresp,
	ahb_intf.hgrant,
	ahb_intf.hmaster
);

	
	initial
		begin
			uvm_config_db #(virtual axi_rst_if)::set(null, "*", "AXI_rst_if", axi_rst_intf);
			uvm_config_db #(virtual axi_if)::set(null, "*", "AXI_if", axi_intf);
			uvm_config_db #(virtual ahb_if)::set(null, "*", "AHB_if", ahb_intf);
			uvm_config_db #(virtual ahb_rst_if)::set(null, "*", "AHB_rst_if", ahb_rst_intf);

			run_test();
		end
	
	initial
		begin
			$fsdbDumpfile("wave.fsdb");
			$fsdbDumpvars(0, top);
		end

endmodule

