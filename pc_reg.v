`include "define.v"

module pc_reg(
	input clk,
	input rst_n,

	input WR_en,	
	input [31:0]pc_new,
	output reg [31:0]pc_out
  );

	
	always@(posedge clk)
	begin
		if(!rst_n)
			pc_out <= `zeroword;
		else if(WR_en)
			pc_out <= pc_new;
	end	
endmodule


