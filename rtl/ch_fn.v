module ch_fn(
	input x, y, z,
	output ch_out
);
	assign ch_out = (x & y) ^ (~x & z);
endmodule
