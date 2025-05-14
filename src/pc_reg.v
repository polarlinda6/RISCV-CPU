`include "define.v"

module pc_reg(
	input clk,
	input rst_n,

	input PL_stall_ex,	
	input [31:0]pc_new,
	output reg [31:0]pc_out
  );

	
	always@(posedge clk)
	begin
		if(!rst_n)
			pc_out <= `zeroword;
		else if(!PL_stall_ex)
			pc_out <= pc_new;
	end	
endmodule


