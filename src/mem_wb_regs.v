`include "define.v"

module mem_wb_regs(
	input clk,
	input rst_n,
	
	input [31:0]load_or_result_mem_wb_i, 	
	input RegWrite_mem_wb_i,
	input [4:0]Rd_mem_wb_i,		
	
	output reg [31:0]load_or_result_mem_wb_o,   
	output reg RegWrite_mem_wb_o,
	output reg [4:0]Rd_mem_wb_o
    );
	
	always@(posedge clk)
	begin
		if(!rst_n)
            begin
                load_or_result_mem_wb_o<=`zeroword;
				RegWrite_mem_wb_o<=`zero;
                Rd_mem_wb_o<=`zeroreg;
            end
		else
            begin
                load_or_result_mem_wb_o<=load_or_result_mem_wb_i;
			    RegWrite_mem_wb_o<=RegWrite_mem_wb_i;
                Rd_mem_wb_o<=Rd_mem_wb_i;
            end
	end
endmodule