`include "define.v"

`define high_confidence (count == 3'b011)
`define upward_trend    (count == 3'b000) || (count == 3'b010)
`define downward_trend  (count == 3'b001) || (count == 3'b111) || (count == 3'b101)
`define no_confidence   (count == 3'b100)

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
  ) B_mux3_inst(
    .din1(true_down_false_up ? N_THREE : P_TWO),
    .din2(true_down_false_up ? N_TWO   : P_ONE),
    .din3(true_down_false_up ? N_TWO   : P_TWO),
    .signal({upward_trend_signal, downward_trend_signal}),
    .dout(B)
  );
  no_overflow_adder #(
    .WIDTH(3)
  ) adder_inst(
    .A(count),
    .B(B),
    .PO(),
    .NO(),
    .result(new_count)
  );
endmodule 