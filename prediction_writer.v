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

  output WR_SP_en1,
  output WR_SP_en2,   
  output WR_LHP_en1,
  output WR_LHP_en2, 
  output WR_GHP_en1,
  output WR_GHP_en2, 
  
  output SP_index1,
  output SP_index2,
  output [STAT_COUNTER_WIDTH - 1:0]LHP_GHP_index1,
  output [STAT_COUNTER_WIDTH - 1:0]LHP_GHP_index2,  

  output [2:0]WR_SP_trend_count1,
  output [2:0]WR_SP_trend_count2,
  output [2:0]WR_LHP_trend_count1,
  output [2:0]WR_LHP_trend_count2,
  output [2:0]WR_GHP_trend_count1,
  output [2:0]WR_GHP_trend_count2,

  output [STAT_COUNTER_WIDTH:0]WR_SP_stat_count1,
  output [STAT_COUNTER_WIDTH:0]WR_SP_stat_count2,
  output [STAT_COUNTER_WIDTH:0]WR_LHP_stat_count1,
  output [STAT_COUNTER_WIDTH:0]WR_LHP_stat_count2,
  output [STAT_COUNTER_WIDTH:0]WR_GHP_stat_count1,
  output [STAT_COUNTER_WIDTH:0]WR_GHP_stat_count2
);

  reg [2:0]SP_trend_count_reg_id, SP_trend_count_reg_ex;
  reg [2:0]LHP_trend_count_reg_id, LHP_trend_count_reg_ex;
  reg [2:0]GHP_trend_count_reg_id, GHP_trend_count_reg_ex;

  always @(posedge clk)
  begin
    if (!rst_n)
      begin  
        localparam ZERO = 3'b000;
        SP_trend_count_reg_id  <= ZERO;
        SP_trend_count_reg_ex  <= ZERO;
        LHP_trend_count_reg_id <= ZERO;
        LHP_trend_count_reg_ex <= ZERO;
        GHP_trend_count_reg_id <= ZERO;
        GHP_trend_count_reg_ex <= ZERO;
      end
    else
      begin
        if(!PL_stall)
        begin
          SP_trend_count_reg_id  <= SP_trend_count;
          SP_trend_count_reg_ex  <= SP_trend_count_reg_id;
          LHP_trend_count_reg_id <= LHP_trend_count;
          LHP_trend_count_reg_ex <= LHP_trend_count_reg_id;
          GHP_trend_count_reg_id <= GHP_trend_count;
          GHP_trend_count_reg_ex <= GHP_trend_count_reg_id;
        end
      end
  end

///////////////////////////////////////////////////////////////////

  wire SP_conflict, LHP_conflict, GHP_conflict;

  wire addr_conflict;
  assign addr_conflict = addr_id == addr_ex;
  assign SP_conflict   = addr_conflict && (SP_prediction_result_id == SP_prediction_result_ex);
  assign LHP_conflict  = addr_conflict && (LHP_count_id == LHP_count_ex);
  assign GHP_conflict  = addr_conflict && (GHP_count_id == GHP_count_ex);


  assign WR_SP_en1  = !SP_conflict  && rollback_en_id;
  assign WR_LHP_en1 = !LHP_conflict && rollback_en_id;
  assign WR_GHP_en1 = !GHP_conflict && rollback_en_id;

  assign WR_SP_en2  = prediction_en || rollback_en_ex;
  assign WR_LHP_en2 = prediction_en || rollback_en_ex;
  assign WR_GHP_en2 = prediction_en || rollback_en_ex;





///////////////////////////////////////////////////////////////////

  assign WR_SP_trend_count1  = SP_trend_count_reg_id;
  assign WR_LHP_trend_count1 = LHP_trend_count_reg_id;
  assign WR_GHP_trend_count1 = GHP_trend_count_reg_id;



  wire SP_add_en, SP_add_en_id, SP_add_en_ex;
  wire LHP_add_en, LHP_add_en_id, LHP_add_en_ex;
  wire GHP_add_en, GHP_add_en_id, GHP_add_en_ex;

  assign SP_add_en  = SP_prediction_result == prediction_result;
  assign LHP_add_en = LHP_count == prediction_result;
  assign GHP_add_en = GHP_count == GHP_count_id;



///////////////////////////////////////////////////////////////////

  wire [2:0]compare_result, compare_result_id, compare_result_ex;

  assign clear_en    = |compare_result;
  assign clear_en_id = |compare_result_id;
  assign clear_en_ex = |compare_result_ex;


  localparam FULL = {STAT_COUNTER_WIDTH{1'b1}};

  parallel_unsig_comparator_eq #(
    .WIDTH(STAT_COUNTER_WIDTH)
  ) SP_clear_inst(
    .data1(SP_stat_count),
    .data2(FULL),
    .compare_result(compare_result[2])
  );
  parallel_unsig_comparator_eq #(
    .WIDTH(STAT_COUNTER_WIDTH)
  ) LHP_clear_inst(
    .data1(LHP_stat_count),
    .data2(FULL),
    .compare_result(compare_result[1])
  );
  parallel_unsig_comparator_eq #(
    .WIDTH(STAT_COUNTER_WIDTH)
  ) GHP_clear_inst(
    .data1(GHP_stat_count),
    .data2(FULL),
    .compare_result(compare_result[0])
  );

  parallel_comparator #(
    .WIDTH(STAT_COUNTER_WIDTH)
  ) SP_clear_id_inst(
    .data1(SP_stat_count_id),
    .data2(FULL),
    .compare_result(compare_result_id[2])
  );
  parallel_comparator #(
    .WIDTH(STAT_COUNTER_WIDTH)
  ) LHP_clear_id_inst(
    .data1(LHP_stat_count_id),
    .data2(FULL),
    .compare_result(compare_result_id[1])
  );
  parallel_comparator #(
    .WIDTH(STAT_COUNTER_WIDTH)
  ) GHP_clear_id_inst(
    .data1(GHP_stat_count_id),
    .data2(FULL),
    .compare_result(compare_result_id[0])
  );

  parallel_comparator #(
    .WIDTH(STAT_COUNTER_WIDTH)
  ) SP_clear_ex_inst(
    .data1(SP_stat_count_ex),
    .data2(FULL),
    .compare_result(compare_result_ex[2])
  );
  parallel_comparator #(
    .WIDTH(STAT_COUNTER_WIDTH)
  ) LHP_clear_ex_inst(
    .data1(LHP_stat_count_ex),
    .data2(FULL),
    .compare_result(compare_result_ex[1])
  );
  parallel_comparator #(
    .WIDTH(STAT_COUNTER_WIDTH)
  ) GHP_clear_ex_inst(
    .data1(GHP_stat_count_ex),
    .data2(FULL),
    .compare_result(compare_result_ex[0])
  );
endmodule 