#Makefile


TOP = ../tb/top.sv
PKG = ../tb/top_pkg.sv
INC = +incdir+../AXI_agt/ +incdir+../AXI_rst_agt/ +incdir+../AHB_agt/ +incdir+../AHB_rst_agt/ +incdir+../tb/ +incdir+../test/ +incdir+../AXI2AHB_RTL/

#/home2/B126/AKSSolomon/AXI2AHB_RTL
RTL = ../AXI2AHB_RTL/*.v
INTF = ../AXI2AHB_RTL/*.sv

TESTNAME = AHB_normal_test
# VCS Commands

cmp_VCS:
	vcs -l out.log -timescale=1ns/1ns -sverilog -ntb_opts uvm -debug_access+all $(INC) $(PKG) $(INTF) $(TOP) $(RTL)

sim_VCS: cmp_VCS
	./simv -a out.log +UVM_TESTNAME=$(TESTNAME) +ntb_random_seed_automatic -cm_dir ./cov_data
	urg -dir cov_data.vdb -format both -report covReport

run_test_1: cmp_VCS
	./simv -a out.log +UVM_TESTNAME=AXI_write_fixed_test +ntb_random_seed_automatic -cm_dir ./axifixed_data
	urg -dir axifixed_data.vdb -format both -report axifixedReport

run_test_2: cmp_VCS
	./simv -a out.log +UVM_TESTNAME=AXI_write_increment_test +ntb_random_seed_automatic -cm_dir ./axiincrement_data
	urg -dir axiincrement_data.vdb -format both -report axiincrementReport

run_test_3: cmp_VCS
	./simv -a out.log +UVM_TESTNAME=AXI_write_wrapped_test +ntb_random_seed_automatic -cm_dir ./axiwrapped_data
	urg -dir axiwrapped_data.vdb -format both -report axiwrappedReport

run_test_4: cmp_VCS
	./simv -l axireadincr.log +UVM_TESTNAME=AXI_read_increment_test +ntb_random_seed_automatic -cm_dir ./axireadincr_data
	urg -dir axireadincr_data.vdb -format both -report axireadincrReport

run_all: run_test_1 run_test_2 run_test_3 run_test_4

report:
	urg -dir cov_data.vdb axifixed_data.vdb axiincrement_data.vdb axiwrapped_data.vdb axireadincr_data.vdb -format both -report regressReport

run_VCS: cmp_VCS sim_VCS

clean_VCS:
	rm -rf csrc simv* ucli* vc* *.log novas.* ver*
	clear

# Questa Commands

work = work

cmp_Questa:
	vlib $(work)
	vmap work $(work)
	vlog -work $(work) $(INC) $(PKG) $(INTF) $(TOP) $(RTL)

sim_Questa:
	vsim -vopt -voptargs=+acc -c -do  " log -r /* ;run -all; exit" -l qlog.log work.top +UVM_TESTNAME=$(TESTNAME)

run_Questa: cmp_Questa sim_Questa

clean_Questa:
	rm -rf transcript* *log*  vsim.wlf fcover* covhtml* mem_cov* *.wlf modelsim.ini work
	clear
 
