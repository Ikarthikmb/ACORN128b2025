module ch_fn(
	input x, y, z,
	output ch_out
);
	// LAB Problem: Correct ch_out here
	// assign ch_out = 'b0;
	
	// LAB Solution
	assign ch_out = (x & y) ^ (~x & z);
endmodule
