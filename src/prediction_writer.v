`include "define.v"

module prediction_writer #(
  parameter JUMP_STATUS_COUNTER_WIDTH = 2,
  parameter STAT_COUNTER_WIDTH = 5
)(
  input  clk,
  input  rst_n,
  input  PL_stall, 

  input  corrected_result,
  input  jump_result_id,
  input  jump_result_ex,

  input  corrected_en,
  input  rollback_en_id,
  input  rollback_en_ex,


  input  [2:0]addr, 
  input  [2:0]addr_id, 
  input  [2:0]addr_ex, 
  
  input  SP_prediction_result,
  input  SP_prediction_result_id,
  input  SP_prediction_result_ex,

  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]LHP_count,
  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]LHP_count_id,
  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]LHP_count_ex,

  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]GHP_count,
  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]GHP_count_id,
  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]GHP_count_ex,

  input  [STAT_COUNTER_WIDTH - 1:0]SP_stat_count,
  input  [STAT_COUNTER_WIDTH - 1:0]SP_stat_count_id,
  input  [STAT_COUNTER_WIDTH - 1:0]SP_stat_count_ex,

  input  [STAT_COUNTER_WIDTH - 1:0]LHP_stat_count,
  input  [STAT_COUNTER_WIDTH - 1:0]LHP_stat_count_id,
  input  [STAT_COUNTER_WIDTH - 1:0]LHP_stat_count_ex,

  input  [STAT_COUNTER_WIDTH - 1:0]GHP_stat_count,
  input  [STAT_COUNTER_WIDTH - 1:0]GHP_stat_count_id,
  input  [STAT_COUNTER_WIDTH - 1:0]GHP_stat_count_ex,

  input  [2:0]SP_trend_count,
  input  [2:0]SP_trend_count_id,
  input  [2:0]SP_trend_count_ex,

  input  [2:0]LHP_trend_count,
  input  [2:0]LHP_trend_count_id,
  input  [2:0]LHP_trend_count_ex,

  input  [2:0]GHP_trend_count,
  input  [2:0]GHP_trend_count_id,
  input  [2:0]GHP_trend_count_ex,


  output clear_en1,
  output clear_en2,

  output WR_SP_stat_en1,
  output WR_LHP_stat_en1,  
  output WR_GHP_stat_en1, 
  output WR_SP_stat_en2,  
  output WR_LHP_stat_en2,  
  output WR_GHP_stat_en2, 

  output WR_SP_trend_en1,
  output WR_LHP_trend_en1,  
  output WR_GHP_trend_en1,   
  output WR_SP_trend_en2,
  output WR_LHP_trend_en2,  
  output WR_GHP_trend_en2, 

  output [2:0]WR_addr1,
  output [2:0]WR_addr2,

  output WR_SP_index1,
  output WR_SP_index2,
  output [JUMP_STATUS_COUNTER_WIDTH - 1:0]WR_LHP_index1,
  output [JUMP_STATUS_COUNTER_WIDTH - 1:0]WR_LHP_index2,
  output [JUMP_STATUS_COUNTER_WIDTH - 1:0]WR_GHP_index1,
  output [JUMP_STATUS_COUNTER_WIDTH - 1:0]WR_GHP_index2,  

  output [2:0]WR_SP_trend_count1,
  output [2:0]WR_SP_trend_count2,
  output [2:0]WR_LHP_trend_count1,
  output [2:0]WR_LHP_trend_count2,
  output [2:0]WR_GHP_trend_count1,
  output [2:0]WR_GHP_trend_count2,

  output [STAT_COUNTER_WIDTH - 1:0]WR_SP_stat_count1,
  output [STAT_COUNTER_WIDTH - 1:0]WR_SP_stat_count2,
  output [STAT_COUNTER_WIDTH - 1:0]WR_LHP_stat_count1,
  output [STAT_COUNTER_WIDTH - 1:0]WR_LHP_stat_count2,
  output [STAT_COUNTER_WIDTH - 1:0]WR_GHP_stat_count1,
  output [STAT_COUNTER_WIDTH - 1:0]WR_GHP_stat_count2
);
  
  localparam STAT_COUNTER_WIDTH_UB = STAT_COUNTER_WIDTH - 1;
  localparam JUMP_STATUS_COUNTER_WIDTH_UB = JUMP_STATUS_COUNTER_WIDTH - 1;

  reg [2:0]SP_trend_count_reg_id, SP_trend_count_reg_ex;
  reg [2:0]LHP_trend_count_reg_id, LHP_trend_count_reg_ex;
  reg [2:0]GHP_trend_count_reg_id, GHP_trend_count_reg_ex;

  wire SP_prediction_failed, LHP_prediction_failed, GHP_prediction_failed;
  wire SP_prediction_failed_id, LHP_prediction_failed_id, GHP_prediction_failed_id;
  wire SP_prediction_failed_ex, LHP_prediction_failed_ex, GHP_prediction_failed_ex;

  wire [2:0]OF1, OF2;
  wire SP_conflict, LHP_conflict, GHP_conflict;

/////////////////////////////////////////////////////////////////////

  localparam ZERO = 3'b000;

  always @(posedge clk)
  begin
    if (!rst_n)
      begin  
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

/////////////////////////////////////////////////////////////////////////////////////
  
  wire addr_conflict;
  assign addr_conflict = addr_id == addr_ex;
  assign SP_conflict   = addr_conflict && (SP_prediction_result_id == SP_prediction_result_ex);
  assign LHP_conflict  = addr_conflict && (LHP_count_id == LHP_count_ex);
  assign GHP_conflict  = addr_conflict && (GHP_count_id == GHP_count_ex);

  assign WR_SP_trend_en1  = rollback_en_id && !SP_conflict;
  assign WR_LHP_trend_en1 = rollback_en_id && !LHP_conflict;
  assign WR_GHP_trend_en1 = rollback_en_id && !GHP_conflict;

  assign WR_SP_trend_en2  = corrected_en || rollback_en_ex;
  assign WR_LHP_trend_en2 = corrected_en || rollback_en_ex;
  assign WR_GHP_trend_en2 = corrected_en || rollback_en_ex;

  assign WR_SP_stat_en1  = WR_SP_trend_en1  && !OF1[2];
  assign WR_LHP_stat_en1 = WR_LHP_trend_en1 && !OF1[1];
  assign WR_GHP_stat_en1 = WR_GHP_trend_en1 && !OF1[0];
  
  assign WR_SP_stat_en2  = WR_SP_trend_en2  && !OF2[2];
  assign WR_LHP_stat_en2 = WR_LHP_trend_en2 && !OF2[1];
  assign WR_GHP_stat_en2 = WR_GHP_trend_en2 && !OF2[0];

  assign clear_en1 = (|OF1) && rollback_en_id && !(addr_conflict && clear_en2);
  assign clear_en2 = |OF2;

////////////////////////////////////////////////////////////////////////////////////

  assign WR_addr1 = addr_id;
  assign WR_addr2 = rollback_en_ex ? addr_ex : addr;

  assign WR_SP_index1 = SP_prediction_result_id;
  assign WR_SP_index2 = rollback_en_ex ? SP_prediction_result_ex : SP_prediction_result;

  assign WR_LHP_index1 = LHP_count_id;
  assign WR_LHP_index2 = rollback_en_ex ? LHP_count_ex : LHP_count;

  assign WR_GHP_index1 = GHP_count_id;
  assign WR_GHP_index2 = rollback_en_ex ? GHP_count_ex : GHP_count;

////////////////////////////////////////////////////////////////////////////////////

  assign WR_SP_trend_count1  = SP_trend_count_reg_id;
  assign WR_LHP_trend_count1 = LHP_trend_count_reg_id;
  assign WR_GHP_trend_count1 = GHP_trend_count_reg_id;


  wire [2:0]WR_SP_trend_count, WR_LHP_trend_count, WR_GHP_trend_count;
  wire [2:0]WR_SP_trend_count_ex, WR_LHP_trend_count_ex, WR_GHP_trend_count_ex;
  trend_counter_operator SP_trend_count_operator_inst(
    .count(SP_trend_count),
    .true_down_false_up(SP_prediction_failed),
    .new_count(WR_SP_trend_count)
  );
  trend_counter_operator LHP_trend_count_operator_inst(
    .count(LHP_trend_count),
    .true_down_false_up(LHP_prediction_failed),
    .new_count(WR_LHP_trend_count)
  );
  trend_counter_operator GHP_trend_count_operator_inst(
    .count(GHP_trend_count),
    .true_down_false_up(GHP_prediction_failed),
    .new_count(WR_GHP_trend_count)
  );
  trend_counter_operator SP_trend_count_ex_operator_inst(
    .count(SP_trend_count_reg_ex),
    .true_down_false_up(SP_prediction_failed_ex),
    .new_count(WR_SP_trend_count_ex)
  );
  trend_counter_operator LHP_trend_count_ex_operator_inst(
    .count(LHP_trend_count_reg_ex),
    .true_down_false_up(LHP_prediction_failed_ex),
    .new_count(WR_LHP_trend_count_ex)
  );
  trend_counter_operator GHP_trend_countex_operator_inst(
    .count(GHP_trend_count_reg_ex),
    .true_down_false_up(GHP_prediction_failed_ex),
    .new_count(WR_GHP_trend_count_ex)
  );

  assign WR_SP_trend_count2  = rollback_en_ex ? WR_SP_trend_count_ex  : WR_SP_trend_count;
  assign WR_LHP_trend_count2 = rollback_en_ex ? WR_LHP_trend_count_ex : WR_LHP_trend_count;
  assign WR_GHP_trend_count2 = rollback_en_ex ? WR_GHP_trend_count_ex : WR_GHP_trend_count;

////////////////////////////////////////////////////////////////////////////////////

  localparam [2:0]P_THREE = 3'b011;
  localparam [2:0]P_TWO   = 3'b010;
  localparam [2:0]P_ONE   = 3'b001; 
  localparam [2:0]N_ONE   = 3'b111;
  localparam [2:0]N_TWO   = 3'b110;
  localparam [2:0]N_THREE = 3'b101;

  stat_counter_operator #(
    .STAT_COUNTER_WIDTH(STAT_COUNTER_WIDTH)
  ) SP_stat_count1_operator_inst(
    .A(SP_stat_count_id),
    .B(SP_prediction_failed_id ? P_ONE : N_ONE),
    .OF(OF1[2]),
    .result(WR_SP_stat_count1)
  );
  stat_counter_operator #(
    .STAT_COUNTER_WIDTH(STAT_COUNTER_WIDTH)
  ) LHP_stat_count1_operator_inst(
    .A(LHP_stat_count_id),
    .B(LHP_prediction_failed_id ? P_ONE : N_ONE),
    .OF(OF1[1]),
    .result(WR_LHP_stat_count1)
  );
  stat_counter_operator #(
    .STAT_COUNTER_WIDTH(STAT_COUNTER_WIDTH)
  ) GHP_stat_count1_operator_inst(
    .A(GHP_stat_count_id),
    .B(GHP_prediction_failed_id ? P_ONE : N_ONE),
    .OF(OF1[0]),
    .result(WR_GHP_stat_count1)
  );

  wire [2:0]OF, OF_ex;
  assign OF2 = rollback_en_ex ? OF_ex : OF;

  wire [STAT_COUNTER_WIDTH_UB:0]WR_SP_stat_count, WR_LHP_stat_count, WR_GHP_stat_count;
  wire [STAT_COUNTER_WIDTH_UB:0]WR_SP_stat_count_ex, WR_LHP_stat_count_ex, WR_GHP_stat_count_ex;
  assign WR_SP_stat_count2  = rollback_en_ex ? WR_SP_stat_count_ex  : WR_SP_stat_count;
  assign WR_LHP_stat_count2 = rollback_en_ex ? WR_LHP_stat_count_ex : WR_LHP_stat_count;
  assign WR_GHP_stat_count2 = rollback_en_ex ? WR_GHP_stat_count_ex : WR_GHP_stat_count;


  localparam P_THREE_INDEX = 5;
  localparam P_TWO_INDEX   = 4;
  localparam P_ONE_INDEX   = 3;
  localparam N_ONE_INDEX   = 2; 
  localparam N_TWO_INDEX   = 1;  
  localparam N_THREE_INDEX = 0;

  wire [2:0]SP_B_ex, LHP_B_ex, GHP_B_ex;
  wire [5:0]SP_B_signal_ex, LHP_B_signal_ex, GHP_B_signal_ex;
  assign SP_B_signal_ex[P_THREE_INDEX] =  (rollback_en_id && SP_conflict) && !SP_prediction_failed_ex &&  SP_prediction_failed_id; 
  assign SP_B_signal_ex[P_TWO_INDEX]   = !(rollback_en_id && SP_conflict) && !SP_prediction_failed_ex;
  assign SP_B_signal_ex[P_ONE_INDEX]   =  (rollback_en_id && SP_conflict) && !SP_prediction_failed_ex && !SP_prediction_failed_id;
  assign SP_B_signal_ex[N_ONE_INDEX]   =  (rollback_en_id && SP_conflict) &&  SP_prediction_failed_ex &&  SP_prediction_failed_id;
  assign SP_B_signal_ex[N_TWO_INDEX]   = !(rollback_en_id && SP_conflict) &&  SP_prediction_failed_ex;
  assign SP_B_signal_ex[N_THREE_INDEX] =  (rollback_en_id && SP_conflict) &&  SP_prediction_failed_ex && !SP_prediction_failed_id;

  assign LHP_B_signal_ex[P_THREE_INDEX] =  (rollback_en_id && LHP_conflict) && !LHP_prediction_failed_ex &&  LHP_prediction_failed_id;
  assign LHP_B_signal_ex[P_TWO_INDEX]   = !(rollback_en_id && LHP_conflict) && !LHP_prediction_failed_ex;
  assign LHP_B_signal_ex[P_ONE_INDEX]   =  (rollback_en_id && LHP_conflict) && !LHP_prediction_failed_ex && !LHP_prediction_failed_id;
  assign LHP_B_signal_ex[N_ONE_INDEX]   =  (rollback_en_id && LHP_conflict) &&  LHP_prediction_failed_ex &&  LHP_prediction_failed_id;
  assign LHP_B_signal_ex[N_TWO_INDEX]   = !(rollback_en_id && LHP_conflict) &&  LHP_prediction_failed_ex;
  assign LHP_B_signal_ex[N_THREE_INDEX] =  (rollback_en_id && LHP_conflict) &&  LHP_prediction_failed_ex && !LHP_prediction_failed_id;

  assign GHP_B_signal_ex[P_THREE_INDEX] =  (rollback_en_id && GHP_conflict) && !GHP_prediction_failed_ex &&  GHP_prediction_failed_id;
  assign GHP_B_signal_ex[P_TWO_INDEX]   = !(rollback_en_id && GHP_conflict) && !GHP_prediction_failed_ex;
  assign GHP_B_signal_ex[P_ONE_INDEX]   =  (rollback_en_id && GHP_conflict) && !GHP_prediction_failed_ex && !GHP_prediction_failed_id;
  assign GHP_B_signal_ex[N_ONE_INDEX]   =  (rollback_en_id && GHP_conflict) &&  GHP_prediction_failed_ex &&  GHP_prediction_failed_id;
  assign GHP_B_signal_ex[N_TWO_INDEX]   = !(rollback_en_id && GHP_conflict) &&  GHP_prediction_failed_ex;
  assign GHP_B_signal_ex[N_THREE_INDEX] =  (rollback_en_id && GHP_conflict) &&  GHP_prediction_failed_ex && !GHP_prediction_failed_id;
  
  parallel_mux #(
    .WIDTH(3),
    .MUX_QUANTITY(6)
  ) SP_B_mux6_inst(
    .din({P_THREE, P_TWO, P_ONE, N_ONE, N_TWO, N_THREE}),
    .signal(SP_B_signal_ex),
    .dout(SP_B_ex)
  );
  parallel_mux #(
    .WIDTH(3),
    .MUX_QUANTITY(6)
  ) LHP_B_mux6_inst(
    .din({P_THREE, P_TWO, P_ONE, N_ONE, N_TWO, N_THREE}),
    .signal(LHP_B_signal_ex),
    .dout(LHP_B_ex)
  );
  parallel_mux #(
    .WIDTH(3),
    .MUX_QUANTITY(6)
  ) GHP_B_mux6_inst(
    .din({P_THREE, P_TWO, P_ONE, N_ONE, N_TWO, N_THREE}),
    .signal(GHP_B_signal_ex),
    .dout(GHP_B_ex)
  );

  stat_counter_operator #(
    .STAT_COUNTER_WIDTH(STAT_COUNTER_WIDTH)
  ) SP_stat_count_operator_inst(
    .A(SP_stat_count),
    .B(SP_prediction_failed ? N_ONE : P_ONE),
    .OF(OF[2]),
    .result(WR_SP_stat_count)
  );
  stat_counter_operator #(
    .STAT_COUNTER_WIDTH(STAT_COUNTER_WIDTH)
  ) LHP_stat_count_operator_inst(
    .A(LHP_stat_count),
    .B(LHP_prediction_failed ? N_ONE : P_ONE),
    .OF(OF[1]),
    .result(WR_LHP_stat_count)
  );
  stat_counter_operator #(
    .STAT_COUNTER_WIDTH(STAT_COUNTER_WIDTH)
  ) GHP_stat_count_operator_inst(
    .A(GHP_stat_count),
    .B(GHP_prediction_failed ? N_ONE : P_ONE),
    .OF(OF[0]),
    .result(WR_GHP_stat_count)
  );
  stat_counter_operator #(
    .STAT_COUNTER_WIDTH(STAT_COUNTER_WIDTH)
  ) SP_stat_count_ex_operator_inst(
    .A(SP_stat_count_ex),
    .B(SP_B_ex),
    .OF(OF_ex[2]),
    .result(WR_SP_stat_count_ex)
  );
  stat_counter_operator #(
    .STAT_COUNTER_WIDTH(STAT_COUNTER_WIDTH)
  ) LHP_stat_count_ex_operator_inst(
    .A(LHP_stat_count_ex),
    .B(LHP_B_ex),
    .OF(OF_ex[1]),
    .result(WR_LHP_stat_count_ex)
  );
  stat_counter_operator #(
    .STAT_COUNTER_WIDTH(STAT_COUNTER_WIDTH)
  ) GHP_stat_count_ex_operator_inst(
    .A(GHP_stat_count_ex),
    .B(GHP_B_ex),
    .OF(OF_ex[0]),
    .result(WR_GHP_stat_count_ex)
  );

////////////////////////////////////////////////////////////////////////////////////

  assign SP_prediction_failed  = corrected_result != SP_prediction_result;
  assign LHP_prediction_failed = corrected_result != LHP_count[JUMP_STATUS_COUNTER_WIDTH_UB];
  assign GHP_prediction_failed = corrected_result != GHP_count[JUMP_STATUS_COUNTER_WIDTH_UB];

  assign SP_prediction_failed_id  = jump_result_id != SP_prediction_result_id;
  assign LHP_prediction_failed_id = jump_result_id != LHP_count_id[JUMP_STATUS_COUNTER_WIDTH_UB];
  assign GHP_prediction_failed_id = jump_result_id != GHP_count_id[JUMP_STATUS_COUNTER_WIDTH_UB];

  assign SP_prediction_failed_ex  = jump_result_ex == SP_prediction_result_ex;
  assign LHP_prediction_failed_ex = jump_result_ex == LHP_count_ex[JUMP_STATUS_COUNTER_WIDTH_UB];
  assign GHP_prediction_failed_ex = jump_result_ex == GHP_count_ex[JUMP_STATUS_COUNTER_WIDTH_UB];
endmodule 