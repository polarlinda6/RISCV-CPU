module no_overflow_adder #(
  parameter WIDTH = 4
)(
  input  [WIDTH - 1:0]A,
  input  [WIDTH - 1:0]B,
  output [WIDTH - 1:0]result
);

  localparam UB = WIDTH - 1;
  localparam [UB:1]FULL_1 = {UB{1'b1}};
  localparam [UB:1]FULL_0 = {UB{1'b0}};
  localparam [UB:0]P_MAX  = {1'b0, FULL_1};
  localparam [UB:0]N_MAX  = {1'b1, FULL_0};


  wire PO, NO;
  wire [UB:0]add_result;

  overflow_adder #(
    .WIDTH(WIDTH)
  ) overflow_adder_inst (
    .A(A),
    .B(B),
    .PO(PO),
    .NO(NO),
    .result(add_result)
  );
  
  assign result = PO ? P_MAX : 
                  NO ? N_MAX : add_result;
endmodule


module overflow_adder #(
  parameter WIDTH = 4
)(
  input  [WIDTH - 1:0]A,
  input  [WIDTH - 1:0]B,

  output PO,
  output NO,
  output [WIDTH - 1:0]result
);
  
  localparam UB = WIDTH - 1;

  assign result = A + B; 

  wire Asig, Bsig, Rsig;
  assign Asig = A[UB];
  assign Bsig = B[UB];
  assign Rsig = result[UB];

  assign PO = !Asig && !Bsig && Rsig;
  assign NO = Asig && Bsig && !Rsig;
endmodule