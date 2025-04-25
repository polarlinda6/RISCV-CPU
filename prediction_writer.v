`include "define.v"

module prediction_writer #(
  parameter JUMP_STATUS_COUNTER_WIDTH = 2,
  parameter STAT_COUNTER_WIDTH = 5
)(
  input  clk,
  input  rst_n,
  input  PL_stall, 

  input  prediction_result,
  input  prediction_result_id,
  input  prediction_result_ex,

  input  prediction_en,
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

  output WR_SP_en1,
  output WR_SP_en2,   
  output WR_LHP_en1,
  output WR_LHP_en2, 
  output WR_GHP_en1,
  output WR_GHP_en2, 
  
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
  
  localparam JUMP_STATUS_COUNTER_WIDTH_UB = JUMP_STATUS_COUNTER_WIDTH - 1;

  reg [2:0]SP_trend_count_reg_id, SP_trend_count_reg_ex;
  reg [2:0]LHP_trend_count_reg_id, LHP_trend_count_reg_ex;
  reg [2:0]GHP_trend_count_reg_id, GHP_trend_count_reg_ex;

  wire SP_conflict, LHP_conflict, GHP_conflict;
  wire SP_prediction_failed, LHP_prediction_failed, GHP_prediction_failed;
  wire SP_prediction_failed_ex, LHP_prediction_failed_ex, GHP_prediction_failed_ex;

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

  assign WR_SP_en1  = rollback_en_id && !SP_conflict;
  assign WR_LHP_en1 = rollback_en_id && !LHP_conflict;
  assign WR_GHP_en1 = rollback_en_id && !GHP_conflict;

  assign WR_SP_en2  = prediction_en || rollback_en_ex;
  assign WR_LHP_en2 = prediction_en || rollback_en_ex;
  assign WR_GHP_en2 = prediction_en || rollback_en_ex;

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

  trend_counter_operator SP_trend_inst(
    .count(             rollback_en_ex ? SP_trend_count_reg_ex   : SP_trend_count),
    .true_down_false_up(rollback_en_ex ? SP_prediction_failed_ex : SP_prediction_failed),
    .new_count(WR_SP_trend_count2)
  );
  trend_counter_operator LHP_trend_inst(
    .count(             rollback_en_ex ? LHP_trend_count_reg_ex   : LHP_trend_count),
    .true_down_false_up(rollback_en_ex ? LHP_prediction_failed_ex : LHP_prediction_failed),
    .new_count(WR_LHP_trend_count2)
  );
  trend_counter_operator GHP_trend_inst(
    .count(             rollback_en_ex ? GHP_trend_count_reg_ex   : GHP_trend_count),
    .true_down_false_up(rollback_en_ex ? GHP_prediction_failed_ex : GHP_prediction_failed),
    .new_count(WR_GHP_trend_count2)
  );

////////////////////////////////////////////////////////////////////////////////////

  localparam [2:0]P_THREE = 3'b011;
  localparam [2:0]P_TWO   = 3'b010;
  localparam [2:0]P_ONE   = 3'b001;
  localparam [2:0]N_THREE = 3'b101;
  localparam [2:0]N_TWO   = 3'b110;
  localparam [2:0]N_ONE   = 3'b111;

  wire SP_prediction_failed_id, LHP_prediction_failed_id, GHP_prediction_failed_id;
  assign SP_prediction_failed_id  = prediction_result_id != SP_prediction_result_id;
  assign LHP_prediction_failed_id = prediction_result_id != LHP_count_id[JUMP_STATUS_COUNTER_WIDTH_UB];
  assign GHP_prediction_failed_id = prediction_result_id != GHP_count_id[JUMP_STATUS_COUNTER_WIDTH_UB];
  
  wire [2:0]OF1, OF2;
  assign clear_en1 = (|OF1) &&  rollback_en_id && !SP_conflict && !LHP_conflict && !GHP_conflict;
  assign clear_en2 = |OF2;



  stat_count_operator #(
    .STAT_COUNTER_WIDTH(STAT_COUNTER_WIDTH)
  ) SP_stat_count1_inst(
    .A(SP_stat_count_id),
    .B(SP_prediction_failed_id ? P_ONE : N_ONE),
    .OF(OF1[0]),
    .result(WR_SP_stat_count1)
  );
  stat_count_operator #(
    .STAT_COUNTER_WIDTH(STAT_COUNTER_WIDTH)
  ) LHP_stat_count1_inst(
    .A(LHP_stat_count_id),
    .B(LHP_prediction_failed_id ? P_ONE : N_ONE),
    .OF(OF1[1]),
    .result(WR_LHP_stat_count1)
  );
  stat_count_operator #(
    .STAT_COUNTER_WIDTH(STAT_COUNTER_WIDTH)
  ) GHP_stat_count1_inst(
    .A(GHP_stat_count_id),
    .B(GHP_prediction_failed_id ? P_ONE : N_ONE),
    .OF(OF1[2]),
    .result(WR_GHP_stat_count1)
  );


  wire [2:0]SP_B, LHP_B, GHP_B;
  wire [5:0]SP_B_signal, LHP_B_signal, GHP_B_signal;
  assign SP_B_signal[5] =  SP_conflict && !SP_prediction_failed_ex && !SP_prediction_failed_id; 
  assign SP_B_signal[4] = !SP_conflict && !SP_prediction_failed_ex;
  assign SP_B_signal[3] =  SP_conflict && !SP_prediction_failed_id &&  SP_prediction_failed_id;
  assign SP_B_signal[2] =  SP_conflict &&  SP_prediction_failed_ex && !SP_prediction_failed_id;
  assign SP_B_signal[1] = !SP_conflict &&  SP_prediction_failed_id;
  assign SP_B_signal[0] =  SP_conflict &&  SP_prediction_failed_ex &&  SP_prediction_failed_id;

  assign LHP_B_signal[5] =  LHP_conflict && !LHP_prediction_failed_ex && !LHP_prediction_failed_id;
  assign LHP_B_signal[4] = !LHP_conflict && !LHP_prediction_failed_ex;
  assign LHP_B_signal[3] =  LHP_conflict && !LHP_prediction_failed_id &&  LHP_prediction_failed_id;
  assign LHP_B_signal[2] =  LHP_conflict &&  LHP_prediction_failed_ex && !LHP_prediction_failed_id;
  assign LHP_B_signal[1] = !LHP_conflict &&  LHP_prediction_failed_id;
  assign LHP_B_signal[0] =  LHP_conflict &&  LHP_prediction_failed_ex &&  LHP_prediction_failed_id;

  assign GHP_B_signal[5] =  GHP_conflict && !GHP_prediction_failed_ex && !GHP_prediction_failed_id;
  assign GHP_B_signal[4] = !GHP_conflict && !GHP_prediction_failed_ex;
  assign GHP_B_signal[3] =  GHP_conflict && !GHP_prediction_failed_id &&  GHP_prediction_failed_id;
  assign GHP_B_signal[2] =  GHP_conflict &&  GHP_prediction_failed_ex && !GHP_prediction_failed_id;
  assign GHP_B_signal[1] = !GHP_conflict &&  GHP_prediction_failed_id;
  assign GHP_B_signal[0] =  GHP_conflict &&  GHP_prediction_failed_ex &&  GHP_prediction_failed_id;
  
  parallel_mux #(
    .WIDTH(3),
    .MUX_QUANTITY(6)
  ) SP_B_inst(
    .data({P_THREE, P_TWO, P_ONE, N_ONE, N_TWO, N_THREE}),
    .signal(SP_B_signal),
    .dout(SP_B)
  );
  parallel_mux #(
    .WIDTH(3),
    .MUX_QUANTITY(6)
  ) LHP_B_inst(
    .data({P_THREE, P_TWO, P_ONE, N_ONE, N_TWO, N_THREE}),
    .signal(LHP_B_signal),
    .dout(LHP_B)
  );
  parallel_mux #(
    .WIDTH(3),
    .MUX_QUANTITY(6)
  ) GHP_B_inst(
    .data({P_THREE, P_TWO, P_ONE, N_ONE, N_TWO, N_THREE}),
    .signal(GHP_B_signal),
    .dout(GHP_B)
  );

  stat_count_operator #(
    .STAT_COUNTER_WIDTH(STAT_COUNTER_WIDTH)
  ) SP_stat_count2_inst(
    .A(rollback_en_ex ? SP_stat_count_ex : SP_stat_count),
    .B(rollback_en_ex ? SP_B : (SP_prediction_failed ? N_ONE : P_ONE)),
    .OF(OF2[0]),
    .result(WR_SP_stat_count2)
  );
  stat_count_operator #(
    .STAT_COUNTER_WIDTH(STAT_COUNTER_WIDTH)
  ) LHP_stat_count2_inst(
    .A(rollback_en_ex ? LHP_stat_count_ex : LHP_stat_count),
    .B(rollback_en_ex ? LHP_B : (LHP_prediction_failed ? N_ONE : P_ONE)),
    .OF(OF2[1]),
    .result(WR_LHP_stat_count2)
  );
  stat_count_operator #(
    .STAT_COUNTER_WIDTH(STAT_COUNTER_WIDTH)
  ) GHP_stat_count2_inst(
    .A(rollback_en_ex ? GHP_stat_count_ex : GHP_stat_count),
    .B(rollback_en_ex ? GHP_B : (GHP_prediction_failed ? N_ONE : P_ONE)),
    .OF(OF2[2]),
    .result(WR_GHP_stat_count2)
  );

////////////////////////////////////////////////////////////////////////////////////

  wire addr_conflict;
  assign addr_conflict = addr_id == addr_ex;
  assign SP_conflict   = addr_conflict && (SP_prediction_result_id == SP_prediction_result_ex);
  assign LHP_conflict  = addr_conflict && (LHP_count_id == LHP_count_ex);
  assign GHP_conflict  = addr_conflict && (GHP_count_id == GHP_count_ex);

  assign SP_prediction_failed  = prediction_result != SP_prediction_result;
  assign LHP_prediction_failed = prediction_result != LHP_count[JUMP_STATUS_COUNTER_WIDTH_UB];
  assign GHP_prediction_failed = prediction_result != GHP_count[JUMP_STATUS_COUNTER_WIDTH_UB];

  assign SP_prediction_failed_ex  = prediction_result_ex == SP_prediction_result_ex;
  assign LHP_prediction_failed_ex = prediction_result_ex == LHP_count_ex[JUMP_STATUS_COUNTER_WIDTH_UB];
  assign GHP_prediction_failed_ex = prediction_result_ex == GHP_count_ex[JUMP_STATUS_COUNTER_WIDTH_UB];
endmodule 