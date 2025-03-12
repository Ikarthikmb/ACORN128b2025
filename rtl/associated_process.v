module associated_process(
	input clk, rst,
	input [292:0] state_in,
	output [382:0] mbit_out,
	output ca_bit,
	output cb_bit,
	output [292:0] state_out
);
	wire [292:0] state_outr;
	reg [11:0] icount;
	reg [127:0] ad;
	reg [382:0] mbit_r;
	reg ca_bitr, cb_bitr;

	// phase 1: m[adlen-1:0] = ad[i:0]
	// phase 2: m[adlen] = 1
	// phase 3: m[adlen+255: adlen+i] = 0 
	always @(posedge clk or negedge rst) begin
		if (rst) begin
			mbit_r <= 'b0;
		end else if (icount < 'd128) begin
			mbit_r[icount] <= ad[icount];
		end else if (icount == 'd128) begin
			mbit_r[icount] <= 'b1;
		end else if (icount > 'd128 & icount <= 'd255) begin
			mbit_r[icount] <= 'b0;
		end
	end

	// C-bit Phase 1: ca[adlen+127:0] = 1
	// C-bit Phase 2: ca[adlen+255:adlen_128] = 1
	always @(posedge clk or negedge rst) begin
		if (rst) begin
			ca_bitr <= 'b0;
		end else if (icount <= 'd127) begin
			ca_bitr <= 'b1;
		end else if (icount > 'd127 & icount <= 'd255) begin
			ca_bitr <= 'b0;
		end
	end

	// C-bit Phase 1: cb[adlen+255:0] = 1
	always @(posedge clk or negedge rst) begin
		if (rst) begin
			cb_bitr <= 'b0;
		end else if (icount <= 'd255) begin
			cb_bitr <= 'b1;
		end
	end

	always @(posedge clk or negedge rst) begin
		if (rst) begin
			icount <= 'b0;
		end else begin
			icount <= icount + 1'b1;
		end
	end

	state_update128 STATE_UPDATE128(
	.clk(clk),
	.rst(rst),
	.ca_in(ca_in),
	.cb_in(cb_in),
	.state_io(state_in),
	.mbit_in(mbit_r),
	.sup128_out(state_outr)
	);

	assign state_out = state_outr;
	assign ca_bit = ca_bitr;
	assign cb_bit = cb_bitr;
	assign mbit_out = mbit_r;

endmodule
