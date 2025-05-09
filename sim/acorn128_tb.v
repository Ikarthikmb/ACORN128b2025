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
    reg [63:0] data_length_in = 'b0; 
    reg [127:0] ciphertext_r = 'b0;
    reg [127:0] cipher_excepted = 'b0;
    reg [127:0] plaintext_r = 'b0;
    reg [127:0] pt_originalr;
	reg [3:0] testcase_r;
	reg str_en = 1'b0;
	reg vdisp = 1'b0;
    reg [127:0] tag_en;
    reg [127:0] tag_de;

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
	end
	endtask

	task process_data(input [3:0] testcase_i, input encrypt_i = 1'b1, input [127:0] cipher_in = 'h0);
	begin
		case (testcase_i)
			'd0: begin		// Testcase 1
				key_in <= 128'h00000000000000000000000000000000;
				iv_in <= 128'h00000000000000000000000000000000;
				if (encrypt_i) begin
					plaintext_in <= 128'h00000000000000000000000000000000;
				end else begin
					plaintext_in <= cipher_in;
				end
				associated_data_in <= 128'h00000000000000000000000000000000;
				cipher_excepted <= 128'h8e93b04c49e8b53884233957a6ead57c;
			end
			'd1: begin		// Testcase 1
				key_in <= 128'h00112233445566778899AABBCCDDEEFF;
				iv_in <= 128'h0123456789ABCDEF0123456789ABCDEF;
				if (encrypt_i) begin
					plaintext_in <= 128'hAABBCCDDEEFF00112233445566778899;
				end else begin
					plaintext_in <= cipher_in;
				end
				associated_data_in <= 128'h11223344556677889900AABBCCDDEEFF;
				cipher_excepted <= 128'h877393273d383817020cc38796cc9453;
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
				cipher_excepted <= 128'h91e4cfd0253835ade1b2d18903763fb6;
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
				cipher_excepted <= 128'haa0cb19168936e55d314812e8c3a7e6a;
			end

			'd4: begin		// Testcase 4
				key_in <= 128'hEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE;
				iv_in <= 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
				if (encrypt_i) begin
					plaintext_in <= 128'h66666666666666666666666666666666;
				end else begin
					plaintext_in <= cipher_in;
				end
				associated_data_in <= 128'h00000000000000000000000000000000;
				cipher_excepted <= 128'h0f12362c82ecee70fe7d6846c1f868a6;	// DO NOT CHANGE
			end

			'd5: begin		// Testcase 5 using a string
				str_en <= 1'b1;
				key_in <= 128'h12312341234512345612345671234567;
				iv_in <= 128'h11111111111111111111111111111111;
				if (encrypt_i) begin
					plaintext_in <= "Hello ACORN";
				end else begin
					plaintext_in <= cipher_in;
				end
				associated_data_in <= 128'h44455556666677777788888883332222;
				cipher_excepted <= 128'h083ef7ae14e91f61a0d45393f274047c;
			end
		endcase

		@(posedge clk)
		if (encrypt_i) begin
			$display("[INFO] STARTING ENCRYPTION ...");
			if (str_en) begin
				$display("[INFO] Plain : %s", plaintext_in);
			end else begin
				$display("[INFO] Plain : %h", plaintext_in);
			end
			pt_originalr <= plaintext_in;
			$display("[INFO] Key   : %h", key_in);
			$display("[INFO] IV    : %h", iv_in);
			$display("[INFO] AD    : %h", associated_data_in);
		end else if (vdisp) begin
			$display("[INFO] STARTING DECRYPTION ...");
			$display("[INFO] Cipher : %h", plaintext_in);
		end


		@(posedge clk)
		if (vdisp)
			$display("[INFO] Waiting for READY ...");
		wait (ready_out);

		if (encrypt_i) begin
			$display("\n[INFO] ENCRYPTION READY");
			
			ciphertext_r = ciphertext_out;
			tag_en = tag_out;
			
			$display("[INFO] Cipher: %h", ciphertext_r);
			// $display("[INFO] Tag   : %h\n", tag_out);
		end else begin
			if (vdisp)
				$display("\n[INFO] DECRYPTION READY");
			
			plaintext_r = ciphertext_out;
			tag_de = tag_out;
			
			if (vdisp & str_en) begin
				$display("[INFO] Plain : %s", plaintext_r);
			end else if (vdisp & ~str_en) begin
				$display("[INFO] Plain : %h", plaintext_r);
			end

			if (vdisp)
				$display("[INFO] Tag   : %h\n", tag_out);
		end

	end
	endtask

	task verify_encryption;
	begin
		if (tag_en == tag_de) begin
			$display("[INFO] 1. Tag Verified");
		end else begin
			$display("[ERROR] Tag Verification Failed");
			$display("[ERROR] Expected tag : %h", tag_en);
			$display("[ERROR] Decryption tag : %h", tag_de);
		end

		if (pt_originalr == plaintext_r) begin
			$display("[INFO] 2. Encryption Verified");
		end else begin
			$display("\n[ERROR] Verification Failed");
			if (testcase_r == 'd5) begin
				$display("[ERROR] Expected Plaintext : %s", pt_originalr);
				$display("[ERROR] Decrypted Plaintext: %s", plaintext_r);
			end else begin
				$display("[ERROR] Expected Plaintext : %h", pt_originalr);
				$display("[ERROR] Decrypted Plaintext: %h", plaintext_r);
			end
		end

		if (ciphertext_r == cipher_excepted) begin
			$display("[INFO] 3. Lab Verified");
		end else begin
			$display("\n[ERROR] Lab Fail");
			$display("[ERROR] Expected tag	: %h", tag_en);
			$display("[ERROR] Decryption tag	: %h", tag_de);
			$display("[ERROR] Expected Plaintext : %h", pt_originalr);
			$display("[ERROR] Decrypted Plaintext: %h", plaintext_r);
			$display("[ERROR] Lab Expected Ciphertext : %h", cipher_excepted);
			$display("[ERROR] Lab Decrypted Ciphertext: %h", ciphertext_r);
		end
	end
	endtask

    initial begin
		testcase_r <= 'd4;		// Change TESTCASE here
		vdisp <= 1'b0;			// Enable verification information

		separation({60{"="}});
		ground_zero();
		$display("[INFO] Pre Setup Completed");

		@(posedge clk) rst <= 0;

		@(posedge clk);
        start_in <= 1;
        encrypt_in <= 1;
		
		// [PROCESS] Encryption
		@(posedge clk);
		process_data(testcase_r, encrypt_in);
        
		// Authentication
		$display("\n[INFO] Authentication");

		// separation({80{"-"}});
		// [PROCESS] Decryption
		ground_zero();
		if (vdisp)
			$display("[INFO] Reset Completed");
		@(posedge clk) rst <= 0;

		@(posedge clk);
        start_in <= 1;
        encrypt_in <= 1;

		process_data(testcase_r, 'b0 , ciphertext_r);

		verify_encryption;

        #10 rst <= 1;
		separation({60{"="}});

		$finish;
    end

	initial begin
		$dumpfile("acorn128_tb.vcd");
		$dumpvars(0, acorn128_tb);
	end

	task separation(input [8*60:1] ch);
	begin
		$display("%s", ch);
	end
	endtask

endmodule

