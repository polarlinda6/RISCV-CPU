module branch_judge(
	input B_type, 
	input beq,
	input bne,
	input blt,
	input bge,
	input bltu,
	input bgeu,
	input jalr,
	
	input zero,
	input slt_result,
	input [31:0]jalr_pc_new,

	input B_type_prediction_result,
	input [31:0]jalr_pc_prediciton,
	
	output PL_flush
    );

	assign PL_flush= (jalr && jalr_pc_new!=jalr_pc_prediciton) 
	                 || 
                   (B_type && (B_type_prediction_result ^ ((beq  && zero)||
																													 (bne  && (!zero))||
																													 (blt  && slt_result)||
																													 (bge  && (!slt_result))||
																													 (bltu && slt_result)||
																													 (bgeu && (!slt_result)))));
endmodule