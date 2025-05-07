`include "define.v"

module prediction_arbiter #(
  parameter STAT_COUNTER_WIDTH = 5,
  parameter [STAT_COUNTER_WIDTH - 1:0]HIGH_CONFIDENCE_OR_VALUE = 3
)(
  input SP_prediction_result,
  input LHP_prediction_result,
  input GHP_prediction_result,

  input [3:0]SP_trend_decode,
  input [3:0]LHP_trend_decode,
  input [3:0]GHP_trend_decode,

  input [STAT_COUNTER_WIDTH - 1:0]SP_stat_count,
  input [STAT_COUNTER_WIDTH - 1:0]LHP_stat_count,
  input [STAT_COUNTER_WIDTH - 1:0]GHP_stat_count,

  output prediction_result
);

  localparam STAT_COUNTER_WIDTH_UB = STAT_COUNTER_WIDTH - 1;
  localparam [STAT_COUNTER_WIDTH_UB:0]ZERO = {STAT_COUNTER_WIDTH{1'b0}};

  wire [STAT_COUNTER_WIDTH_UB:0]SP_corrected_stat_count, LHP_corrected_stat_count, GHP_corrected_stat_count;
  assign SP_corrected_stat_count  = SP_trend_decode[0]  ? ZERO : SP_trend_decode[3] ?  HIGH_CONFIDENCE_OR_VALUE | SP_stat_count : SP_stat_count;
  assign LHP_corrected_stat_count = LHP_trend_decode[0] ? ZERO : LHP_trend_decode[3] ? HIGH_CONFIDENCE_OR_VALUE | LHP_stat_count : LHP_stat_count;
  assign GHP_corrected_stat_count = GHP_trend_decode[0] ? ZERO : GHP_trend_decode[3] ? HIGH_CONFIDENCE_OR_VALUE | GHP_stat_count : GHP_stat_count;


  wire SP_LHP_conflict, SP_GHP_conflict;
  assign SP_LHP_conflict = SP_prediction_result ^ LHP_prediction_result;
  assign SP_GHP_conflict = SP_prediction_result ^ GHP_prediction_result;

  wire no_conflict, SP_only, LHP_only, GHP_only;
  assign no_conflict = !SP_LHP_conflict && !SP_GHP_conflict;
  assign SP_only     =  SP_LHP_conflict &&  SP_GHP_conflict;
  assign LHP_only    =  SP_LHP_conflict && !SP_GHP_conflict;
  assign GHP_only    = !SP_LHP_conflict &&  SP_GHP_conflict;


///////////////////////////////////////////////////////////////////////////

  wire double_arbitrate_signal, once_arbitrate_result;


  wire [STAT_COUNTER_WIDTH_UB:0]stat_only;    
  parallel_mux #(
    .WIDTH(STAT_COUNTER_WIDTH),
    .MUX_QUANTITY(3)
  ) stat_only_mux3_inst(
    .din({SP_corrected_stat_count, LHP_corrected_stat_count, GHP_corrected_stat_count}),
    .signal({SP_only, LHP_only, GHP_only}),
    .dout(stat_only)
  );

  wire [STAT_COUNTER_WIDTH_UB:0]stat_A, stat_B;
  assign stat_A = SP_LHP_conflict ? GHP_corrected_stat_count : SP_corrected_stat_count;
  assign stat_B = SP_GHP_conflict ? LHP_corrected_stat_count : SP_corrected_stat_count;

  wire [STAT_COUNTER_WIDTH:0]stat_sum;
  assign stat_sum = stat_A + stat_B;

  parallel_unsig_comparator_eq_lt #(
    .WIDTH(STAT_COUNTER_WIDTH + 1)
  ) stat_arbiter_comparator_inst (
    .data1(stat_sum),
    .data2({`zero, stat_only}),
    .eq_result(double_arbitrate_signal),
    .lt_result(once_arbitrate_result)
  );

////////////////////////////////////////////////////////////////////////////////////

  wire double_arbitrate_result;

  wire [3:0]trend_only;  
  parallel_mux #(
    .WIDTH(4),
    .MUX_QUANTITY(3)
  ) trend_only_mux3_inst(
    .din({SP_trend_decode, LHP_trend_decode, GHP_trend_decode}),
    .signal({SP_only, LHP_only, GHP_only}),
    .dout(trend_only)
  ); 

  assign double_arbitrate_result = trend_only[3];

/////////////////////////////////////////////////////////////////////////////////////

  wire only_arbitrate_result;
  assign only_arbitrate_result = once_arbitrate_result || (double_arbitrate_signal && double_arbitrate_result);

  wire SP_sel, LHP_sel, GHP_sel;
  assign SP_sel  = (SP_only  && only_arbitrate_result) || (GHP_only && !only_arbitrate_result);
  assign LHP_sel = (LHP_only && only_arbitrate_result) || (SP_only  && !only_arbitrate_result);
  assign GHP_sel = (GHP_only && only_arbitrate_result) || (LHP_only && !only_arbitrate_result);

  parallel_mux #(
    .WIDTH(1),
    .MUX_QUANTITY(3)
  ) prediction_result_mux3_inst(
    .din({SP_prediction_result, LHP_prediction_result, GHP_prediction_result}),
    .signal({no_conflict || SP_sel, LHP_sel, GHP_sel}),
    .dout(prediction_result)
  );
endmodule