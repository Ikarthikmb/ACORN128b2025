module ksg128(
	input [292:0] state_in,
	output ks_out
	);

	wire maj_out, ch_out;

	maj_fn MAJ(state_in[235], state_in[61], state_in[193], maj_out);
	ch_fn CH(state_in[235], state_in[61], state_in[193], ch_out);

	assign ks_out = state_in[12] ^ state_in[154] ^ maj_out ^ ch_out;

endmodule
