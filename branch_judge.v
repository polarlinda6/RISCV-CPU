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
	input [31:0]jalr_jump_pc_actual,

	input B_type_prediction_result,
	input [31:0]jalr_jump_pc,
	
	output PL_flush
  );

	wire ne_result;
	parallel_unsig_comparator_ne #(
		.WIDTH(32)
	) jalr_pc_comparator_inst(
		.data1(jalr_jump_pc_actual),
		.data2(jalr_jump_pc),
		.compare_result(ne_result)
	);

	assign PL_flush= (jalr && ne_result) 
	                 || 
                   (B_type && (B_type_prediction_result ^ ((beq  && zero)||
																													 (bne  && (!zero))||
																													 (blt  && slt_result)||
																													 (bge  && (!slt_result))||
																													 (bltu && slt_result)||
																													 (bgeu && (!slt_result)))));
endmodule