#Makefile

iphase:
	iverilog -o initialization_tb.out initialization_tb.v initialization.v state_update128.v fbk128.v ksg128.v ch_fn.v maj_fn.v
	vvp initialization_tb.out

kftest:
	iverilog -o ksb_fsb_tb.out ksb_fsb_tb.v fbk128.v ksg128.v maj_fn.v ch_fn.v 
	vvp ksb_fsb_tb.out
