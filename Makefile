test:
	echo "Make file test"

bool:
	cd rtl
	iverilog -o bool.out -Wall -g2012 maj_fn.v ch_fn.v
	vvp bool.out
	cd ../

fun:
	iverilog -o fbk128.out -Wall -g2012 fbk128.v maj_fn.v ksg128.v ch_fn.v

clean: 
	rm *.out
