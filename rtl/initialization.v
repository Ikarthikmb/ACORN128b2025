// INITIALIZATION PHASE
// Initialization consists loading the key and iv into the state, and running the cipher for 1729 steps.

module initialization(
	input clk,
	input rst,
	input [127:0] key_in,
	input [127:0] iv_in,
	input pinitial,
	output [292:0] state_out,
	output [1791:0] mbit_out,
	output ca_out,
	output cb_out
);
	reg [1791:0] mbit_r;
	reg [292:0] state_r;
	wire [292:0] state_ur;
	reg [11:0] icount;

	always @(posedge clk or negedge rst) begin
		if (rst) begin
			icount <= 'b0;
			mbit_r <= 'b0;
		end else if (icount <= 'd127) begin
			mbit_r[icount] <= key_in[icount];
		end else if (icount > 'd127 && icount <= 'd255) begin
			mbit_r[icount] <= key_in[icount - 'd128];
		end else if (icount == 'd256) begin
			mbit_r[icount] <= key_in[0] ^ 1;
		end else if (icount > 'd256 && icount <= 'd1535) begin
			mbit_r[icount] <= key_in[(icount - 'd256) % 'd128];
		end
	end

	always @(posedge clk or negedge rst) begin
		if (rst) begin
			icount <= 'b0;
		end else begin
			icount <= icount + 1'b1;
		end
	end

	always @(posedge pinitial) begin
		if (pinitial) begin
			state_r <= 'b0;
			icount <= 'b0;
		end
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			state_r <= 'b0;
		end else begin
			state_r <= state_ur;
		end
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

	assign state_out 	= state_ur;
	assign mbit_out 	= mbit_r;
	assign ca_out 	= 1'b1;
	assign cb_out 	= 1'b1;

endmodule
