module mem_stage(
	input [31:0]Rs2_data_mem_i,
	input [31:0]load_data_mem_wb_o,
	input forward_load_mem_i,
	output [31:0]store_data,
	
	input  [31:0]result_mem_i,
	input  [31:0]load_data_mem_i,
	input  MemRead_mem_i,
	output [31:0]load_or_result_mem_o
    );

	mux mem_mux (
        .din1(load_data_mem_wb_o), 
        .din2(Rs2_data_mem_i), 
        .signal(forward_load_mem_i), 
        .dout(store_data)
        );
        
   	mux wb_data_mux (
        .din1(load_data_mem_i), 
        .din2(result_mem_i), 
        .signal(MemRead_mem_i), 
        .dout(load_or_result_mem_o)
        );     
endmodule