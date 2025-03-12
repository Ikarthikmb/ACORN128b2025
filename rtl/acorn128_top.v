module acorn128_top(
    input clk,
    input rst,
    input start_in,
    input encrypt_in,
    input [127:0] key_in,
    input [127:0] iv_in,
    input [127:0] plaintext_in,
    input [127:0] ciphertext_in,
    input [127:0] associated_data_in,
    input [63:0] data_length_in,
    output [127:0] ciphertext_out,
    output [127:0] plaintext_out,
    output [127:0] tag_out,
    output ready_out
);

    wire [292:0] state_w;
    reg [127:0] keystream_r;
    reg [127:0] auth_tag_r;
    reg [7:0] phase_r;
    reg [63:0] counter_r;
	wire [1791:0] mbit_w;
	wire ca_w, cb_w;
	reg ready_r;
    wire [127:0] ciphertext_w;
    reg [127:0] plaintext_r;
    wire [127:0] tag;

    localparam INITIALIZATION_P	= 'd0;
    localparam PROCESSING_P		= 'd1;
    localparam ENCRYPTION_P		= 'd2;
    localparam FINAL_P			= 'd3;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            keystream_r 	<= 128'b0;
            auth_tag_r 		<= 128'b0;
            // ciphertext_r 	<= 128'b0;
            plaintext_r 	<= 128'b0;
            // tag 			<= 128'b0;
            phase_r 		<= INITIALIZATION_P;
            counter_r 		<= 'd1792;
            ready_r 		<= 'b0;
			// $display("Reset process complete");
        end else if (start_in) begin
            case (phase_r)
                INITIALIZATION_P: begin
					if (counter_r > 0) begin 
						counter_r <= counter_r - 1;
						// $write("%0d ", counter_r);
					end else if (counter_r <= 'd1) begin
						phase_r <= PROCESSING_P;
						counter_r <= 'd383;
						// $display("End of Initialiazation");
						// $display("Start of Porcessing");
					end
                end
                PROCESSING_P: begin
                    if (counter_r > 0) begin
                        counter_r <= counter_r - 1;
						// $write("%0d ", counter_r);
                    end else if (counter_r <= 'd1) begin
                        phase_r <= ENCRYPTION_P;
                        counter_r <= 'd767;
						// $display("Start of Encryption");
                    end
                end
                ENCRYPTION_P: begin
                    if (counter_r > 0) begin
                        counter_r <= counter_r - 1;
						// $write("%0d ", counter_r);
                    end else if (counter_r <= 'b1) begin
                        phase_r <= FINAL_P;
                        counter_r <= 'd1535;
						// $display("Start of Finalization");
                    end
                end
                FINAL_P: begin
                    if (counter_r > 0) begin
                        counter_r <= counter_r - 1;
						// $write("%0d ", counter_r);
                    end else if (counter_r <= 'b1) begin
                        ready_r <= 1;
						// $display("End of Finalization");
                    end
                end
            endcase
        end
    end

	initialization INITIALIZATION_MOD(
	.clk(clk),
	.rst(rst),
	.key_in(key_in),
	.iv_in(iv_in),
	.state_out(state_w),
	.mbit_out(mbit_w),
	.ca_out(ca_w),
	.cb_out(cb_w)
	);

	associated_process ASSOCIATED_P(
	.clk(clk),
	.rst(rst),
	.state_in(state_w),
	.mbit_out(mbit_w),
	.ca_bit(ca_w),
	.cb_bit(cb_w),
	.state_out(state_w)
	);

	encryption ENCRYPTION(
	.clk(clk),
	.rst(rst),
	.state_in(state_w),
	.ca_in(ca_w), 
	.cb_in(cb_w),
	.plaintext_in(plaintext_r),
	.ca_bito(ca_w), 
	.cb_bito(cb_w),
	.cipher_out(ciphertext_w)
	);

	finalization FINALIZATION(
	.clk(clk),
	.rst(rst),
	.state_in(state_w),
	.tag(tag)
	);

	assign ready_out = ready_r;
    assign ciphertext_out = ciphertext_w;
    assign plaintext_out = plaintext_r;
	assign tag_out = tag;

endmodule

