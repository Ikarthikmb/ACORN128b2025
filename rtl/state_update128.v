module state_update128(
	input clk, rst,
	input ca_in, cb_in,
	input [292:0] state_io,
	input mbit_in,
	output [292:0] sup128_out
);
	wire ks_out, fout;
	reg [292:0] state_reg;

	always @(posedge clk or negedge rst) begin
		state_reg <= state_io;
		if (rst) begin
			state_reg <= 'b0;
		end else begin
			state_reg[289] 	<= state_reg[289] ^ state_reg[235] ^ state_reg[230];
			state_reg[230] 	<= state_reg[230] ^ state_reg[196] ^ state_reg[193];
			state_reg[193] 	<= state_reg[193] ^ state_reg[160] ^ state_reg[154];
			state_reg[154] 	<= state_reg[154] ^ state_reg[111] ^ state_reg[107];
			state_reg[107] 	<= state_reg[107] ^ state_reg[66]  ^ state_reg[61];
			state_reg[61] 	<= state_reg[61]  ^ state_reg[23]  ^ state_reg[0];
		end
	end

	ksg128 KSG128(.clk(clk), .rst(rst), .state_in(state_reg), .ks_out(ks_out));
	fbk128 FBK128(.clk(clk), .rst(rst), .state_in(state_reg), .ca_in(ca_in), .cb_in(cb_in), .fout(fout));

	assign sup128_out[291:0] = state_reg << 1'b1;
	assign sup128_out[292] = fout ^ mbit_in;
endmodule
