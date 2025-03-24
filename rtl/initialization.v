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
		end else if (icount >= 'd0 && icount <= 'd127) begin
			mbit_r[icount] <= key_in[icount];
		end else if (icount > 'd127 && icount <= 'd255) begin
			mbit_r[icount] <= key_in[icount - 'd128];
		end else if (icount == 'd256) begin
			mbit_r[icount] <= key_in[0] ^ 1;
		end else if (icount > 'd256 && icount <= 'd1535) begin
			mbit_r[icount] <= key_in[(icount - 'd256) % 'd128];
		end else begin
			mbit_r[icount] <= 'b0;
		end
	end

	always @(posedge clk or posedge rst) begin
		if (rst | icount == 'd1793) begin
			icount <= 'b0;
			state_r <= 'b0;
		end else if (start_ipi) begin
			icount <= icount + 1'b1;
			state_r <= state_ur;
		end else begin
			icount <= 'b0;
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
		.mbit_in(mbit_sw),
		.sup128_out(state_ur)
	);

	assign state_out 	= state_r;
	assign mbit_out 	= mbit_r;
	assign mbit_sw 	= (icount > 'b0) ? mbit_r[icount-1'b1] : mbit_r[icount];

endmodule
