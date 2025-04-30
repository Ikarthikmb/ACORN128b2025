# Makefile
bool: rtl/ch_fn.v rtl/maj_fn.v
	iverilog -o bool.out -Wall -g2012 rtl/maj_fn.v rtl/ch_fn.v
	vvp bool.out

tb: rtl/associated_process.v rtl/encryption.v rtl/finalization.v rtl/ksg128.v rtl/state_update128.v rtl/acorn128_top.v rtl/ch_fn.v rtl/fbk128.v rtl/initialization.v rtl/maj_fn.v sim/acorn128_tb.v 
	iverilog -o sim/tb.out -g2012 rtl/associated_process.v rtl/encryption.v rtl/finalization.v rtl/ksg128.v rtl/state_update128.v rtl/acorn128_top.v rtl/ch_fn.v rtl/fbk128.v rtl/initialization.v rtl/maj_fn.v sim/acorn128_tb.v 
	vvp sim/tb.out

tb-debug: rtl/associated_process.v rtl/encryption.v rtl/finalization.v rtl/ksg128.v rtl/state_update128.v rtl/acorn128_top.v rtl/ch_fn.v rtl/fbk128.v rtl/initialization.v rtl/maj_fn.v sim/acorn128_tb.v  
	iverilog -E -o sim/tb.out -g2012 -DEBUG=1 rtl/associated_process.v rtl/encryption.v rtl/finalization.v rtl/ksg128.v rtl/state_update128.v rtl/acorn128_top.v rtl/ch_fn.v rtl/fbk128.v rtl/initialization.v rtl/maj_fn.v sim/acorn128_tb.v
	vvp sim/tb.out

fun:
	iverilog -o fbk128.out -Wall -g2012 fbk128.v maj_fn.v ksg128.v ch_fn.v

clean: 
	rm *.out
.PHONY:
	clean tb
