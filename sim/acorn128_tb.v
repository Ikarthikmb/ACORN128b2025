`timescale 1ns / 1ps

module acorn128_tb();
    reg clk;
    reg rst;
    reg start_in;
    reg encrypt_in;
    reg [127:0] key_in;
    reg [127:0] iv_in;
    reg [127:0] plaintext_in;
    reg [127:0] ciphertext_in;
    reg [127:0] associated_data_in;
    reg [63:0] data_length_in;
    reg [127:0] ciphertext_r;
    wire [127:0] ciphertext_out;
    wire [127:0] plaintext_out;
    wire [127:0] tag_out;
    wire ready_out;

    acorn128_top DUT(
    .clk(clk),
    .rst(rst),
    .start_in(start_in),
    .encrypt_in(encrypt_in),
    .key_in(key_in),
    .iv_in(iv_in),
    .plaintext_in(plaintext_in),
    .ciphertext_in(ciphertext_in),
    .associated_data_in(associated_data_in),
    .data_length_in(data_length_in),
    .ciphertext_out(ciphertext_out),
    .plaintext_out(plaintext_out),
    .tag_out(tag_out),
    .ready_out(ready_out)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        #10 rst = 0;
        start_in = 0;
		
		/*
		// Case 1
        key = 128'h00112233445566778899AABBCCDDEEFF;
        iv = 128'h0123456789ABCDEF0123456789ABCDEF;
        plaintext = 128'hAABBCCDDEEFF00112233445566778899;
        associated_data = 128'h11223344556677889900AABBCCDDEEFF;
        data_length = 64'd128;
		*/

		// Case 2
        key_in = 128'hEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE;
        iv_in = 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        plaintext_in = 128'h66666666666666666666666666666666;
        associated_data_in = 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        data_length_in = 64'd128;
		$display("STARTING ENCRYPTION...");
		$display("Key: %h", key_in);
		$display("IV: %h", iv_in);
		$display("Plaintext: %h", plaintext_in);

        #10 start_in = 1;
        
        wait (ready_out);
		$display("ENCRYPTION READY");
        
        ciphertext_r = ciphertext_out;
        
        $display("Ciphertext: %h", ciphertext_r);
        $display("Tag: %h", tag_out);
        
		rst = 1;
		#20 rst = 0;
        encrypt_in = 0;
        start_in = 1;
		$display("\nSTARTING DECRYPTION...");
        
        wait (ready_out);
		$display("DECRYPTION READY");
        
        $display("Decrypted Plaintext: %h", plaintext_out);
        
        
        #100 $finish;
    end

endmodule

