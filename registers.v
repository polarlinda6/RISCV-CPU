`include "define.v"

module registers(
	input  clk,
	input  rst_n,
	
	input  [4:0]Rs1,
	input  [4:0]Rs2,
	input  [4:0]Rd,
	input  RegWrite,
	input  [31:0]Wr_data,
	
	output [31:0]Rs1_data,
	output [31:0]Rs2_data,

	input  [4:0]prediction_Rs1,
	input  [4:0]prediction_Rs2,
	output [31:0]prediction_Rs1_data,
	output [31:0]prediction_Rs2_data
    );
	
	reg [31:0]regs[31:1]; //x0 is a dedicated zero register.
	                      //Not implemented to save resources.

	always@(negedge clk)
	begin
		if(!rst_n)
		begin
			regs[2]  <= 32'h7ffffff0;  //sp
			regs[3]  <= 32'h10000000;  //gp
		end
		else if(RegWrite) 
			regs[Rd] <= Wr_data;
	end

	assign Rs1_data=(Rs1==`zeroreg) ? `zeroword : regs[Rs1];
	assign Rs2_data=(Rs2==`zeroreg) ? `zeroword : regs[Rs2];
	assign prediction_Rs1_data=(prediction_Rs1==`zeroreg) ? `zeroword : regs[prediction_Rs1];
	assign prediction_Rs2_data=(prediction_Rs2==`zeroreg) ? `zeroword : regs[prediction_Rs2];
endmodule