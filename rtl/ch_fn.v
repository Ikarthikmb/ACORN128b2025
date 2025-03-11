module ch_fn(
	input x, y, z,
	output reg ch_out
);
	initial begin
		ch_out = (x & y) ^ (~x & z);
	end
endmodule
