module maj_fn(
	input x, y, z,
	output maj_out
);
	assign maj_out = (x & y) ^ (x & z) ^ (y & z);
endmodule
