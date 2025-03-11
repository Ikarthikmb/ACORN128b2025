module maj_fn(
	input x, y, z,
	output reg maj_out
);

	initial begin
		maj_out = (x & y) ^ (x & z) ^ (y & z);
	end
endmodule
