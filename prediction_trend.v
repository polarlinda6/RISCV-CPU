`include "define.v"

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
  mux3 #(
    .WIDTH(3)
  ) B_inst(
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


module stat_count_operator #(
  parameter STAT_COUNTER_WIDTH = 5
)(
  input  [STAT_COUNTER_WIDTH - 1:0]A, 
  input  [2:0]B,
  output OF,
  output [STAT_COUNTER_WIDTH - 1:0]result
);
  

  localparam SUB = STAT_COUNTER_WIDTH - 2;
  localparam STAT_COUNTER_WIDTH_UB = STAT_COUNTER_WIDTH - 1;

  wire NO;
  wire [STAT_COUNTER_WIDTH:0]result_inner;

  overflow_adder #(
    .WIDTH(STAT_COUNTER_WIDTH + 1)
  ) adder_inst(
    .A({`zero, A}),
    .B({{SUB{B[2]}}, B}),

    .PO(OF),
    .NO(NO),
    .result(result_inner)
  );


  localparam [STAT_COUNTER_WIDTH_UB:0]ZERO = {STAT_COUNTER_WIDTH{1'b0}};
  assign result = NO ? ZERO : result_inner[STAT_COUNTER_WIDTH_UB:0];
endmodule 