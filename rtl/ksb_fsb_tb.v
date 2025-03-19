module ksb_fsb_tb();

	reg clk;
	reg rst;
	reg [292:0] state_in;
	reg ca_in;
	reg cb_in;

	wire fout;
	wire ks_out;

	always #5 clk <= ~clk;

	initial begin
		clk <= 'b0;
		rst <= 'b1;
		ca_in <= 'b0;
		cb_in <= 'b0;
		state_in <= 'b0;
	end

	initial begin
		#10 rst <= 'b0;
		state_in <= {32{8'b0101_0101}};
		#5 state_in <= {32{8'b0101_1111}};
		#5 state_in <= {32{8'b0101_0000}};
		#5 state_in <= {32{8'b1111_0000}};
		#5 state_in <= {32{8'b1100_0011}};
	end

	initial begin
		$monitor("rst\t: ", rst, "\nS\t: %0h", state_in, "\nCA\t: ", ca_in, "\nCB\t: ", cb_in, "\nFB\t: ", fout, "\nKB\t: ", ks_out, "\n--------");
		#200 $finish;
	end
	
	fbk128 FBK128(
		.state_in(state_in),
		.ca_in(ca_in),
		.cb_in(cb_in),
		.fout(fout)
	);

	ksg128 KSG128(
		.state_in(state_in),
		.ks_out(ks_out)
	);

endmodule
