module finalization(
	input clk,
	input rst,
	input [292:0] state_in,
	output [127:0] tag
);
	reg [11:0] icount;
	reg [767:0] mbit_r;
	reg ca_bitr, cb_bitr;
	wire [292:0] state_outr;
	reg [11:0] ks_outr;
	wire ks_outw;
	reg [127:0] tagr;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			mbit_r <= 'b0;
		end else begin
			mbit_r[768 + icount] <= 0;
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
		if (rst) begin
			icount <= 'b0;
		end else begin
			icount <= icount + 'b1;
		end
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			tagr <= 'b0;
		end else if (icount >= 'd1407 && icount <= 1535) begin
			tagr <= tagr || ks_outw;
		end
	end

	state_update128 STATE_UPDATE128(
	.clk(clk),
	.rst(rst),
	.ca_in(ca_bitr),
	.cb_in(cb_bitr),
	.state_io(state_in),
	.mbit_in(mbit_r[icount]),
	.sup128_out(state_outr)
	);

	ksg128 KSG128(
	.state_in(state_in),
	.ks_out(ks_outw)
	);

endmodule
