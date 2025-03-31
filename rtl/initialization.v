// INITIALIZATION PHASE
// Initialization consists loading the key and iv into the state, and running the cipher for 1792 steps.

module initialization(
	input clk,
	input rst,
	input start_ipi,
	input	[127:0] key_in,
	input	[127:0] iv_in,
	output 	done_ipo,
	output	[1792:0] mbit_out,
	output	[292:0] state_out
);

	reg [11:0] icount;
	reg [292:0] state_pstr;
	reg done_ipr;

	wire [292:0] state_nxtw;
	wire mbit_sw;

	always @(posedge clk or posedge rst) begin
		if (rst | icount == 'd0) begin
			icount <= 'd1793;
			state_pstr <= 'b0;
		end else if (start_ipi) begin
			icount <= icount - 1'b1;
			state_pstr <= state_nxtw;
		end
	end

	always @(posedge start_ipi) begin
		icount <= 'd1793;
		state_pstr <= 'b0;
		done_ipr <= 'b0;
	end

	state_update128 STATEUPDATE128(
		.clk(clk),
		.rst(rst),
		.ca_in(1'b1),
		.cb_in(1'b1),
		.state_io(state_pstr),
		.mbit_in(mbit_sw),
		.sup128_out(state_nxtw)
	);

	assign state_out	= state_pstr;
	assign mbit_sw 		= (icount > 0 & icount <= 1792) ? mbit_out[icount] : 1'b0;
	assign done_ipo 	= done_ipr;

	assign mbit_out[1792:1665] 	= key_in[127:0];
	assign mbit_out[1664:1537] 	= iv_in[127:0];
	assign mbit_out[1536] 		= key_in[0] ^ 1;
	assign mbit_out[1535:1409] 	= key_in[127:0];
	assign mbit_out[1408:1281] 	= key_in[127:0];
	assign mbit_out[1280:1153] 	= key_in[127:0];
	assign mbit_out[1152:1025] 	= key_in[127:0];
	assign mbit_out[1024:897] 	= key_in[127:0];
	assign mbit_out[896:769]	= key_in[127:0];
	assign mbit_out[768:641]	= key_in[127:0];
	assign mbit_out[640:513]	= key_in[127:0];
	assign mbit_out[512:385]	= key_in[127:0];
	assign mbit_out[384:257]	= key_in[127:0];
	assign mbit_out[256:129]	= key_in[127:0];
	assign mbit_out[128:1] 		= key_in[127:0];
	assign mbit_out[0] = 'b0;
endmodule
