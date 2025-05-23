module fbk128(
	input [292:0] state_in,
	input ca_in,
	input cb_in,
	output fout
);
	wire maj_out;
	wire ks_out;

	maj_fn MAJ(state_in[244], state_in[23], state_in[160], maj_out);
	ksg128 KSG128(state_in, ks_out);

	assign fout = state_in[0] ^ ~state_in[107] ^ maj_out ^ (ca_in & state_in[196]) ^ (cb_in & ks_out);

endmodule
