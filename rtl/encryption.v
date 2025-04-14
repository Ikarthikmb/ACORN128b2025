module encryption(
	input clk,
	input rst,
	input [11:0] count_ep,
	input	[127:0] plaintext_in,
	output 	ca_out,
	output 	cb_out,
	output	mbit_out
);

	reg mbit_r;
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			mbit_r <= 1'b0;
		end else if (count_ep >= 'd384 & count_ep <= 12'd511) begin
			mbit_r <= plaintext_in['d511 - count_ep];
		end else if (count_ep == 12'd512) begin
			mbit_r <= 1'b1;
		end else if (count_ep >= 12'd513) begin
			mbit_r <= 1'b0;
		end else begin
			mbit_r <= 1'b0;
		end
	end

	/*
	assign mbit_out = rst ? 1'b0 : 
							(count_ep >= 'd384 & count_ep <= 12'd511) ? plaintext_in['d511 - count_ep] :
							(count_ep == 12'd512) ? 1'b1 : 
							(count_ep >= 12'd513) ? 1'b0 :
													1'b0 ;
	*/

	reg ca_r, cb_r;
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			ca_r 	<= 1'b0;
		end else if (count_ep <= 12'd639) begin
			ca_r <= 1'b1;
		end else begin
			ca_r <= 1'b0;
		end 
	end

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			cb_r 	<= 1'b0;
		end else begin
			cb_r 	<= 1'b0;
		end
	end

	/*
	ca_out 	= rst ? 1'b0 :
							(count_ep <= 12'd639) ? 1'b1 :
													1'b0 ;
	cb_out 	= rst ? 1'b0 : 1'b0;
	*/
	assign mbit_out = mbit_r;
	assign ca_out = ca_r;
	assign cb_out = cb_r;
endmodule
