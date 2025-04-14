
module state_update128(
	input clk,
	input rst,
	input ca_in,
	input cb_in,
	input fbk_in,
	input [292:0] state_in,
	input mbit_in,
	output [292:0] sup128_out
);
	reg [292:0] state_reg;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			state_reg <= 'b0;
		end else begin
			state_reg[292] 		<= fbk_in ^ mbit_in;
			state_reg[291:289] <= state_in[292:290];
			state_reg[288] 	<= state_in[289] ^ state_in[235] ^ state_in[230];
			state_reg[287:230] <= state_in[288:231];
			state_reg[229] 	<= state_in[230] ^ state_in[196] ^ state_in[193];
			state_reg[228:193] <= state_in[229:194];
			state_reg[192] 	<= state_in[193] ^ state_in[160] ^ state_in[154];
			state_reg[191:154] <= state_in[192:155];
			state_reg[153] 	<= state_in[154] ^ state_in[111] ^ state_in[107];
			state_reg[152:107] <= state_in[153:108];
			state_reg[106] 	<= state_in[107] ^ state_in[66]  ^ state_in[61];
			state_reg[105:61] <= state_in[106:62];
			state_reg[60] 	<= state_in[61]  ^ state_in[23]  ^ state_in[0];
			state_reg[59:0] <= state_in[60:1];
		end
	end

	assign sup128_out 		= rst ? 1'b0 : state_reg;

endmodule
