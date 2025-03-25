module associated_process(
	input clk, rst,
	input start_ppi,
	input [1791:0] mbit_in,
	input [292:0] state_in,
	input [127:0] ad_in,
	output [1791:0] mbit_out,
	output [292:0] state_out
);
	reg [11:0] icount;
	reg [1791:0] mbit_r;
	reg [292:0] state_pstr;
	reg ca_ar, cb_ar;

	wire [292:0] state_nxtw;
	wire mbit_sw;


	always @(posedge clk or posedge rst) begin
		if (rst) begin
			mbit_r <= 'b0;
		end else if (icount < 'd128) begin
			mbit_r[icount] <= ad_in[icount];
		end else if (icount == 'd128) begin
			mbit_r[icount] <= 1'b1;
		end else if (icount > 'd128 & icount <= 'd255) begin
			mbit_r[icount] <= 1'b0;
		end
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			ca_ar <= 1'b0;
		end else if ( (icount >= 1'b0) & (icount <= 'd127) ) begin
			ca_ar <= 1'b1;
		end else if (icount > 'd127 & icount <= 'd255) begin
			ca_ar <= 1'b0;
		end
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			cb_ar <= 1'b0;
		end else if (icount <= 'd255) begin
			cb_ar <= 1'b1;
		end
	end

	always @(posedge start_ppi) begin
		icount <= 1'd0;
		state_pstr <= state_in;
		mbit_r <= mbit_in;
	end

	always @(posedge clk or posedge rst) begin
		if (rst | icount == 'd256) begin
			icount <= 'b0;
			state_pstr <= 'b0;
		end else if (start_ppi) begin
			icount <= icount + 1'b1;
			state_pstr <= state_nxtw;
		end else begin
			icount <= 'b0;
		end
	end

	state_update128 STATE_UPDATE128(
		.clk(clk),
		.rst(rst),
		.ca_in(ca_in),
		.cb_in(cb_in),
		.state_io(state_pstr),
		.mbit_in(mbit_sw),
		.sup128_out(state_nxtw)
	);

	assign state_out = state_pstr;
	assign mbit_sw 	= ( (icount > 1'b0) & (icount < 'd257) ) ? mbit_r[icount] : 1'b0;
	assign mbit_out = mbit_r;

endmodule
