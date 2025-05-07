module state_update128(
	input clk,
	input rst,
	input ca_in,
	input cb_in,
	input [292:0] state_io,
	input mbit_in,
	output [292:0] sup128_out
);
	wire ks_out, fout;
	reg [292:0] state_reg;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			state_reg <= 'b0;
		end else begin
			state_reg[292] 		<= fout ^ mbit_in;
			state_reg[291:289] <= state_io[292:290];
			state_reg[288] 	<= state_io[289] ^ state_io[235] ^ state_io[230];
			state_reg[287:230] <= state_io[288:231];
			state_reg[229] 	<= state_io[230] ^ state_io[196] ^ state_io[193];
			state_reg[228:193] <= state_io[229:194];
			state_reg[192] 	<= state_io[193] ^ state_io[160] ^ state_io[154];
			state_reg[191:154] <= state_io[192:155];
			state_reg[153] 	<= state_io[154] ^ state_io[111] ^ state_io[107];
			state_reg[152:107] <= state_io[153:108];
			state_reg[106] 	<= state_io[107] ^ state_io[66]  ^ state_io[61];
			state_reg[105:61] <= state_io[106:62];
			state_reg[60] 	<= state_io[61]  ^ state_io[23]  ^ state_io[0];
			state_reg[59:0] <= state_io[60:1];
		end
	end

	/*
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			state_reg <= 'b0;
		end else begin
			state_reg[292:290]	<= state_io[292:290];
			state_reg[289] 		<= state_io[289] ^ state_io[235] ^ state_io[230];
			state_reg[288:231]	<= state_io[288:231];
			state_reg[230] 		<= state_io[230] ^ state_io[196] ^ state_io[193];
			state_reg[229:194]	<= state_io[229:194];
			state_reg[193] 		<= state_io[193] ^ state_io[160] ^ state_io[154];
			state_reg[192:155]	<= state_io[192:155];
			state_reg[154] 		<= state_io[154] ^ state_io[111] ^ state_io[107];
			state_reg[153:108]	<= state_io[153:108];
			state_reg[107] 		<= state_io[107] ^ state_io[66]  ^ state_io[61];
			state_reg[106:62]	<= state_io[106:62];
			state_reg[61] 		<= state_io[61]  ^ state_io[23]  ^ state_io[0];
			state_reg[60:0]		<= state_io[60:0];
		end
	end

	assign sup128_out[0] 		= state_reg[292];
	assign sup128_out[291:1] 	= state_reg[290:0];
	assign sup128_out[292] 		= fout ^ mbit_in;
	*/

	assign sup128_out 		= rst ? 1'b0 : state_reg;

	ksg128 KSG128(.state_in(state_reg), .ks_out(ks_out));
	fbk128 FBK128(.state_in(state_reg), .ca_in(ca_in), .cb_in(cb_in), .fout(fout));

endmodule
