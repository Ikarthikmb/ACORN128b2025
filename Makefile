test:
	echo "Make file test"

bool: rtl/ch_fn.v rtl/maj_fn.v
	iverilog -o bool.out -Wall -g2012 rtl/maj_fn.v rtl/ch_fn.v
	vvp bool.out

sim: rtl/associated_process.v rtl/encryption.v rtl/finalization.v rtl/ksg128.v rtl/state_update128.v rtl/acorn128_top.v rtl/ch_fn.v rtl/fbk128.v rtl/initialization.v rtl/maj_fn.v sim/acorn128_tb.v 
	iverilog -o sim/sim.out rtl/associated_process.v rtl/encryption.v rtl/finalization.v rtl/ksg128.v rtl/state_update128.v rtl/acorn128_top.v rtl/ch_fn.v rtl/fbk128.v rtl/initialization.v rtl/maj_fn.v sim/acorn128_tb.v 
	vvp sim/sim.out
fun:
	iverilog -o fbk128.out -Wall -g2012 fbk128.v maj_fn.v ksg128.v ch_fn.v

clean: 
	rm *.out
