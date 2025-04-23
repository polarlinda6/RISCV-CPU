module id_stage(
	input clk,
	input rst_n,
	input [31:0]instr_id_i,
	
	input [4:0]Rd_id_i,
    input RegWrite_id_i,
	input [31:0]Wr_reg_data_id_i,	
	
	input  [4:0]prediction_Rs1_id_i,
    input  [4:0]prediction_Rs2_id_i,
	output [31:0]prediction_Rs1_data_id_o,
    output [31:0]prediction_Rs2_data_id_o,

	output [31:0]imme_id_o,
	output [31:0]Rs1_data_id_o,
	output [31:0]Rs2_data_id_o,
	output [4:0]Rd_id_o,
	output [4:0]Rs1_id_o,
	output [4:0]Rs2_id_o,

	output [6:0]opcode_id_o,
	output [2:0]func3_id_o,
	output func7_id_o
    );
	
	instr_decode instr_decode_inst (
        .instr(instr_id_i), 
        .opcode(opcode_id_o), 
        .func3(func3_id_o), 
        .func7(func7_id_o), 
        .Rs1(Rs1_id_o), 
        .Rs2(Rs2_id_o), 
        .Rd(Rd_id_o), 
        .imme(imme_id_o)
        );
	
    registers registers_inst (
        .clk(clk), 
        .rst_n(rst_n), 

        .Rs1(Rs1_id_o), 
        .Rs2(Rs2_id_o), 
        
        .Rd(Rd_id_i), 
        .RegWrite(RegWrite_id_i),
        .Wr_data(Wr_reg_data_id_i), 
        
        .Rs1_data(Rs1_data_id_o), 
        .Rs2_data(Rs2_data_id_o),
        
        .prediction_Rs1(prediction_Rs1_id_i),
        .prediction_Rs2(prediction_Rs2_id_i),
	    .prediction_Rs1_data(prediction_Rs1_data_id_o),
        .prediction_Rs2_data(prediction_Rs2_data_id_o)
        );
endmodule