`include "define.v"

module stat_counter_operator #(
  parameter STAT_COUNTER_WIDTH = 5
)(
  input  [STAT_COUNTER_WIDTH - 1:0]A, 
  input  [2:0]B,
  output OF,
  output [STAT_COUNTER_WIDTH - 1:0]result
);
  localparam SUB = STAT_COUNTER_WIDTH - 3;

  no_overflow_unsig_adder #(
    .WIDTH(STAT_COUNTER_WIDTH),
    .ALLOW_PO(`true),
    .ALLOW_NO(`false)
  ) adder_inst(
    .A(A),
    .B({{SUB{B[2]}}, B}),
    .OF(OF),
    .UF(),
    .result(result)
  );
endmodule 