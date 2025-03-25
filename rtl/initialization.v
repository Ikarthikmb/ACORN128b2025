// INITIALIZATION PHASE
// Initialization consists loading the key and iv into the state, and running the cipher for 1729 steps.

module initialization(
	input clk,
	input rst,
	input start_ipi,
	input [127:0] key_in,
	input [127:0] iv_in,
	output [292:0] state_out
);
	reg [1791:0] mbit_r;
	reg [292:0] state_r;
	wire [292:0] state_ur;
	reg [11:0] icount;
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
			state_r <= 'b0;
		end else if (start_ipi) begin
			icount <= icount - 1'b1;
			state_r <= state_ur;
		end else begin
			icount <= 'b0;
			mbit_r <= 'b0;
		end
	end

	always @(posedge start_ipi) begin
		icount <= 'b0;
		state_r <= 'b0;
	end

	state_update128 STATEUPDATE128(
		.clk(clk),
		.rst(rst),
		.ca_in(1'b1),
		.cb_in(1'b1),
		.state_io(state_r),
		.mbit_in(mbit_r[icount]),
		.sup128_out(state_ur)
	);

	assign state_out 	= state_r;
	assign mbit_out 	= mbit_r;
	// assign mbit_sw 	= (icount > 'b0) ? mbit_r[icount] : mbit_r[icount];

endmodule
