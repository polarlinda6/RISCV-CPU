`include "define.v"

module branch_predictor(
	input  clk,
	input  rst_n,
	input  PL_stall,
	input  PL_flush,	
	input  jalr_prediction_en,
	input  B_type_prediction_en,

	output [31:0]jalr_pc_prediction,
	output B_type_prediction_result,

	//jalr
	input  jal,
	input  jalr,
	input  [4:0]Rd,
	input  [31:0]pc_add_4,
	
	input  jal_id,
	input  jalr_id,
	input  [4:0]Rd_id,	
	input  [4:0]Rs1_id,

	//B_type
	input  [31:0]imme,

	input  B_type, 
	input  beq,
	input  bne,
	input  blt,
	input  bge,
	input  bltu,
	input  bgeu,
	input  [31:0]pc,
	input  corrected_result,

	input  B_type_id,
	input  beq_id,
	input  bne_id,
	input  blt_id,
	input  bge_id,
	input  bltu_id,
	input  bgeu_id,
	input  [31:0]pc_id,
	input  B_type_prediction_result_id, 

	input  B_type_branch_failed,
	input  beq_branch_failed,
	input  bne_branch_failed,
	input  blt_branch_failed,
	input  bge_branch_failed,
	input  bltu_branch_failed,
	input  bgeu_branch_failed,
	input  [31:0]pc_branch_filled,
	input  B_type_prediction_result_branch_failed
);

	localparam RAS_STACK_ADDR_WIDTH = 4;

	localparam GHP_INDEX_HR_WIDTH = 6;
	localparam GHP_INDEX_PC_WIDTH = 4;
	localparam LHP_INDEX_HR_WIDTH = 5;
	localparam LHP_INDEX_PC_WIDTH = 3;
	localparam STAT_COUNTER_WIDTH = 4;

	localparam JUMP_STATUS_COUNTER_WIDTH = 2;
	localparam JUMP_STATUS_COUNTER_WIDTH_UB = JUMP_STATUS_COUNTER_WIDTH - 1;


	wire SP_prediction_result;

	wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]GHP_count;
	wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]GHP_count_id;
	wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]GHP_count_ex;

	wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]LHP_beq_count;
	wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]LHP_bne_count;
	wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]LHP_blt_count;
	wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]LHP_bge_count;
	wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]LHP_bltu_count;
	wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]LHP_bgeu_count;

	wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]LHP_beq_count_id;
	wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]LHP_bne_count_id;
	wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]LHP_blt_count_id;
	wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]LHP_bge_count_id;
	wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]LHP_bltu_count_id;
	wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]LHP_bgeu_count_id;

	wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]LHP_beq_count_ex;
	wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]LHP_bne_count_ex;
	wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]LHP_blt_count_ex;
	wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]LHP_bge_count_ex;
	wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]LHP_bltu_count_ex;
	wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]LHP_bgeu_count_ex;


	wire B_type_rollback_en_id;	
	wire B_type_rollback_en_ex;	
	assign B_type_rollback_en_id = PL_flush && B_type_id;
	assign B_type_rollback_en_ex = PL_flush && B_type_branch_failed;


	//MP
	meta_predictor #(
		.JUMP_STATUS_COUNTER_WIDTH(JUMP_STATUS_COUNTER_WIDTH),
		.STAT_COUNTER_WIDTH(STAT_COUNTER_WIDTH)
	) MP_inst(
		.clk(clk),
		.rst_n(rst_n),

		.prediction_result(B_type_prediction_result),
		.prediction_result_id(B_type_prediction_result_id), 
		.prediction_result_branch_failed(B_type_prediction_result_branch_failed),

		.prediction_en(B_type_prediction_en),
		.beq(beq),
		.bne(bne),
		.blt(blt),
		.bge(bge),
		.bltu(bltu),
		.bgeu(bgeu),

		.rollback_en_id(B_type_rollback_en_id),
		.beq_id(beq_id),  
		.bne_id(bne_id),
		.blt_id(blt_id),
		.bge_id(bge_id),
		.bltu_id(bltu_id),
		.bgeu_id(bgeu_id),

		.rollback_en_ex(B_type_rollback_en_ex),
		.beq_ex(beq_ex),
		.bne_ex(bne_ex),
		.blt_ex(blt_ex),
		.bge_ex(bge_ex),
		.bltu_ex(bltu_ex),
		.bgeu_ex(bgeu_ex),


		.SP_prediction_result(SP_prediction_result),

		.GHP_count(GHP_count),
		.GHP_count_id(GHP_count_id),
		.GHP_count_ex(GHP_count_ex),

		.LHP_beq_count(LHP_beq_count),
		.LHP_bne_count(LHP_bne_count),
		.LHP_blt_count(LHP_blt_count),
		.LHP_bge_count(LHP_bge_count),
		.LHP_bltu_count(LHP_bltu_count),
		.LHP_bgeu_count(LHP_bgeu_count),

		.LHP_beq_count_id(LHP_beq_count_id),
		.LHP_bne_count_id(LHP_bne_count_id),
		.LHP_blt_count_id(LHP_blt_count_id),
		.LHP_bge_count_id(LHP_bge_count_id),
		.LHP_bltu_count_id(LHP_bltu_count_id),
		.LHP_bgeu_count_id(LHP_bgeu_count_id),

		.LHP_beq_count_ex(LHP_beq_count_ex),
		.LHP_bne_count_ex(LHP_bne_count_ex),
		.LHP_blt_count_ex(LHP_blt_count_ex),
		.LHP_bge_count_ex(LHP_bge_count_ex),
		.LHP_bltu_count_ex(LHP_bltu_count_ex),
		.LHP_bgeu_count_ex(LHP_bgeu_count_ex)
	);



	//SP
	static_predictor SP_inst(
		.imme_sig(imme[31]),
		.SP_prediction(SP_prediction_result)
	);


	//GHP
	history_predictor #(
		.JUMP_STATUS_COUNTER_WIDTH(JUMP_STATUS_COUNTER_WIDTH),
		.INDEX_HR_WIDTH(GHP_INDEX_HR_WIDTH),
		.INDEX_PC_WIDTH(GHP_INDEX_PC_WIDTH)
	) GHP_inst(
		.clk(clk),
		.rst_n(rst_n),
		.PL_stall(PL_stall),

		.corrected_result(corrected_result),
		.prediction_result_branch_failed(B_type_prediction_result_branch_failed),

		.corrected_en(B_type),
		.rollback_en_id(B_type_rollback_en_id),
		.rollback_en_ex(B_type_rollback_en_ex),

		.pc(pc),
		.pc_id(pc_id),
		.pc_ex(pc_branch_filled),

		.HP_count(GHP_count),
		.HP_count_id(GHP_count_id),
		.HP_count_ex(GHP_count_ex)
	);


	//LHP beq
	history_predictor #(
		.JUMP_STATUS_COUNTER_WIDTH(JUMP_STATUS_COUNTER_WIDTH),
		.INDEX_HR_WIDTH(LHP_INDEX_HR_WIDTH),
		.INDEX_PC_WIDTH(LHP_INDEX_PC_WIDTH)
	) LHP_beq_inst(
		.clk(clk),
		.rst_n(rst_n),
		.PL_stall(PL_stall),

		.corrected_result(corrected_result),
		.prediction_result_branch_failed(B_type_prediction_result_branch_failed),

		.corrected_en(beq),
		.rollback_en_id(PL_flush && beq_id),
		.rollback_en_ex(PL_flush && beq_ex),

		.pc(pc),
		.pc_id(pc_id),
		.pc_ex(pc_branch_filled),

		.HP_count(LHP_beq_count),
		.HP_count_id(LHP_beq_count_id),
		.HP_count_ex(LHP_beq_count_ex)
	);
	

	//LHP bne
	history_predictor #(
		.JUMP_STATUS_COUNTER_WIDTH(JUMP_STATUS_COUNTER_WIDTH),
		.INDEX_HR_WIDTH(LHP_INDEX_HR_WIDTH),
		.INDEX_PC_WIDTH(LHP_INDEX_PC_WIDTH)
	) LHP_bne_inst(
		.clk(clk),
		.rst_n(rst_n),
		.PL_stall(PL_stall),

		.corrected_result(corrected_result),
		.prediction_result_branch_failed(B_type_prediction_result_branch_failed),

		.corrected_en(bne),
		.rollback_en_id(PL_flush && bne_id),
		.rollback_en_ex(PL_flush && bne_ex),

		.pc(pc),
		.pc_id(pc_id),
		.pc_ex(pc_branch_filled),

		.HP_count(LHP_bne_count),
		.HP_count_id(LHP_bne_count_id),
		.HP_count_ex(LHP_bne_count_ex)
	);
	

	//LHP blt
	history_predictor #(
		.JUMP_STATUS_COUNTER_WIDTH(JUMP_STATUS_COUNTER_WIDTH),
		.INDEX_HR_WIDTH(LHP_INDEX_HR_WIDTH),
		.INDEX_PC_WIDTH(LHP_INDEX_PC_WIDTH)
	) LHP_blt_inst(
		.clk(clk),
		.rst_n(rst_n),
		.PL_stall(PL_stall),

		.corrected_result(corrected_result),
		.prediction_result_branch_failed(B_type_prediction_result_branch_failed),

		.corrected_en(blt),
		.rollback_en_id(PL_flush && blt_id),
		.rollback_en_ex(PL_flush && blt_ex),

		.pc(pc),
		.pc_id(pc_id),
		.pc_ex(pc_branch_filled),

		.HP_count(LHP_blt_count),
		.HP_count_id(LHP_blt_count_id),
		.HP_count_ex(LHP_blt_count_ex)
	);
	

	//LHP bge
	history_predictor #(
		.JUMP_STATUS_COUNTER_WIDTH(JUMP_STATUS_COUNTER_WIDTH),
		.INDEX_HR_WIDTH(LHP_INDEX_HR_WIDTH),
		.INDEX_PC_WIDTH(LHP_INDEX_PC_WIDTH)
	) LHP_bge_inst(
		.clk(clk),
		.rst_n(rst_n),
		.PL_stall(PL_stall),

		.corrected_result(corrected_result),
		.prediction_result_branch_failed(B_type_prediction_result_branch_failed),

		.corrected_en(bge),
		.rollback_en_id(PL_flush && bge_id),
		.rollback_en_ex(PL_flush && bge_ex),

		.pc(pc),
		.pc_id(pc_id),
		.pc_ex(pc_branch_filled),

		.HP_count(LHP_bge_count),
		.HP_count_id(LHP_bge_count_id),
		.HP_count_ex(LHP_bge_count_ex)
	);
	
	
	//LHP bltu
	history_predictor #(
		.JUMP_STATUS_COUNTER_WIDTH(JUMP_STATUS_COUNTER_WIDTH),
		.INDEX_HR_WIDTH(LHP_INDEX_HR_WIDTH),
		.INDEX_PC_WIDTH(LHP_INDEX_PC_WIDTH)
	) LHP_bltu_inst(
		.clk(clk),
		.rst_n(rst_n),
		.PL_stall(PL_stall),

		.corrected_result(corrected_result),
		.prediction_result_branch_failed(B_type_prediction_result_branch_failed),

		.corrected_en(bltu),
		.rollback_en_id(PL_flush && bltu_id),
		.rollback_en_ex(PL_flush && bltu_ex),

		.pc(pc),
		.pc_id(pc_id),
		.pc_ex(pc_branch_filled),

		.HP_count(LHP_bltu_count),
		.HP_count_id(LHP_bltu_count_id),
		.HP_count_ex(LHP_bltu_count_ex)
	);


	//LHP bgeu
	history_predictor #(
		.JUMP_STATUS_COUNTER_WIDTH(JUMP_STATUS_COUNTER_WIDTH),
		.INDEX_HR_WIDTH(LHP_INDEX_HR_WIDTH),
		.INDEX_PC_WIDTH(LHP_INDEX_PC_WIDTH)
	) LHP_bgeu_inst(
		.clk(clk),
		.rst_n(rst_n),
		.PL_stall(PL_stall),

		.corrected_result(corrected_result),
		.prediction_result_branch_failed(B_type_prediction_result_branch_failed),

		.corrected_en(bgeu),
		.rollback_en_id(PL_flush && bgeu_id),
		.rollback_en_ex(PL_flush && bgeu_ex),

		.pc(pc),
		.pc_id(pc_id),
		.pc_ex(pc_branch_filled),

		.HP_count(LHP_bgeu_count),
		.HP_count_id(LHP_bgeu_count_id),
		.HP_count_ex(LHP_bgeu_count_ex)
	);


/////////////////////////////////////////////////////////////////////////////////

	ras #(
		.STACK_ADDR_WIDTH(RAS_STACK_ADDR_WIDTH)
	) ras_inst(
		.clk(clk),
		.rst_n(rst_n),
		.PL_flush(PL_flush),
		.prediction_en(jalr_prediction_en),
		.jal(jal),
		.jalr(jalr),
		.Rd_is_ra(Rd == `ra),
		.pc_add_4(pc_add_4),
		.jal_id(jal_id),
		.jalr_id(jalr_id),
		.Rd_is_ra_id(Rd_id == `ra),
		.Rs1_is_ra_id(Rs1_id == `ra),
		.jalr_pc_prediction(jalr_pc_prediction)
	);
endmodule


module static_predictor(
	input imme_sig,
	output SP_prediction
);

	assign SP_prediction = imme_sig;
endmodule