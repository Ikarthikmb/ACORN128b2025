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
    reg [127:0] plaintext_r;
	reg [3:0] testcase_r;

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

	task ground_zero;
	begin
		clk <= 'b0;
		rst <= 'b1;
		start_in <= 'b0;
		encrypt_in <= 'b0;
		key_in <= 'b0;
		iv_in <= 'b0;
		plaintext_in <= 'b0;
		associated_data_in <= 'b0;
		ciphertext_in <= 'b0;
		#10;
		$display("----------------------------------------------------------------------");
		$display("[INFO] Pre Setup Completed");
	end
	endtask

	task process_data(input [3:0] testcase_i, input encrypt_i, input [127:0] cipher_in = 'h0);
	begin
		case (testcase_i)
			'd1: begin		// Testcase 1
				key_in <= 128'h00112233445566778899AABBCCDDEEFF;
				iv_in <= 128'h0123456789ABCDEF0123456789ABCDEF;
				if (encrypt_i) begin
					plaintext_in <= 128'hAABBCCDDEEFF00112233445566778899;
				end else begin
					plaintext_in <= cipher_in;
				end
				associated_data_in <= 128'h11223344556677889900AABBCCDDEEFF;
			end

			'd2: begin		// Testcase 2
				key_in <= 128'hEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE;
				iv_in <= 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
				if (encrypt_i) begin
					plaintext_in <= 128'h66666666666666666666666666666666;
				end else begin
					plaintext_in <= cipher_in;
				end
				associated_data_in <= 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
			end

			'd3: begin		// Testcase 3
				key_in <= {16{8'b00000001}};
				iv_in <= {16{8'b00000001}};
				if (encrypt_i) begin
					plaintext_in <= {16{8'b00000001}};
				end else begin
					plaintext_in <= cipher_in;
				end
				associated_data_in <= {16{8'b00000001}};
			end
		endcase

		#10; 
		if (encrypt_i) begin
			$display("[INFO] STARTING ENCRYPTION");
			$display("[ECRP] Plain: %h", plaintext_in);
		end else begin
			$display("[INFO] STARTING DECRYPTION");
			$display("[ECRP] Cipher: %h", plaintext_in);
		end

		$display("[ECRP] Key   : %h", key_in);
		$display("[ECRP] IV    : %h", iv_in);
		$display("[ECRP] AD    : %h", associated_data_in);

		wait (ready_out);

		if (encrypt_i) begin
			$display("\n[INFO] ENCRYPTION READY");
			
			ciphertext_r = ciphertext_out;
			
			$display("[ECRP] Cipher: %h", ciphertext_r);
			$display("[ECRP] Tag   : %h", tag_out);
		end else begin
			$display("\n[INFO] DECRYPTION READY");
			
			plaintext_r = ciphertext_out;
			
			$display("[DCRP] Plain: %h", plaintext_r);
			$display("[DCRP] Tag: %h", tag_out);
		end

	end
	endtask

	task verify_encryption;
	begin
		if (plaintext_r == ciphertext_r) begin
			$display("\n[INFO] Verification Success");
		end else begin
			$display("\n[ERROR] Verification Failed");
		end
	end
	endtask

    initial begin
		testcase_r <= 'd2;		// Change TESTCASE here

		ground_zero();
		@(posedge clk) rst <= 0;

		@(posedge clk);
        start_in <= 1;
        encrypt_in <= 1;
		
		// [PROCESS] Encryption
		@(posedge clk);
		process_data(testcase_r, encrypt_in);
        
		// [PROCESS] Decryption
		ground_zero();
		@(posedge clk) rst <= 0;

		@(posedge clk);
        start_in <= 1;
        encrypt_in <= 1;

		process_data(testcase_r, 'b0 , ciphertext_r);

		verify_encryption();

        #10 rst <= 1;
		$finish;
    end

	initial begin
		$dumpfile("acorn128_tb.vcd");
		$dumpvars(0, acorn128_tb);
	end

endmodule

