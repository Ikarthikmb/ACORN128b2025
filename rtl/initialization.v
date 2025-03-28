// INITIALIZATION PHASE
// Initialization consists loading the key and iv into the state, and running the cipher for 1729 steps.

module initialization(
	input clk,
	input rst,
	input start_ipi,
	input	[127:0] key_in,
	input	[127:0] iv_in,
	output	[1791:0] mbit_out,
	output	[292:0] state_out
);
	reg [11:0] icount;
	reg [1791:0] mbit_r;
	reg [292:0] state_pstr;

	wire [292:0] state_nxtw;
	wire mbit_sw;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			mbit_r <= 'b0;
		end else if (icount >= 'd1665 && icount <= 'd1792) begin
			mbit_r[icount] <= key_in['d1792 - icount];
		end else if (icount >= 'd1537 && icount <= 'd1664) begin
			mbit_r[icount] <= iv_in['d1664 - icount];
		end else if (icount == 'd1536) begin
			// mbit_r[icount] <= key_in[0] ^ 1;
			mbit_r[icount] <= 'b0;
		end else if (icount >= 'd1 && icount <= 'd1535) begin
			mbit_r[icount] <= key_in[icount % 'd128];
		end else begin
			mbit_r[icount] <= 'b0;
		end
	end

	always @(posedge clk or posedge rst) begin
		if (rst | icount == 'd0) begin
			icount <= 'd1792;
			state_pstr <= 'b0;
		end else if (start_ipi) begin
			icount <= icount - 1'b1;
			state_pstr <= state_nxtw;
		end else begin
			icount <= 'b0;
			mbit_r <= 'b0;
		end
	end

	always @(posedge start_ipi) begin
		icount <= 'b0;
		state_pstr <= 'b0;
		mbit_r <= 'b0;
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

	assign state_out 	= state_pstr;
	assign mbit_out 	= mbit_r;
	// assign mbit_sw 	= ( (icount > 1'b0) & (icount < 'd1792) ) ? mbit_r[icount+1'b1] : 1'b0;
	assign mbit_sw 	= (icount < 'd1792) ? mbit_r[icount] : 1'b0;

endmodule
