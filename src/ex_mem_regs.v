`include "define.v"

module ex_mem_regs(
	input clk,
	input rst_n,

	input [31:0]result_ex_mem_i,
	input [31:0]Rs2_data_ex_mem_i,
	input [4:0]Rd_ex_mem_i,

	output reg [31:0]result_ex_mem_o,   
	output reg [31:0]Rs2_data_ex_mem_o,    
	output reg [4:0]Rd_ex_mem_o,
	
	input  forward_load_ex_mem_i,
	output reg forward_load_ex_mem_o,
	
	input RegWrite_ex_mem_i,
	input MemRead_ex_mem_i,
	input MemWrite_ex_mem_i,
	input [2:0]RW_type_ex_mem_i,
	
	output reg RegWrite_ex_mem_o,
	output reg MemRead_ex_mem_o,
	output reg MemWrite_ex_mem_o,
	output reg [2:0]RW_type_ex_mem_o
    );

	always@(posedge clk)
	begin
		if(!rst_n)
            begin
    			result_ex_mem_o<=`zeroword;
    			Rs2_data_ex_mem_o<=`zeroword;
    			Rd_ex_mem_o<=`zeroreg;
    			forward_load_ex_mem_o<=`zero;
					RegWrite_ex_mem_o<=`zero;
    			MemRead_ex_mem_o<=`zero;
    			MemWrite_ex_mem_o<=`zero;
    			RW_type_ex_mem_o<=3'b000;
    		end
		else
	        begin
    			result_ex_mem_o<=result_ex_mem_i;
    			Rs2_data_ex_mem_o<=Rs2_data_ex_mem_i;
    			Rd_ex_mem_o<=Rd_ex_mem_i;
    			forward_load_ex_mem_o<=forward_load_ex_mem_i;
					RegWrite_ex_mem_o<=RegWrite_ex_mem_i;
    			MemRead_ex_mem_o<=MemRead_ex_mem_i;
    			MemWrite_ex_mem_o<=MemWrite_ex_mem_i;
    			RW_type_ex_mem_o<=RW_type_ex_mem_i;
            end
	end
endmodule