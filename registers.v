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
//			regs[1]  <= `zeroword;
			regs[2]  <= 32'h7ffffff0;  //sp
			regs[3]  <= 32'h10000000;  //gp
//			regs[4]  <= `zeroword;
//			regs[5]  <= `zeroword;
//			regs[6]  <= `zeroword;
//			regs[7]  <= `zeroword;
//			regs[8]  <= `zeroword;
//			regs[9]  <= `zeroword;
//			regs[10] <= `zeroword;
//			regs[11] <= `zeroword;
//			regs[12] <= `zeroword;
//			regs[13] <= `zeroword;
//			regs[14] <= `zeroword;
//			regs[15] <= `zeroword;
//			regs[16] <= `zeroword;
//			regs[17] <= `zeroword;
//			regs[18] <= `zeroword;
//			regs[19] <= `zeroword;
//			regs[20] <= `zeroword;
//			regs[21] <= `zeroword;
//			regs[22] <= `zeroword;
//			regs[23] <= `zeroword;
//			regs[24] <= `zeroword;
//			regs[25] <= `zeroword;
//			regs[26] <= `zeroword;
//			regs[27] <= `zeroword;
//			regs[28] <= `zeroword;
//			regs[29] <= `zeroword;
//			regs[30] <= `zeroword;
//			regs[31] <= `zeroword;
		end
		else if(RegWrite) 
			regs[Rd] <= Wr_data;
	end

	assign Rs1_data=(Rs1==`zeroreg) ? `zeroword : regs[Rs1];
	assign Rs2_data=(Rs2==`zeroreg) ? `zeroword : regs[Rs2];
	assign prediction_Rs1_data=(prediction_Rs1==`zeroreg) ? `zeroword : regs[prediction_Rs1];
	assign prediction_Rs2_data=(prediction_Rs2==`zeroreg) ? `zeroword : regs[prediction_Rs2];
endmodule