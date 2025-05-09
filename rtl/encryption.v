module encryption(
	input clk,
	input rst,
	input start_epi,
	input	[1792:0] mbit_in,
	input	[292:0] state_in,
	input	[127:0] plaintext_in,
	output	[1792:0] mbit_out,
	output	[127:0] cipher_out
);
	reg	[11:0] icount;
	reg	[127:0] cipher_r;
	reg	[1792:0] mbit_r;
	reg	[292:0] state_pstr;
	reg ca_bitr;
	reg cb_bitr;

	wire [292:0] state_nxtw;
	wire ks_out;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			mbit_r <= 'b0;
		end else if (icount >= 'd0 & icount < 'd128) begin
			mbit_r[384+icount] <= plaintext_in[icount];
		end else if (icount == 'd128) begin
			mbit_r[384+icount] <= 'b1;
		end else if (icount >= 'd129 & icount <= 'd383) begin
			mbit_r[384+icount] <= 'b0;
		end
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			ca_bitr <= 'b0;
		end else if (icount >= 'd384 & icount <= 'd639) begin
			ca_bitr <= 'b1;
		end else if (icount >= 'd640 & icount <= 'd767) begin
			ca_bitr <= 'b0;
		end
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			cb_bitr <= 'b0;
		end else if (icount >= 'd384 & icount <= 'd767) begin
			cb_bitr <= 'b0;
		end else begin
			cb_bitr <= 'b0;
		end
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			cb_bitr <= 'b0;
		end else if (icount >= 384 & icount <= 767) begin
			cb_bitr <= 'b0;
		end
	end

	always @(posedge start_epi) begin
		if (~rst) begin
			icount <= 'b0;
			state_pstr <= state_in;
			mbit_r <= mbit_in;
		end
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			icount <= 'b0;
			state_pstr <= 'b0;
		end else if (start_epi) begin
			icount <= icount + 'b1;
			state_pstr <= state_nxtw;
		end else begin
			icount <= 'b0;
		end
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			cipher_r <= 'b0;
		end else if (icount >= 'd384 & icount <= 'd767) begin
			// LAB Problem: Pi xor ksi
			// Hint: count - 384 gives the location of Pi
			cipher_r[icount - 'd384] <= 'b0;
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
		.ks_out(ks_out)
	);

	assign cipher_out = cipher_r;
	assign mbit_out = mbit_r;
endmodule
