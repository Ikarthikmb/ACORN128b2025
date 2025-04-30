
module acorn128_top(
    input clk,
    input rst,
    input start_in,
    input encrypt_in,
    input	[127:0]	key_in,
    input	[127:0]	iv_in,
    input	[127:0]	plaintext_in,
    input	[127:0]	ciphertext_in,
    input	[127:0]	associated_data_in,
    input	[63:0]	data_length_in,
    output	[127:0]	ciphertext_out,
    output	[127:0]	plaintext_out,
    output	[127:0]	tag_out,
    output ready_out
);

	wire ks_outw;
	wire fbk_outw;
    reg	[127:0]	plaintext_r;
    reg	[127:0]	plaintext_outr;
	reg [11:0] counter_r;
	reg [11:0] counter_er;
	reg ready_r;
	reg [3:0] phase_r;
	reg [292:0] state_pstr;
	reg [292:0] state_nxtr;
	reg ca_state_ir;
	reg cb_state_ir;
	reg mbit_state_ir;
	reg [127:0] cipher_r;
	reg [127:0] tag_r;
	reg start_sp;
	wire ca_ip_ow, ca_ap_ow, ca_ep_ow;
	wire cb_ip_ow, cb_ap_ow, cb_ep_ow;
	wire mbit_ip_ow, mbit_ap_ow, mbit_ep_ow;

    localparam WAITING_P		= 'd0;
    localparam INITIALIZATION_P	= 'd1;
    localparam ASSOCIATED_P		= 'd2;
    localparam ENCRYPTION_P		= 'd3;
    localparam FINAL_P			= 'd4;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state_pstr <= 'b0;
		end else if(start_sp & (phase_r >= 1'b1) & (counter_r <= 'd1792) ) begin
            state_pstr <= state_nxtr;
		// end else if (start_sp & phase_r > 1'b1) begin
		end else begin
            state_pstr <= state_pstr;
		end
	end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter_r <= 'b0;
		end else if(start_sp & phase_r == 1'b1) begin
            counter_r <= counter_r - 1'b1;
		end else if(start_sp & phase_r > 1'b1) begin
            counter_r <= counter_r + 1'b1;
		end
	end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            plaintext_r <= 128'b0;
            counter_r   <= 'd1792;
            ready_r     <= 'b0;
            cipher_r     <= 'b0;
            phase_r     <= WAITING_P;
			state_pstr <= 293'b0;
			start_sp <= 1'b0;
			ca_state_ir <= 1'b0;
			cb_state_ir <= 1'b0;
			mbit_state_ir <= 1'b0;
			tag_r <= 'b0;
        end else if (start_in) begin
            case (phase_r)
				WAITING_P: begin
					phase_r <= INITIALIZATION_P;
					counter_r <= 'd1792;
					ca_state_ir <= ca_ip_ow;
					cb_state_ir <= cb_ip_ow;
					mbit_state_ir <= mbit_ip_ow;
					state_pstr <= 293'b0;
					plaintext_r <= encrypt_in ? plaintext_in : ciphertext_in;
				end

                INITIALIZATION_P: begin
					if (counter_r == 'd1792) begin
						// state_pstr <= 293'b0;
						start_sp <= 1'b1;
					end else if (counter_r > 0 & counter_r < 'd1792) begin
						ca_state_ir <= ca_ip_ow;
						cb_state_ir <= cb_ip_ow;
						mbit_state_ir <= mbit_ip_ow;
					end else if (counter_r == 'b0) begin
						phase_r <= ASSOCIATED_P;
						ca_state_ir <= ca_ap_ow;
						cb_state_ir <= cb_ap_ow;
						mbit_state_ir <= mbit_ap_ow;
					end
				end

                ASSOCIATED_P: begin
                    if (counter_r > 0 & counter_r <= 'd382) begin
						ca_state_ir <= ca_ap_ow;
						cb_state_ir <= cb_ap_ow;
						mbit_state_ir <= mbit_ap_ow;
                    end else if (counter_r == 'd383) begin
						ca_state_ir <= ca_ap_ow;
						cb_state_ir <= cb_ap_ow;
						mbit_state_ir <= mbit_ap_ow;
                        phase_r <= ENCRYPTION_P;
                    end
                end

                ENCRYPTION_P: begin
                    if (counter_r >= 12'd384 & counter_r <= 12'd511) begin
						ca_state_ir <= ca_ep_ow;
						cb_state_ir <= cb_ep_ow;
						mbit_state_ir <= mbit_ep_ow;
						cipher_r[counter_r - 12'd384] <= plaintext_in[counter_r - 12'd384] ^ ks_outw;
						// cipher_r[counter_r - 12'd384] <= plaintext_in[counter_r - 12'd384];
					end else if (counter_r > 'd511 & counter_r <= 12'd766) begin
						ca_state_ir <= ca_ep_ow;
						cb_state_ir <= cb_ep_ow;
						mbit_state_ir <= mbit_ep_ow;
					end else if (counter_r == 12'd767) begin
						ca_state_ir <= ca_ep_ow;
						cb_state_ir <= cb_ep_ow;
						mbit_state_ir <= mbit_ep_ow;
						phase_r <= FINAL_P;
					end
                end

                FINAL_P: begin
                    if (counter_r >= 12'd768 & counter_r < 12'd1408) begin
						ca_state_ir <= 1'b1;
						cb_state_ir <= 1'b1;
						mbit_state_ir <= 1'b0;
                    end else if (counter_r >= 12'd1408 & counter_r <= 12'd1535) begin
						tag_r[counter_r - 'd1408] <= tag_r[counter_r - 'd1408] | ks_outw;
                    end else if (counter_r == 'd1536) begin
                        ready_r <= 'b1;
                        start_sp <= 'b0;
                    end
                end
            endcase

        end else begin
            plaintext_r <= 128'b0;
            counter_r 	<= 'd1792;
            ready_r 	<= 'b0;
            phase_r 	<= WAITING_P;
			// $display("[INFO] Waiting for START Signal ...");
		end
    end


	initialization INITIALIZATION_M(
		.clk(clk),
		.rst(rst),
		.count_ip(counter_r),
		.key_in(key_in),
		.iv_in(iv_in),
		.ca_out(ca_ip_ow),
		.cb_out(cb_ip_ow),
		.mbit_out(mbit_ip_ow)
	);

	associated_process ASSOCIATED_M(
		.clk(clk),
		.rst(rst),
		.count_ap(counter_r), 
		.ad_in(associated_data_in),
		.ca_out(ca_ap_ow),
		.cb_out(cb_ap_ow),
		.mbit_out(mbit_ap_ow)
	);

	encryption ENCRYPTION_M(
		.clk(clk),
		.rst(rst),
		.count_ep(counter_r),
		.plaintext_in(plaintext_in),
		.ca_out(ca_ep_ow),
		.cb_out(cb_ep_ow),
		.mbit_out(mbit_ep_ow)
	);

	state_update128 STATE_UPDATE128(
		.clk(clk),
		.rst(rst),
		.ca_in(ca_state_ir),
		.cb_in(cb_state_ir),
		.fbk_in(fbk_outw),
		.state_in(state_pstr),
		.mbit_in(mbit_state_ir),
		.sup128_out(state_nxtr)
	);

	ksg128 KSG128(
		.state_in(state_pstr),
		.ks_out(ks_outw)
	);

	fbk128 FBK128(
		.state_in(state_pstr),
		.ca_in(ca_state_ir),
		.cb_in(cb_state_ir),
		.ks_in(ks_outw),
		.fout(fbk_outw)
	);

	assign ready_out 		= ready_r;
	assign tag_out 			= tag_r;
    assign ciphertext_out 	= encrypt_in ? cipher_r : 128'h0;
    assign plaintext_out 	= encrypt_in ? 128'h0 : cipher_r;

endmodule

