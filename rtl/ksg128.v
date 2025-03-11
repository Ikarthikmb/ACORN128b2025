module ksg128(
	input clk, rst,
	input [292:0] state_in,
	output ks_out
);
	reg ks_reg;
	wire maj_out, ch_out;

	maj_fn MAJ(state_in[235], state_in[61], state_in[193], maj_out);
	ch_fn CH(state_in[235], state_in[61], state_in[193], ch_out);

	always @(posedge clk or negedge rst) begin
		if (!rst) begin
			ks_reg <= state_in[12] ^ state_in[154] ^ maj_out ^ ch_out;
		end
	end

	assign ks_out = ks_reg;

endmodule
