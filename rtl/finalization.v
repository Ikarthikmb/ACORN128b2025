module finalization(
	input clk,
	input rst,
	output ca_out,
	output cb_out,
	output mbit_out
);
	assign mbit_out = 1'b0;
	assign ca_out = 1'b1;
	assign cb_out = 1'b1;
endmodule
