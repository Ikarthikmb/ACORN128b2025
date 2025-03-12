module encryption(
	input clk,
	input rst,
	input [292:0] state_in,
	input ca_in, 
	input cb_in,
	input [127:0] plaintext_in,
	output ca_bito, 
	output cb_bito,
	output [127:0] cipher_out
);
	reg [767:0] mbit_r;
	reg [127:0] cipher_r;
	reg ca_bitr, cb_bitr;
	reg [11:0] icount;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			mbit_r <= 'b0;
		end else if (icount >= 'd0 && icount < 'd128) begin
			mbit_r[384+icount] <= plaintext_in[icount];
		end else if (icount == 'd128) begin
			mbit_r[384+icount] <= 'b1;
		end else if (icount >= 'd129 && icount <= 'd383) begin
			mbit_r[384+icount] <= 'b0;
		end
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			ca_bitr <= 'b0;
		end else if (icount >= 'd384 && icount <= 'd639) begin
			ca_bitr <= 'b1;
		end else if (icount >= 'd640 && icount <= 'd767) begin
			ca_bitr <= 'b0;
		end
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			cb_bitr <= 'b0;
		end else if (icount >= 'd384 && icount <= 'd767) begin
			cb_bitr <= 'b0;
		end else begin
			cb_bitr <= 'b0;
		end
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			cb_bitr <= 'b0;
		end else if (icount >= 384 && icount <= 767) begin
			cb_bitr <= 'b0;
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
			cipher_r <= 'b0;
		end else if (icount <= 'd384 && icount <= 'd767) begin
			cipher_r['d384 - icount] <= plaintext_in['d384 - icount] ^  ks_out;
		end
	end

	state_update128 STATE_UPDATE128(
	.clk(clk),
	.rst(rst),
	.ca_in(ca_bitr),
	.cb_in(cb_bitr),
	.state_io(state_in),
	.mbit_in(mbit_r),
	.sup128_out(state_outr)
	);

	ksg128 KSG128(
	.clk(clk),
	.rst(rst),
	.state_in(state_in),
	.ks_out(ks_out)
	);

	assign cipher_out = cipher_r;
	assign ca_bito = ca_bitr;
endmodule
