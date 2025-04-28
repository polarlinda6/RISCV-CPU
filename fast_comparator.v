module fast_comparator #(
  parameter WIDTH = 32
)(
  input [WIDTH - 1:0]data1,
  input [WIDTH - 1:0]data2,
  input [2:0]func3,
  output compare_result
);

  wire eq, lt, ltu;

  parallel_comparator #(
    .WIDTH(WIDTH)
  ) parallel_comparator_inst(
    .data1(data1),
    .data2(data2),
    .beq_result(eq),
    .blt_result(lt),
    .bltu_result(ltu)
  );

  wire lt_result;
  assign lt_result = func3[1] ? ltu : lt; 

  assign compare_result = func3[2] ? (func3[0] ? !lt_result : lt_result) : (func3[0] ? !eq : eq);
endmodule


module parallel_comparator #(
  parameter WIDTH = 32
)(
  input  [WIDTH - 1:0]data1,
  input  [WIDTH - 1:0]data2,
  output beq_result,
  output blt_result,
  output bltu_result
);

  localparam WIDTH_UB = WIDTH - 1;

  wire gt_sig, lt_sig, eq_sig;
  assign gt_sig = data1[WIDTH_UB] > data2[WIDTH_UB];
  assign lt_sig = data1[WIDTH_UB] < data2[WIDTH_UB];
  assign eq_sig = data1[WIDTH_UB] == data2[WIDTH_UB];

  wire lt_bit, eq_bit;
  parallel_unsig_comparator_eq #(
    .WIDTH(WIDTH_UB)
  ) eq_inst(
    .data1(data1[WIDTH_UB - 1:0]),
    .data2(data2[WIDTH_UB - 1:0]),
    .compare_result(eq_bit)
  );
  parallel_unsig_comparator_lt #(
    .WIDTH(WIDTH_UB)
  ) lt_inst(
    .data1(data1[WIDTH_UB - 1:0]),
    .data2(data2[WIDTH_UB - 1:0]),
    .compare_result(lt_bit)
  );

  assign beq_result  = eq_sig && eq_bit;
  assign blt_result  = gt_sig || (eq_sig && lt_bit);
  assign bltu_result = lt_sig || (eq_sig && lt_bit);
endmodule


module parallel_unsig_comparator_lt #(
  parameter WIDTH = 32
)(
  input  [WIDTH - 1:0]data1,
  input  [WIDTH - 1:0]data2,
  output compare_result
);

  localparam PARALLEL_DEGREE = 4;
  localparam PARALLEL_DEGREE_UB = PARALLEL_DEGREE - 1;

  localparam BASE_COMPARATOR_WIDTH = WIDTH / PARALLEL_DEGREE + (WIDTH % PARALLEL_DEGREE ? 1 : 0);  
  localparam BASE_COMPARATOR_WIDTH_UB = BASE_COMPARATOR_WIDTH - 1;   

  localparam CORRECTED_WIDTH = PARALLEL_DEGREE * BASE_COMPARATOR_WIDTH;
  localparam CORRECTED_WIDTH_UB = CORRECTED_WIDTH - 1;

  localparam SUB = CORRECTED_WIDTH - WIDTH;
  wire [CORRECTED_WIDTH_UB:0]corrected_data1, corrected_data2;
  assign corrected_data1 = {{SUB{1'b0}}, data1};
  assign corrected_data2 = {{SUB{1'B0}}, data2};

  wire [PARALLEL_DEGREE_UB:0]result; 

  generate
    genvar i;
    for(i = 0; i < PARALLEL_DEGREE; i = i + 1) 
    begin
      localparam lb = i * BASE_COMPARATOR_WIDTH;
      localparam ub = lb + BASE_COMPARATOR_WIDTH_UB;

      assign result[i] = corrected_data1[ub:lb] < corrected_data2[ub:lb];
    end
  endgenerate

  assign compare_result = result[3] || 
                         (!result[3] && result[2]) || 
                         (!result[3] && !result[2] && result[1]) || 
                         (!result[3] && !result[2] && !result[1] && result[0]);
endmodule


module parallel_unsig_comparator_eq #(
  parameter WIDTH = 32
)(
  input  [WIDTH - 1:0]data1,
  input  [WIDTH - 1:0]data2,
  output compare_result
);

  wire ne_result;
  parallel_unsig_comparator_ne #(
    .WIDTH(WIDTH)
  ) comparator_ne_inst(
    .data1(data1),
    .data2(data2),
    .compare_result(ne_result)
  );
  assign compare_result = !ne_result;
endmodule


module parallel_unsig_comparator_ne #(
  parameter WIDTH = 32
)(
  input  [WIDTH - 1:0]data1,
  input  [WIDTH - 1:0]data2,
  output compare_result
);

  wire [WIDTH - 1:0]result;
  generate
    genvar i;
    for(i = 0; i < WIDTH; i = i + 1) begin
      assign result[i] = data1[i] != data2[i];
    end
  endgenerate

  large_fan_in_or #(
    .WIDTH(1),
    .OR_QUANTITY(WIDTH)
  ) inst(
    .din(result),
    .dout(compare_result)
  );
endmodule