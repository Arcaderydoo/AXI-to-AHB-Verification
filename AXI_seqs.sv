class AXI_base_seqs extends uvm_sequence #(AXI_xtn);

	`uvm_object_utils(AXI_base_seqs)
	
	int len;

	function new (string name = "AXI_base_seqs");
		super.new(name);
		req = AXI_xtn::type_id::create("req");
	endfunction

	task body;
		if (!uvm_config_db #(int)::get(null, get_full_name(), "len", len))
			`uvm_info(get_full_name(), "cannot get length in AXI_seqs", UVM_LOW)
	endtask

endclass

class AXI_fixed_seqs extends AXI_base_seqs;

	`uvm_object_utils(AXI_fixed_seqs)

	function new (string name = "AXI_fixed_seqs");
		super.new(name);
	endfunction

	task body;
		super.body();	

		start_item(req);
		assert(req.randomize with {awvalid == 1'b1; wvalid == 1'b1; arvalid == 1'b1; awsize == 3'b000; awlen == len; awaddr == 2000;  bready == 1'b1; rready == 1'b1;});
		finish_item(req);

	endtask

endclass

class AXI_inc_seqs extends AXI_base_seqs;

	`uvm_object_utils(AXI_inc_seqs)

	function new (string name = "AXI_inc_seqs");
		super.new(name);
	endfunction

	task body;
		super.body();	
		start_item(req);
		assert(req.randomize with {awvalid == 1'b1; awburst == 2'b01; awlen == len; awsize == 3'd3;
		wvalid == 1'b1; arvalid == 1'b1; bready == 1'b1; rready == 1'b1;});
		finish_item(req);
	endtask

endclass


class AXI_wrap_seqs extends AXI_base_seqs;

	`uvm_object_utils(AXI_wrap_seqs)

	function new (string name = "AXI_wrap_seqs");
		super.new(name);
	endfunction

	task body;
		super.body();	
		start_item(req);
		assert(req.randomize with {awvalid == 1'b1; awaddr == 2000; awburst == 2'b10; awlen == len; awsize == 3'd0;
		wvalid == 1'b1; arvalid == 1'b1; bready == 1'b1; rready == 1'b1;});
		finish_item(req);
	endtask

endclass

//=============================================================================
// Directed sweep sequences: each issues one transaction per legal
// (size, length) combination for a given burst type, so every AWLEN/ARLEN,
// AWSIZE/ARSIZE and AWBURST/ARBURST bin is hit deterministically at least once.
//=============================================================================

// FIXED burst: sweep length 0-15 (single beat .. 16 beats) across all 4 sizes.
// (FIXED is unconstrained by the AXI4 wrap rules, but we cap at 15 here to stay
// inside this DUT's 16-deep FIFOs for a clean, backpressure-free sweep.)
class AXI_fixed_sweep_seqs extends AXI_base_seqs;

	`uvm_object_utils(AXI_fixed_sweep_seqs)

	function new (string name = "AXI_fixed_sweep_seqs");
		super.new(name);
	endfunction

	task body;
		super.body();
		for (int size = 0; size <= 3; size++) begin
			for (int len_i = 0; len_i <= 15; len_i++) begin
				start_item(req);
				assert(req.randomize with {
					awvalid == 1'b1; wvalid == 1'b1; arvalid == 1'b1;
					bready  == 1'b1; rready == 1'b1;
					awburst == 2'b00; arburst == 2'b00;
					awsize  == size;  arsize  == size;
					awlen   == len_i; arlen   == len_i;
				});
				finish_item(req);
			end
		end
	endtask

endclass

// INCR burst: sweep length 0-15 across all 4 sizes.
class AXI_inc_sweep_seqs extends AXI_base_seqs;

	`uvm_object_utils(AXI_inc_sweep_seqs)

	function new (string name = "AXI_inc_sweep_seqs");
		super.new(name);
	endfunction

	task body;
		super.body();
		for (int size = 0; size <= 3; size++) begin
			for (int len_i = 0; len_i <= 15; len_i++) begin
				start_item(req);
				assert(req.randomize with {
					awvalid == 1'b1; wvalid == 1'b1; arvalid == 1'b1;
					bready  == 1'b1; rready == 1'b1;
					awburst == 2'b01; arburst == 2'b01;
					awsize  == size;  arsize  == size;
					awlen   == len_i; arlen   == len_i;
				});
				finish_item(req);
			end
		end
	endtask

endclass

// WRAP burst: AXI4 only allows burst lengths of 2, 4, 8 or 16 beats
// (awlen/arlen == 1, 3, 7, 15). Sweep all 4 legal lengths across all 4 sizes.
// awaddr/araddr are left to the solver, which now has to satisfy the
// full wrap-window alignment constraint added to AXI_xtn.
class AXI_wrap_sweep_seqs extends AXI_base_seqs;

	`uvm_object_utils(AXI_wrap_sweep_seqs)

	int wrap_lens[4] = '{1, 3, 7, 15};

	function new (string name = "AXI_wrap_sweep_seqs");
		super.new(name);
	endfunction

	task body;
		super.body();
		foreach (wrap_lens[i]) begin
			for (int size = 0; size <= 3; size++) begin
				start_item(req);
				assert(req.randomize with {
					awvalid == 1'b1; wvalid == 1'b1; arvalid == 1'b1;
					bready  == 1'b1; rready == 1'b1;
					awburst == 2'b10; arburst == 2'b10;
					awsize  == size;       arsize  == size;
					awlen   == wrap_lens[i]; arlen == wrap_lens[i];
				});
				finish_item(req);
			end
		end
	endtask

endclass

// Comprehensive sweep: runs FIXED, then INCR, then WRAP sweeps back to back.
// This is the sequence to reach for when you want "every burst type x every
// legal length x every size" exercised in a single run.
class AXI_all_burst_len_seqs extends AXI_base_seqs;

	`uvm_object_utils(AXI_all_burst_len_seqs)

	AXI_fixed_sweep_seqs fixed_sweep;
	AXI_inc_sweep_seqs   inc_sweep;
	AXI_wrap_sweep_seqs  wrap_sweep;

	function new (string name = "AXI_all_burst_len_seqs");
		super.new(name);
	endfunction

	task body;
		fixed_sweep = AXI_fixed_sweep_seqs::type_id::create("fixed_sweep");
		inc_sweep   = AXI_inc_sweep_seqs::type_id::create("inc_sweep");
		wrap_sweep  = AXI_wrap_sweep_seqs::type_id::create("wrap_sweep");

		fixed_sweep.start(m_sequencer, this);
		inc_sweep.start(m_sequencer, this);
		wrap_sweep.start(m_sequencer, this);
	endtask

endclass

// Randomized complement to the directed sweeps above: lets the class-level
// constraints in AXI_xtn (burst/size/length legality, WRAP window alignment)
// pick combinations freely across many iterations. Good for catching
// interactions the directed sweep's fixed nesting order wouldn't hit
// (e.g. a specific WRAP length together with a specific unaligned-before-
// rounding address, or back-to-back bursts of different types).
class AXI_random_burst_len_seqs extends AXI_base_seqs;

	`uvm_object_utils(AXI_random_burst_len_seqs)

	int num_txns = 50;

	function new (string name = "AXI_random_burst_len_seqs");
		super.new(name);
	endfunction

	task body;
		super.body();
		repeat (num_txns) begin
			start_item(req);
			assert(req.randomize with {
				awvalid == 1'b1; wvalid == 1'b1; arvalid == 1'b1;
				bready  == 1'b1; rready == 1'b1;
			});
			finish_item(req);
		end
	endtask

endclass

// Stress/corner sequence: INCR bursts longer than the 16-deep addr/data FIFOs
// can hold in one shot, to exercise awready/wready backpressure (fifo_access
// full) mid-burst. Not required for the AWLEN[0:15] covergroup bin, but a
// valuable functional corner case given this DUT's FIFO depth.
class AXI_incr_backpressure_seqs extends AXI_base_seqs;

	`uvm_object_utils(AXI_incr_backpressure_seqs)

	int long_lens[4] = '{16, 63, 128, 255};

	function new (string name = "AXI_incr_backpressure_seqs");
		super.new(name);
	endfunction

	task body;
		super.body();
		foreach (long_lens[i]) begin
			start_item(req);
			assert(req.randomize with {
				awvalid == 1'b1; wvalid == 1'b1; arvalid == 1'b0;
				bready  == 1'b1; rready == 1'b1;
				awburst == 2'b01; awsize == 3'd3;
				awlen   == long_lens[i];
			});
			finish_item(req);
		end
	endtask

endclass

