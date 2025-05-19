module no_overflow_adder #(
  parameter WIDTH = 4
)(
  input  [WIDTH - 1:0]A,
  input  [WIDTH - 1:0]B,

  output PO,
  output NO,
  output [WIDTH - 1:0]result
);

  localparam UB = WIDTH - 1;
  localparam [UB:0]P_MAX  = {1'b0, {UB{1'b1}}};
  localparam [UB:0]N_MAX  = {1'b1, {UB{1'b0}}};

  wire [UB:0]result_inner;
  assign result_inner = A + B; 

  wire Asig, Bsig, Rsig;
  assign Asig = A[UB];
  assign Bsig = B[UB];
  assign Rsig = result_inner[UB];

  assign PO = !Asig && !Bsig && Rsig;
  assign NO = Asig && Bsig && !Rsig;
  
  assign result = PO ? P_MAX : 
                  NO ? N_MAX : result_inner;
endmodule


module no_overflow_unsig_adder #(
  parameter WIDTH = 4,
  parameter ALLOW_PO = 1,
  parameter ALLOW_NO = 1
)(
  input  [WIDTH - 1:0]A,
  input  [WIDTH - 1:0]B,

  output OF,
  output UF,
  output [WIDTH - 1:0]result
);
  
  localparam UB = WIDTH - 1;
  localparam P_MAX = {WIDTH{1'b1}};
  localparam ZERO  = {WIDTH{1'b0}};


  wire [UB:0]result_inner;
  assign result_inner = A + B; 

  wire ltu;
  parallel_unsig_comparator_eq_lt #(
    .WIDTH(WIDTH)
  ) ltu_comparator_inst(
    .data1(result_inner),
    .data2(A),
    .eq_result(),
    .lt_result(ltu)
  );

  assign OF = !B[UB] && ltu;
  assign UF = B[UB] && !ltu;

  generate
  if(ALLOW_PO && ALLOW_NO) assign result = result_inner;
  if(ALLOW_PO && !ALLOW_NO) assign result = UF ? ZERO : result_inner;
  if(!ALLOW_PO && ALLOW_NO) assign result = OF ? P_MAX : result_inner;
  if(!ALLOW_PO && !ALLOW_NO) assign result = OF ? P_MAX : (UF ? ZERO : result_inner);
  endgenerate
endmodule