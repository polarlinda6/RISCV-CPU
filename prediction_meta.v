module meta_predictor #(
  parameter JUMP_STATUS_COUNTER_WIDTH = 2,
  parameter STAT_COUNTER_WIDTH = 5,
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

  localparam STAT_COUNTER_WIDTH_UB = STAT_COUNTER_WIDTH - 1;  
  localparam JUMP_STATUS_COUNTER_WIDTH_UB = JUMP_STATUS_COUNTER_WIDTH - 1;

  localparam JUMP_STATUS_COUNTER_CAPACITY = 1 << JUMP_STATUS_COUNTER_WIDTH;
  localparam JUMP_STATUS_COUNTER_CAPACITY_UB = JUMP_STATUS_COUNTER_CAPACITY - 1;

  reg [3 + STAT_COUNTER_WIDTH_UB:0]SP_trend_stat_counter_regs [5:0][1:0];
  reg [3 + STAT_COUNTER_WIDTH_UB:0]GHP_trend_stat_counter_regs[5:0][JUMP_STATUS_COUNTER_CAPACITY_UB:0];
  reg [3 + STAT_COUNTER_WIDTH_UB:0]LHP_trend_stat_counter_regs[5:0][JUMP_STATUS_COUNTER_CAPACITY_UB:0];


  wire [2:0]addr, addr_id, addr_ex;
  wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]LHP_count, LHP_count_id, LHP_count_ex;


  wire SP_trend_stat_count, LHP_trend_stat_count, GHP_trend_stat_count;
  assign SP_trend_stat_count  = SP_stat_counter_regs[addr][SP_prediction_result];
  assign LHP_trend_stat_count = LHP_stat_counter_regs[addr][LHP_count];
  assign GHP_trend_stat_count = GHP_stat_counter_regs[addr][GHP_count];

  wire SP_stat_count, LHP_stat_count, GHP_stat_count;
  assign [STAT_COUNTER_WIDTH_UB:0]SP_stat_count  = SP_trend_stat_count [STAT_COUNTER_WIDTH_UB:0];
  assign [STAT_COUNTER_WIDTH_UB:0]LHP_stat_count = LHP_trend_stat_count[STAT_COUNTER_WIDTH_UB:0];
  assign [STAT_COUNTER_WIDTH_UB:0]GHP_stat_count = GHP_trend_stat_count[STAT_COUNTER_WIDTH_UB:0];

  wire SP_trend_count, LHP_trend_count, GHP_trend_count;
  assign [2:0]SP_trend_count  = SP_trend_stat_count [:STAT_COUNTER_WIDTH];
  assign [2:0]LHP_trend_count = LHP_trend_stat_count[:STAT_COUNTER_WIDTH];
  assign [2:0]GHP_trend_count = GHP_trend_stat_count[:STAT_COUNTER_WIDTH];


/////////////////////////////////////////////////////////////////////////////////





/////////////////////////////////////////////////////////////////////////////////

  wire [3:0]SP_trend_decode, LHP_trend_decode, GHP_trend_decode;
  trend_counter_decoder SP_trend_decode_inst(
    .count(SP_trend_count),
    .count_decode(SP_trend_decode)
  );
  trend_counter_decoder LHP_trend_decode_inst(
    .count(LHP_trend_count),
    .count_decode(LHP_trend_decode)
  );
  trend_counter_decoder GHP_trend_decode_inst(
    .count(GHP_trend_count),
    .count_decode(GHP_trend_decode)
  );

  prediction_arbiter #(
    .STAT_COUNTER_WIDTH(STAT_COUNTER_WIDTH),
    .TREND_COUNTER_WIDTH(TREND_COUNTER_WIDTH)
  ) prediction_arbiter_inst (
    .SP_prediction_result(SP_prediction_result),
    .LHP_prediction_result(LHP_count[JUMP_STATUS_COUNTER_WIDTH_UB]),
    .GHP_prediction_result(GHP_count[JUMP_STATUS_COUNTER_WIDTH_UB]),
    
    .SP_trend_decode(SP_trend_decode),
    .LHP_trend_decode(LHP_trend_decode),
    .GHP_trend_decode(GHP_trend_decode),

    .SP_stat_count(SP_stat_count),
    .LHP_stat_count(LHP_stat_count),
    .GHP_stat_count(GHP_stat_count),

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


`define high_confidence (count == 3'b001) || (count == 3'b010) || (count == 3'b011)
`define upward_trend    (count == 3'b000) || (count == 3'b010)
`define downward_trend  (count == 3'b001) || (count == 3'b111) || (count == 3'b101)
`define no_confidence   (count == 3'b100) || (count == 3'b101) || (count == 3'b110)


module trend_counter_decoder(
  input  [2:0]count,   
  output [3:0]count_decode
);

  assign count_decode[3] = `high_confidence;
  assign count_decode[2] = `upward_trend;
  assign count_decode[1] = `downward_trend;
  assign count_decode[0] = `no_confidence;
endmodule 


module trend_counter_operator(
  input  [2:0]count,
  input  true_down_false_up, 
  output [2:0]new_count
);

  localparam [2:0]P_TWO   = 3'b010;
  localparam [2:0]P_ONE   = 3'b001;
  localparam [2:0]N_TWO   = 3'b110;
  localparam [2:0]N_THREE = 3'b101;

  wire upward_trend_signal, downward_trend_signal;
  assign upward_trend_signal   = `upward_trend;
  assign downward_trend_signal = `downward_trend;
  
  wire [2:0]B;
  mux3 B_inst(
    .data1(true_down_false_up ? N_THREE : P_TWO),
    .data2(true_down_false_up ? N_TWO   : P_ONE),
    .data3(true_down_false_up ? N_TWO   : P_TWO),
    .signal({upward_trend_signal, downward_trend_signal}),
    .dout(B)
  );
  no_overflow_adder #(
    .WIDTH(3)
  ) adder_inst(
    .A(count),
    .B(B),
    .result(new_count)
  );
endmodule 