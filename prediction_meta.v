module meta_predictor #(
  parameter JUMP_STATUS_COUNTER_WIDTH = 2,
  parameter STAT_COUNTER_WIDTH = 5,
  parameter TREND_COUNTER_WIDTH = 3,
  parameter STAT_COUNTER_CLEAR_SHIFT_BITS = STAT_COUNTER_WIDTH / 2,
  parameter SP_STAT_COUNTER_INIT_VALUE = 1 << STAT_COUNTER_CLEAR_SHIFT_BITS
)(
  input  clk,
  input  rst_n,

  output prediction_result,
  input  prediction_result_id, 
  input  prediction_result_branch_failed,
  
  input  prediction_en,
  input  beq,
  input  bne,
  input  blt,
  input  bge,
  input  bltu,
  input  bgeu,

  input  rollback_en_id, 
  input  beq_id, 
  input  bne_id,
  input  blt_id,
  input  bge_id,
  input  bltu_id,
  input  bgeu_id,

  input  rollback_en_ex,
  input  beq_ex, 
  input  bne_ex,
  input  blt_ex,
  input  bge_ex,
  input  bltu_ex,
  input  bgeu_ex,


  input  SP_prediction_result,
  
  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]GHP_count,
  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]GHP_count_id,
  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]GHP_count_ex,

  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]LHP_beq_count,
  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]LHP_bne_count,
  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]LHP_blt_count,
  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]LHP_bge_count,
  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]LHP_bltu_count,
  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]LHP_bgeu_count,

  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]LHP_beq_count_id,
  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]LHP_bne_count_id,
  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]LHP_blt_count_id,
  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]LHP_bge_count_id,
  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]LHP_bltu_count_id,
  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]LHP_bgeu_count_id,

  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]LHP_beq_count_ex,
  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]LHP_bne_count_ex,
  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]LHP_blt_count_ex,
  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]LHP_bge_count_ex,
  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]LHP_bltu_count_ex,
  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]LHP_bgeu_count_ex
);
  
  localparam JUMP_STATUS_COUNTER_WIDTH_UB = JUMP_STATUS_COUNTER_WIDTH - 1;

  localparam STAT_COUNTER_WIDTH_UB = STAT_COUNTER_WIDTH - 1;




  localparam JUMP_STATUS_COUNTER_CAPACITY = 1 << JUMP_STATUS_COUNTER_WIDTH;
  localparam JUMP_STATUS_COUNTER_CAPACITY_UB = JUMP_STATUS_COUNTER_CAPACITY - 1;

  reg [STAT_COUNTER_WIDTH_UB:0]SP_stat_counter_regs [5:0][1:0];
  reg [STAT_COUNTER_WIDTH_UB:0]GHP_stat_counter_regs[5:0][JUMP_STATUS_COUNTER_CAPACITY_UB:0];
  reg [STAT_COUNTER_WIDTH_UB:0]LHP_stat_counter_regs[5:0][JUMP_STATUS_COUNTER_CAPACITY_UB:0];


  wire [2:0]addr, addr_id, addr_ex;
  wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]LHP_count, LHP_count_id, LHP_count_ex;

/////////////////////////////////////////////////////////////////////////////////





/////////////////////////////////////////////////////////////////////////////////

  prediction_arbiter #(
    .STAT_COUNTER_WIDTH(STAT_COUNTER_WIDTH),
    .TREND_COUNTER_WIDTH(TREND_COUNTER_WIDTH)
  ) prediction_arbiter_inst (
    .SP_prediction_result(SP_prediction_result),
    .LHP_prediction_result(LHP_count[JUMP_STATUS_COUNTER_WIDTH_UB]),
    .GHP_prediction_result(GHP_count[JUMP_STATUS_COUNTER_WIDTH_UB]),

    .SP_stat_count(SP_stat_count),
    .LHP_stat_count(LHP_stat_count),
    .GHP_stat_count(GHP_stat_count),

    .SP_trend_count(SP_trend_count),
    .LHP_trend_count(LHP_trend_count),
    .GHP_trend_count(GHP_trend_count),

    .prediction_result(prediction_result)
  );

//////////////////////////////////////////////////////////////////////////////////

  localparam ADDR_WIDTH = 3;
  localparam ADDR_WIDTH_UB = ADDR_WIDTH - 1;

  localparam [ADDR_WIDTH_UB:0]BEQ_ADDR  = 3'd5;
  localparam [ADDR_WIDTH_UB:0]BNE_ADDR  = 3'd4;
  localparam [ADDR_WIDTH_UB:0]BLT_ADDR  = 3'd3;
  localparam [ADDR_WIDTH_UB:0]BGE_ADDR  = 3'd2;
  localparam [ADDR_WIDTH_UB:0]BLTU_ADDR = 3'd1;
  localparam [ADDR_WIDTH_UB:0]BGEU_ADDR = 3'd0;

  parallel_mux #(
    .WIDTH(ADDR_WIDTH),
    .MUX_QUANTITY(6)
  ) addr_inst(
    .data({BEQ_ADDR, BNE_ADDR, BLT_ADDR, BGE_ADDR, BLTU_ADDR, BGEU_ADDR}),
    .signal({beq, bne, blt, bge, bltu, bgeu}),
    .dout(addr)
  );
  parallel_mux #(
    .WIDTH(3),
    .MUX_QUANTITY(6)
  ) addr_id_inst(
    .data({BEQ_ADDR, BNE_ADDR, BLT_ADDR, BGE_ADDR, BLTU_ADDR, BGEU_ADDR}),
    .signal({beq_id, bne_id, blt_id, bge_id, bltu_id, bgeu_id}),
    .dout(addr_id)
  );  
  parallel_mux #(
    .WIDTH(3),
    .MUX_QUANTITY(6)
  ) addr_ex_inst(
    .data({BEQ_ADDR, BNE_ADDR, BLT_ADDR, BGE_ADDR, BLTU_ADDR, BGEU_ADDR}),
    .signal({beq_ex, bne_ex, blt_ex, bge_ex, bltu_ex, bgeu_ex}),
    .dout(addr_ex)
  );


  parallel_mux #(
    .WIDTH(JUMP_STATUS_COUNTER_WIDTH),
    .MUX_QUANTITY(6)
  ) count_inst(
    .data({LHP_beq_count, LHP_bne_count, LHP_blt_count, LHP_bge_count, LHP_bltu_count, LHP_bgeu_count}),
    .signal({beq, bne, blt, bge, bltu, bgeu}),
    .dout(LHP_count)
  );
  parallel_mux #(
    .WIDTH(JUMP_STATUS_COUNTER_WIDTH),
    .MUX_QUANTITY(6)
  ) count_id_inst(
    .data({LHP_beq_count_id, LHP_bne_count_id, LHP_blt_count_id, LHP_bge_count_id, LHP_bltu_count_id, LHP_bgeu_count_id}),
    .signal({beq_id, bne_id, blt_id, bge_id, bltu_id, bgeu_id}),
    .dout(LHP_count_id)
  );
  parallel_mux #(
    .WIDTH(JUMP_STATUS_COUNTER_WIDTH),
    .MUX_QUANTITY(6)
  ) count_ex_inst(
    .data({LHP_beq_count_ex, LHP_bne_count_ex, LHP_blt_count_ex, LHP_bge_count_ex, LHP_bltu_count_ex, LHP_bgeu_count_ex}),
    .signal({beq_ex, bne_ex, blt_ex, bge_ex, bltu_ex, bgeu_ex}),
    .dout(LHP_count_ex)
  );
endmodule