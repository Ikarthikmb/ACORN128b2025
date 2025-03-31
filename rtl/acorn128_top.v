`define DEBUG

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

	reg	start_ipr;
	reg start_ppr;
	reg start_epr;
	reg	start_fpr;
	wire done_ipw;
	wire done_ppw;
	wire done_epw;
	wire done_fpw;
	reg ready_r;
    reg [127:0]	keystream_r;
    reg [127:0]	plaintext_r;
    reg [63:0]	counter_r;
    reg [7:0]	phase_r;

    wire [127:0]	ciphertext_w;
    wire [127:0]	tag;
    wire [292:0]	state_aw;
    wire [292:0]	state_iw;
	wire [1792:0]	mbit_iow;
	wire [1792:0]	mbit_aow;
	wire [1792:0]	mbit_eow;

    localparam WAITING_P		= 'd0;
    localparam INITIALIZATION_P	= 'd1;
    localparam PROCESSING_P		= 'd2;
    localparam ENCRYPTION_P		= 'd3;
    localparam FINAL_P			= 'd4;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            keystream_r 	<= 128'b0;
            plaintext_r 	<= 128'b0;
            counter_r 		<= 'd1792;
            ready_r 		<= 'b0;
            phase_r 		<= WAITING_P;
			start_ipr 		<= 'b0;
			start_ppr 		<= 'b0;
			start_epr 		<= 'b0;
			start_fpr 		<= 'b0;
        end else if (start_in) begin
            case (phase_r)
				WAITING_P: begin
					if (encrypt_in) begin
						phase_r <= INITIALIZATION_P;
						counter_r <= 'd1792;
						start_ipr <= 'b1;
					end else begin
						phase_r <= WAITING_P;
					end
				end
                INITIALIZATION_P: begin
					if (counter_r > 0) begin 
						counter_r <= counter_r - 1;
						// ddisplay($sformatf("Initialization counter: ", counter_r));
					end else if (counter_r <= 'd1) begin
						phase_r <= PROCESSING_P;
						counter_r <= 'd383;
						start_ipr <= 'b0;
						start_ppr <= 'b1;
						if (~done_ipw) begin
							$display("[ERROR] INITILIZATION INCOMPLETE");
							if (debug) begin
								dddisplay("counter: %0d", counter_r);
								dddisplay("done_ipw: %0b", done_ipw);
							end
						end
					end
                end
                PROCESSING_P: begin
                    if (counter_r > 0) begin
                        counter_r <= counter_r - 1;
                    end else if (counter_r <= 'd1) begin
                        phase_r <= ENCRYPTION_P;
                        counter_r <= 'd767;
						start_ppr <= 'b0;
						start_epr <= 'b1;
                    end
                end
                ENCRYPTION_P: begin
                    if (counter_r > 0) begin
                        counter_r <= counter_r - 1;
                    end else if (counter_r <= 'b1) begin
                        phase_r <= FINAL_P;
                        counter_r <= 'd1535;
						start_epr <= 'b0;
						start_fpr <= 'b1;
                    end
                end
                FINAL_P: begin
                    if (counter_r > 0) begin
                        counter_r <= counter_r - 1;
                    end else if (counter_r <= 'b1) begin
						start_fpr <= 'b0;
                        ready_r <= 'b1;
                    end
                end
            endcase
        end
    end

	initialization INITIALIZATION_M(
		.clk(clk),
		.rst(rst),
		.start_ipi(start_ipr),
		.key_in(key_in),
		.iv_in(iv_in),
		.done_ipo(done_ipw),
		.mbit_out(mbit_iow),
		.state_out(state_iw)
	);

	associated_process ASSOCIATED_M(
		.clk(clk),
		.rst(rst),
		.start_ppi(start_ppr),
		.mbit_in(mbit_iow),
		.state_in(state_iw),
		.ad_in(associated_data_in),
		.mbit_out(mbit_aow),
		.state_out(state_aw)
	);

	encryption ENCRYPTION_M(
		.clk(clk),
		.rst(rst),
		.start_epi(start_epr),
		.mbit_in(mbit_aow),
		.state_in(state_aw),
		.plaintext_in(plaintext_in),
		.mbit_out(mbit_eow),
		.cipher_out(ciphertext_w)
	);

	finalization FINALIZATION_M(
		.clk(clk),
		.rst(rst),
		.start_fpi(start_fpr),
		.mbit_in(mbit_aow),
		.state_in(state_aw),
		.tag(tag)
	);

	assign ready_out = ready_r;
    assign ciphertext_out = ciphertext_w;
	assign tag_out = tag;

	task ddisplay(input string text);
		`ifdef DEBUG
			$display("[DEBUG] %s",text);
		`endif
	endtask

	task dddisplay(input string text, input reg [2000:0] val);
		`ifdef DEBUG
			$display("[DEBUG] ",$sformatf(text, val));
		`endif
	endtask

	reg debug = 1;
	initial begin
		`ifdef DEBUG
			debug = 1;
		`else
			debug = 0;
		`endif
	end

endmodule

