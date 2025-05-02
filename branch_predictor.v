`include "define.v"

module branch_predictor(
	input  clk,
	input  rst_n,
	input  PL_flush,	
	input  PL_stall,
	input  PL_stall_inner, 

	output [31:0]jalr_pc_prediction,
	output B_type_prediction_result,

	input  ras_pop, 
	input  ras_push,
	input  ras_rollback_pop, 
	input  ras_rollback_push,

	input  [31:0]pc_add_4,
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
	input  B_type_result_id, 

	input  B_type_branch_failed,
	input  beq_branch_failed,
	input  bne_branch_failed,
	input  blt_branch_failed,
	input  bge_branch_failed,
	input  bltu_branch_failed,
	input  bgeu_branch_failed,
	input  [31:0]pc_branch_filled,
	input  B_type_result_branch_failed
);

	localparam RAS_STACK_ADDR_WIDTH = 4;

	localparam GHP_INDEX_HR_WIDTH = 6;
	localparam GHP_INDEX_PC_WIDTH = 4;
	localparam LHP_INDEX_HR_WIDTH = 5;
	localparam LHP_INDEX_PC_WIDTH = 3;
	localparam STAT_COUNTER_WIDTH = 5;

	localparam JUMP_STATUS_COUNTER_WIDTH = 2;
	localparam JUMP_STATUS_COUNTER_WIDTH_UB = JUMP_STATUS_COUNTER_WIDTH - 1;
	localparam [JUMP_STATUS_COUNTER_WIDTH_UB:0]JUMP_STATUS_COUNTER_INIT_VALUE = 0;


	wire SP_prediction_result;
	wire SP_prediction_result_id;
	wire SP_prediction_result_ex;

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


	wire corrected_en, rollback_en_id, rollback_en_ex;
	assign corrected_en   = B_type && !PL_stall && !PL_stall_inner;
	assign rollback_en_id = B_type_id && PL_flush;
	assign rollback_en_ex = B_type_branch_failed && PL_flush;


	//MP
	meta_predictor #(
		.JUMP_STATUS_COUNTER_WIDTH(JUMP_STATUS_COUNTER_WIDTH),
		.STAT_COUNTER_WIDTH(STAT_COUNTER_WIDTH)
	) MP_inst(
		.clk(clk),
		.rst_n(rst_n),
		.PL_stall(PL_stall),

		.corrected_result(corrected_result),
		.jump_result_id(B_type_result_id),
		.jump_result_ex(B_type_result_branch_failed),
		
		.corrected_en(corrected_en),
		.rollback_en_id(rollback_en_id),
		.rollback_en_ex(rollback_en_ex),


		.beq(beq),
		.bne(bne),
		.blt(blt),
		.bge(bge),
		.bltu(bltu),
		.bgeu(bgeu),

		.beq_id(beq_id),  
		.bne_id(bne_id),
		.blt_id(blt_id),
		.bge_id(bge_id),
		.bltu_id(bltu_id),
		.bgeu_id(bgeu_id),

		.beq_ex(beq_branch_failed),
		.bne_ex(bne_branch_failed),
		.blt_ex(blt_branch_failed),
		.bge_ex(bge_branch_failed),
		.bltu_ex(bltu_branch_failed),
		.bgeu_ex(bgeu_branch_failed),

		.SP_prediction_result(SP_prediction_result),
		.SP_prediction_result_id(SP_prediction_result_id),
		.SP_prediction_result_ex(SP_prediction_result_ex),

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
		.LHP_bgeu_count_ex(LHP_bgeu_count_ex),
	
		.prediction_result(B_type_prediction_result)
	);


	//SP
	static_predictor SP_inst(
		.clk(clk),
		.rst_n(rst_n),
		.PL_stall(PL_stall),

		.imme_sig(imme[31]),
		.SP_prediction_result(SP_prediction_result),
		.SP_prediction_result_id(SP_prediction_result_id),
		.SP_prediction_result_ex(SP_prediction_result_ex)
	);


	//GHP
	history_predictor #(
		.JUMP_STATUS_COUNTER_WIDTH(JUMP_STATUS_COUNTER_WIDTH),
		.JUMP_STATUS_COUNTER_INIT_VALUE(JUMP_STATUS_COUNTER_INIT_VALUE),
		.INDEX_HR_WIDTH(GHP_INDEX_HR_WIDTH),
		.INDEX_PC_WIDTH(GHP_INDEX_PC_WIDTH)
	) GHP_inst(
		.clk(clk),
		.rst_n(rst_n),
		.PL_stall(PL_stall),

		.corrected_result(corrected_result),

		.corrected_en(corrected_en),
		.rollback_en_id(rollback_en_id),
		.rollback_en_ex(rollback_en_ex),

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
		.JUMP_STATUS_COUNTER_INIT_VALUE(JUMP_STATUS_COUNTER_INIT_VALUE),
		.INDEX_HR_WIDTH(LHP_INDEX_HR_WIDTH),
		.INDEX_PC_WIDTH(LHP_INDEX_PC_WIDTH)
	) LHP_beq_inst(
		.clk(clk),
		.rst_n(rst_n),
		.PL_stall(PL_stall),

		.corrected_result(corrected_result),

		.corrected_en(beq && !PL_stall && !PL_stall_inner),
		.rollback_en_id(beq_id && PL_flush),
		.rollback_en_ex(beq_branch_failed && PL_flush),

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
		.JUMP_STATUS_COUNTER_INIT_VALUE(JUMP_STATUS_COUNTER_INIT_VALUE),
		.INDEX_HR_WIDTH(LHP_INDEX_HR_WIDTH),
		.INDEX_PC_WIDTH(LHP_INDEX_PC_WIDTH)
	) LHP_bne_inst(
		.clk(clk),
		.rst_n(rst_n),
		.PL_stall(PL_stall),

		.corrected_result(corrected_result),

		.corrected_en(bne && !PL_stall && !PL_stall_inner),
		.rollback_en_id(bne_id && PL_flush),
		.rollback_en_ex(bne_branch_failed && PL_flush),

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
		.JUMP_STATUS_COUNTER_INIT_VALUE(JUMP_STATUS_COUNTER_INIT_VALUE),
		.INDEX_HR_WIDTH(LHP_INDEX_HR_WIDTH),
		.INDEX_PC_WIDTH(LHP_INDEX_PC_WIDTH)
	) LHP_blt_inst(
		.clk(clk),
		.rst_n(rst_n),
		.PL_stall(PL_stall),

		.corrected_result(corrected_result),

		.corrected_en(blt && !PL_stall && !PL_stall_inner),
		.rollback_en_id(blt_id && PL_flush),
		.rollback_en_ex(blt_branch_failed && PL_flush),

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
		.JUMP_STATUS_COUNTER_INIT_VALUE(JUMP_STATUS_COUNTER_INIT_VALUE),
		.INDEX_HR_WIDTH(LHP_INDEX_HR_WIDTH),
		.INDEX_PC_WIDTH(LHP_INDEX_PC_WIDTH)
	) LHP_bge_inst(
		.clk(clk),
		.rst_n(rst_n),
		.PL_stall(PL_stall),

		.corrected_result(corrected_result),

		.corrected_en(bge && !PL_stall && !PL_stall_inner),
		.rollback_en_id(bge_id && PL_flush),
		.rollback_en_ex(bge_branch_failed && PL_flush),

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
		.JUMP_STATUS_COUNTER_INIT_VALUE(JUMP_STATUS_COUNTER_INIT_VALUE),
		.INDEX_HR_WIDTH(LHP_INDEX_HR_WIDTH),
		.INDEX_PC_WIDTH(LHP_INDEX_PC_WIDTH)
	) LHP_bltu_inst(
		.clk(clk),
		.rst_n(rst_n),
		.PL_stall(PL_stall),

		.corrected_result(corrected_result),

		.corrected_en(bltu && !PL_stall && !PL_stall_inner),
		.rollback_en_id(bltu_id && PL_flush),
		.rollback_en_ex(bltu_branch_failed && PL_flush),

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
		.JUMP_STATUS_COUNTER_INIT_VALUE(JUMP_STATUS_COUNTER_INIT_VALUE),
		.INDEX_HR_WIDTH(LHP_INDEX_HR_WIDTH),
		.INDEX_PC_WIDTH(LHP_INDEX_PC_WIDTH)
	) LHP_bgeu_inst(
		.clk(clk),
		.rst_n(rst_n),
		.PL_stall(PL_stall),

		.corrected_result(corrected_result),

		.corrected_en(bgeu && !PL_stall && !PL_stall_inner),
		.rollback_en_id(bgeu_id && PL_flush),
		.rollback_en_ex(bgeu_branch_failed && PL_flush),

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

		.pop(ras_pop),
		.push(ras_push),
		.rollback_pop(ras_rollback_pop),	
		.rollback_push(ras_rollback_push),
		
		.pc_add_4(pc_add_4),
		.jalr_pc_prediction(jalr_pc_prediction)
	);
endmodule


module static_predictor(
	input clk,
	input rst_n,
	input PL_stall,

	input imme_sig,
	output SP_prediction_result, 
	output SP_prediction_result_id,
	output SP_prediction_result_ex
);
	reg prediciont_result_reg_id, prediciont_result_reg_ex;

	always @(posedge clk)
	begin
		if (!rst_n)
			begin
				prediciont_result_reg_id <= `zero;
				prediciont_result_reg_ex <= `zero;
			end
		else
			begin
				if(!PL_stall)
				begin
					prediciont_result_reg_id <= SP_prediction_result;
					prediciont_result_reg_ex <= prediciont_result_reg_id;
				end
			end
	end	

	assign SP_prediction_result_id = prediciont_result_reg_id;
	assign SP_prediction_result_ex = prediciont_result_reg_ex;
	assign SP_prediction_result = imme_sig;
endmodule