module initialization_tb();

	reg clk;
	reg rst;
	reg [127:0] key_in;
	reg [127:0] iv_in;
	wire [292:0] state_out;
	wire [1791:0] mbit_out;
	wire ca_out;
	wire cb_out;
	reg [8*43:0] lline;

	always #5 clk <= ~clk;

	initial begin
		lline = "========== ========== ========== ==========\n";
		$monitor ("rst\t: %b\n", rst, "key\t: %0h\n",key_in,"IV\t: %0h\n", iv_in,"State\t: %0h\n", state_out,"Mbit\t: %0h\n", mbit_out,"CA\t: %0h\n", ca_out,"CB\t: %0h\n", cb_out, "%s", lline);
		#(1792*2+2) $finish;
	end

	initial begin 
		clk <= 'b0;
		rst <= 'b1;
		key_in <= 'b0;
		iv_in <= 'b0;
	end

	initial begin
		// Test case 3
		#10;
		rst <=0;
        key_in <= {16{8'b00000001}};
        iv_in <= {16{8'b00000001}};
	end

	initialization INITIALIZATION(
	.clk(clk),
	.rst(rst),
	.key_in(key_in),
	.iv_in(iv_in),
	.state_out(state_out),
	.mbit_out(mbit_out),
	.ca_out(ca_out),
	.cb_out(cb_out)
	);

endmodule
