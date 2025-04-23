module forward_unit(
	input [4:0]Rs1_id_ex_o,
	input [4:0]Rs2_id_ex_o,
	input [4:0]Rd_ex_mem_o,
	input [4:0]Rd_mem_wb_o,

	input RegWrite_ex_mem_o,
	input RegWrite_mem_wb_o,

	output [1:0]forwardA,
	output [1:0]forwardB,

	
	input [4:0]Rs1_id_ex_i,
	input [4:0]Rs2_id_ex_i,
	input [4:0]Rd_id_ex_o,
	
	input RegWrite_id_ex_o,
	input MemRead_id_ex_o,
	input MemRead_ex_mem_o,
		
	input MemWrite_id_o,
	input MemWrite_id_ex_o,

	output forward_load,
	output PL_stall
    );
	
	assign forwardA[1]= RegWrite_ex_mem_o && (Rd_ex_mem_o==Rs1_id_ex_o);
	assign forwardA[0]= RegWrite_mem_wb_o && (Rd_mem_wb_o==Rs1_id_ex_o);
	
	assign forwardB[1]= RegWrite_ex_mem_o && (Rd_ex_mem_o==Rs2_id_ex_o);
	assign forwardB[0]= RegWrite_mem_wb_o && (Rd_mem_wb_o==Rs2_id_ex_o);
	
	
	//store after load
	assign forward_load= MemRead_ex_mem_o && RegWrite_ex_mem_o &&
	                     MemWrite_id_ex_o && (Rd_ex_mem_o!=Rs1_id_ex_o) && (Rd_ex_mem_o==Rs2_id_ex_o);
	
	
	//use after load
	assign PL_stall= MemRead_id_ex_o && RegWrite_id_ex_o &&
                   ((!MemWrite_id_o && ((Rd_id_ex_o==Rs1_id_ex_i) || (Rd_id_ex_o==Rs2_id_ex_i))) || 
                   (MemWrite_id_o && (Rd_id_ex_o==Rs1_id_ex_i)));
endmodule