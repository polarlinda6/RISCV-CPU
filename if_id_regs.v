`include "define.v"

module if_id_regs(
	input clk,
	input rst_n,

	input [31:0]pc_add_imme_if_id_i,
	output reg [31:0]pc_add_imme_if_id_o,

	input [31:0]pc_add_4_if_id_i,
	output reg [31:0]pc_add_4_if_id_o,

	input [31:0]jalr_pc_jump_or_pc_if_id_i,
	output reg [31:0]jalr_pc_jump_or_pc_if_id_o,

	input B_type_prediction_result_if_id_i, 
	output reg B_type_prediction_result_if_id_o,

	input [31:0]instr_if_id_i,
	output reg [31:0]instr_if_id_o,
	
	
	input PL_stall,
	input PL_flush
    );
	
	always@(posedge clk)
	begin
		if(!rst_n || PL_flush)				
		    begin
						pc_add_imme_if_id_o<=`zeroword;
						pc_add_4_if_id_o<=`zeroword;
						jalr_pc_jump_or_pc_if_id_o<=`zeroword;
						B_type_prediction_result_if_id_o<=`zero;
						instr_if_id_o<=`nop;
				end
		else if(!PL_stall)
				begin
						pc_add_imme_if_id_o<=pc_add_imme_if_id_i;
						pc_add_4_if_id_o<=pc_add_4_if_id_i;
						jalr_pc_jump_or_pc_if_id_o<=jalr_pc_jump_or_pc_if_id_i;
						B_type_prediction_result_if_id_o<=B_type_prediction_result_if_id_i;
						instr_if_id_o<=instr_if_id_i;
				end
	end
endmodule