module associated_process(
	input clk,
	input rst,
	input [11:0] count_ap, 
	input	[127:0] ad_in,
	output	ca_out,
	output	cb_out,
	output	mbit_out
);

	reg mbit_r;
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			mbit_r <= 1'b0;
		end else if (count_ap <= 12'd127) begin
			mbit_r <= ad_in[count_ap];
		end else if (count_ap == 12'd128) begin
			mbit_r <= 1'b1;
		end else begin
			mbit_r <= 1'b0 ;
		end

	end

	assign ca_out = (count_ap <= 'd255) ? 1'b1 : 1'b0;
	assign cb_out = 1'b1;
	assign mbit_out = mbit_r;

endmodule
