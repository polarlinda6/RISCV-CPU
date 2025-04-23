module prediction_writer #(
  parameter JUMP_STATUS_COUNTER_WIDTH = 2,
  parameter STAT_COUNTER_WIDTH = 5
)(
  input clk,
  input rst,
  input PL_stall, 

  input prediction_en,
  input rollback_en_id,
  input rollback_en_ex,

  input prediction_result,
  input prediction_result_id,
  input prediction_result_branch_failed,

  input [2:0]addr, 
  input [2:0]addr_id, 
  input [2:0]addr_ex, 
  
  input SP_prediction_result,
  input SP_prediction_result_id,
  input SP_prediction_result_ex,

  input [JUMP_STATUS_COUNTER_WIDTH - 1:0]LHP_count,
  input [JUMP_STATUS_COUNTER_WIDTH - 1:0]LHP_count_id,
  input [JUMP_STATUS_COUNTER_WIDTH - 1:0]LHP_count_ex,

  input [JUMP_STATUS_COUNTER_WIDTH - 1:0]GHP_count,
  input [JUMP_STATUS_COUNTER_WIDTH - 1:0]GHP_count_id,
  input [JUMP_STATUS_COUNTER_WIDTH - 1:0]GHP_count_ex,

  input [STAT_COUNTER_WIDTH - 1:0]SP_stat_count,
  input [STAT_COUNTER_WIDTH - 1:0]SP_stat_count_id,
  input [STAT_COUNTER_WIDTH - 1:0]SP_stat_count_ex,

  input [STAT_COUNTER_WIDTH - 1:0]LHP_stat_count,
  input [STAT_COUNTER_WIDTH - 1:0]LHP_stat_count_id,
  input [STAT_COUNTER_WIDTH - 1:0]LHP_stat_count_ex,

  input [STAT_COUNTER_WIDTH - 1:0]GHP_stat_count,
  input [STAT_COUNTER_WIDTH - 1:0]GHP_stat_count_id,
  input [STAT_COUNTER_WIDTH - 1:0]GHP_stat_count_ex,

  input [2:0]SP_trend_count,
  input [2:0]SP_trend_count_id,
  input [2:0]SP_trend_count_ex,

  input [2:0]LHP_trend_count,
  input [2:0]LHP_trend_count_id,
  input [2:0]LHP_trend_count_ex,

  input [2:0]GHP_trend_count,
  input [2:0]GHP_trend_count_id,
  input [2:0]GHP_trend_count_ex,


  output clear_en,
  output clear_en_id,
  output clear_en_ex,

  output SP_index1,
  output SP_index2,
  output [STAT_COUNTER_WIDTH - 1:0]LHP_GHP_index1,
  output [STAT_COUNTER_WIDTH - 1:0]LHP_GHP_index2,

  output WR_SP_en1,
  output WR_SP_en2,
  output [2 + STAT_COUNTER_WIDTH:0]WR_SP_data1,
  output [2 + STAT_COUNTER_WIDTH:0]WR_SP_data2,

  output WR_LHP_en1,
  output WR_LHP_en2,
  output [2 + STAT_COUNTER_WIDTH:0]WR_LHP_data1,
  output [2 + STAT_COUNTER_WIDTH:0]WR_LHP_data2,
  
  output WR_GHP_en1,
  output WR_GHP_en2,
  output [2 + STAT_COUNTER_WIDTH:0]WR_GHP_data1,
  output [2 + STAT_COUNTER_WIDTH:0]WR_GHP_data2
);


endmodule 