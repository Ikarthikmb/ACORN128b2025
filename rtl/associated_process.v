module associated_process(
	input clk, rst,
	input start_ppi,
	input [292:0] state_in,
	input [127:0] ad_in,
	output [292:0] state_out
);
	reg [292:0] state_r;
	wire [292:0] state_outr;
	reg [11:0] icount;
	reg [1791:0] mbit_r;
	reg ca_ar, cb_ar;

	always @(posedge clk or negedge rst) begin
		if (rst) begin
			mbit_r <= 'b0;
		end else if (icount < 'd128) begin
			mbit_r[icount] <= ad_in[icount];
		end else if (icount == 'd128) begin
			mbit_r[icount] <= 'b1;
		end else if (icount > 'd128 & icount <= 'd255) begin
			mbit_r[icount] <= 'b0;
		end
	end

	always @(posedge clk or negedge rst) begin
		if (rst) begin
			ca_ar <= 'b0;
		end else if (icount <= 'd127) begin
			ca_ar <= 'b1;
		end else if (icount > 'd127 & icount <= 'd255) begin
			ca_ar <= 'b0;
		end
	end

	always @(posedge clk or negedge rst) begin
		if (rst) begin
			cb_ar <= 'b0;
		end else if (icount <= 'd255) begin
			cb_ar <= 'b1;
		end
	end

	always @(posedge start_ppi) begin
		icount <= 'd0;
		state_r <= state_in;
	end

	always @(posedge clk or negedge rst) begin
		if (rst | icount == 'd1793) begin
			icount <= 'b0;
		end else if (start_ppi) begin
			icount <= icount + 1'b1;
		end else begin
			icount <= 'b0;
		end
	end

	always @(posedge clk or negedge rst) begin
		if (rst) begin
			state_r <= 'b0;
		end else begin
			state_r <= state_outr;
		end
	end

	state_update128 STATE_UPDATE128(
	.clk(clk),
	.rst(rst),
	.ca_in(ca_in),
	.cb_in(cb_in),
	.state_io(state_r),
	.mbit_in(mbit_r[icount]),
	.sup128_out(state_outr)
	);

	assign state_out = state_r;

endmodule
