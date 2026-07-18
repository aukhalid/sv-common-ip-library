RTL_SRC = $(wildcard rtl/*.sv)
TB_SRC  = $(wildcard tb/*.sv)

.PHONY: lint sim clean

lint:
	verilator --lint-only -Wall $(RTL_SRC)

sim:
	xvlog -sv $(RTL_SRC) $(TB_SRC)
	xelab tb_top -s sim_snapshot
	xsim sim_snapshot -runall

clean:
	rm -rf xsim.dir/ *.log *.jou *.vcd
