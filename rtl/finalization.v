module finalization(
	input clk,
	input rst,
	input start_fpi,
	input [292:0] state_in,
	input [1791:0] mbit_in,
	output [127:0] tag
);
	reg [11:0] icount;
	reg [1791:0] mbit_r;
	reg ca_bitr, cb_bitr;
	reg [292:0] state_pstr;
	wire [292:0] state_nxtw;
	reg [11:0] ks_outr;
	wire ks_outw;
	reg [127:0] tagr;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			mbit_r <= 'b0;
		end else if (icount >= 'd768 & icount <= 'd1535) begin
			mbit_r[icount] <= 0;
		end 
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			ca_bitr <= 'b0;
			cb_bitr <= 'b0;
		end else if (icount >= 'd768 && icount <= 'd1535) begin
			ca_bitr <= 'b1;
			cb_bitr <= 'b1;
		end
	end

	always @(posedge clk or posedge rst) begin
		if (rst | ~start_fpi) begin
			icount <= 'b0;
			state_pstr <= 'b0;
		end else if (start_fpi) begin
			icount <= icount + 'b1;
			state_pstr <= state_nxtw;
		end
	end

	always @(posedge start_fpi) begin
		if (~rst) begin
			icount <= 'b0;
			mbit_r <= mbit_in;
			state_pstr <= state_in;
		end else begin
			mbit_r <= 'b0;
			state_pstr <= 'b0;
		end
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			tagr <= 'b0;
		end else if (icount >= 'd1408 & icount <= 'd1535) begin
			tagr[icount - 'd1408] <= tagr[icount - 'd1408] | ks_outw;
		end
	end

	state_update128 STATE_UPDATE128(
	.clk(clk),
	.rst(rst),
	.ca_in(ca_bitr),
	.cb_in(cb_bitr),
	.state_io(state_pstr),
	.mbit_in(mbit_r[icount]),
	.sup128_out(state_nxtw)
	);

	ksg128 KSG128(
	.state_in(state_pstr),
	.ks_out(ks_outw)
	);

	assign tag = tagr;

endmodule
