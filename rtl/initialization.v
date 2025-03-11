// INITIALIZATION PHASE
// Initialization consists loading the key and IV into the state, and running the cipher for 1729 steps.

module initialization(		// TODO rewrite initialization
	input clk,
	input rst,
	input [127:0] key_in,
	input [127:0] iv,
	output [292:0] state_out,
	output [1791:0] mbit_out,
	output [127:0] ca_out,
	output [127:0] cb_out
);
	integer i;
	reg [1791:0] mbit_reg, ca_reg, cb_reg; 
	ret [292:0] state_r, state_ur;

	parameter MSTEP0 = 'b000,
			  MSTEP1 = 'b001,
			  MSTEP2 = 'b010,
			  MSTEP3 = 'b011,
			  MSTEP4 = 'b100;

	always @(posedge clk or negedge rst) begin
		// One data bit
		case(MSTEP)
			MSTEP0: begin
				icount <= 'd1792;
				state_r <= 'b0;
			end 
			MSTEP1: begin
				mbit_reg[icount] <= key_in[jcount];
				jcount <= jcount + 1'b1;
			end 
			MSTEP2: begin
				mbit_reg[icount] <= iv[jcount];
				jcount <= jcount + 1'b1;
			end
			MSTEP3: begin
				mbit_reg[icount] <= key_in[0] ^ 'b1;
			end
			MSTEP4: begin
				kjcount <= jcount % 'd128;
				mbit_reg[icount] <= key_in[kjcount];
			end
		endcase

		// control bits
		ca_reg <= {1791{1'b1}};
		cb_reg <= {1791{1'b1}};
	end

	always @(posedge clk or negedge rst) begin
		if (rst) begin
			MSTEP <= 'b0;
			icount <= 'd1792;
			jcount <= 'b0;
			kjcount <= 'b0;
			MSTEP <= MSTEP1;
		end else if (icount == 'd1665) begin
			icount <= icount - 1'b1;
			jcount <= 'b0;
			phase <= MSTEP2;
		end else if (icount == 'd1538) begin
			icount <= icount - 1'b1;
			jcount <= 'b0;
			phase <= MSTEP3;
		end else if (icount == 'd1537) begin
			icount <= icount - 1'b1;
			jcount <= 'b1;
			phase <= MSTEP4;
		end else begin
			icount <= icount - 1'b1;
		end
	end 

	state_update128 STATEUPDATE128(
		.clk(clk), .rst(rst),
		.ca_in(ca_reg), .cb_in(cb_reg),
		.state_io(state_r),
		.mbit_in(mbit_reg),
		.sup128_out(state_ur) 		// TODO
	);

	assign state_out 	= state_r;
	assign mbit_out 	= mbit_reg;
	assign ca_out 	= ca_reg;
	assign cb_out 	= cb_reg;

endmodule
