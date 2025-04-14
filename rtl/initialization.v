module initialization(
	input clk,
	input rst,
	input [11:0] count_ip,
	input	[127:0] key_in,
	input	[127:0] iv_in,
	output 	ca_out,
	output 	cb_out,
	output	mbit_out
);

	reg mbit_r;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			mbit_r <= 1'b0;
		end else if (count_ip >= 12'd1665) begin
			mbit_r <= key_in[12'd1792 - count_ip];
		end else if (count_ip >= 12'd1537) begin
			mbit_r <= iv_in[12'd1664 - count_ip];
		end else if (count_ip == 12'd1536) begin
			mbit_r <= key_in[0] ^ 1'b1;
		end else if (count_ip >= 12'd1 & count_ip <= 12'd1535) begin
			mbit_r <= key_in[count_ip % 128];
		end else begin
			mbit_r <= 'b0;
		end
	end

	assign ca_out = (count_ip <= 'd1792) ? 1'b1 : 1'b0;
	assign cb_out = (count_ip <= 'd1792) ? 1'b1 : 1'b0;

	/*
	assign mbit_out = rst ? 1'b0 :
							(count_ip >= 12'd1665) ? key_in[12'd1792 - count_ip] : 
							(count_ip >= 12'd1537) ? iv_in[12'd1664 - count_ip] :
							(count_ip == 12'd1536) ? key_in[0] ^ 1'b1 : 
							(count_ip >= 12'd1 & count_ip <= 12'd1535) ? key_in[count_ip % 128] :
													 1'b0 ;
	*/
	assign mbit_out = mbit_r;
endmodule
