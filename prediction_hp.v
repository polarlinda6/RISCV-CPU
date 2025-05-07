module history_predictor #(
  parameter JUMP_STATUS_COUNTER_WIDTH = 2,
  parameter [JUMP_STATUS_COUNTER_WIDTH - 1:0]JUMP_STATUS_COUNTER_INIT_VALUE = 0,  
  parameter INDEX_WIDTH = 12,
  parameter HR_WIDTH = 6
)(
  input  clk,
  input  rst_n,  
  input  PL_stall,

  input  corrected_result,

  input  corrected_en,
  input  rollback_en_id,
  input  rollback_en_ex,

  input  [31:0]pc,
  input  [31:0]pc_id, 
  input  [31:0]pc_ex,

  output [JUMP_STATUS_COUNTER_WIDTH - 1: 0]HP_count,
  output [JUMP_STATUS_COUNTER_WIDTH - 1: 0]HP_count_id,
  output [JUMP_STATUS_COUNTER_WIDTH - 1: 0]HP_count_ex
);

  localparam HR_DEPTH = HR_WIDTH + 2;
  localparam HR_DEPTH_UB = HR_DEPTH - 1;

  localparam INDEX_WIDTH_UB = INDEX_WIDTH - 1;
  localparam JUMP_STATUS_COUNTER_WIDTH_UB = JUMP_STATUS_COUNTER_WIDTH - 1;  

  localparam [JUMP_STATUS_COUNTER_WIDTH_UB:0]N_ONE  = {JUMP_STATUS_COUNTER_WIDTH{1'b1}};  
  localparam [JUMP_STATUS_COUNTER_WIDTH_UB:0]P_ONE  = {{JUMP_STATUS_COUNTER_WIDTH_UB{1'b0}}, 1'b1};

  wire prediction_result_branch_failed;
  reg [JUMP_STATUS_COUNTER_WIDTH_UB:0]count_reg_id, count_reg_ex;
  reg [HR_DEPTH_UB:0]history_reg;

  assign HP_count_id = count_reg_id;
  assign HP_count_ex = count_reg_ex;  
  
////////////////////////////////////////////////////////////////////////////////

  wire [HR_DEPTH_UB:0]history_ex = history_reg >> rollback_en_id;
  assign prediction_result_branch_failed = history_ex[0];

  always @(posedge clk)
  begin
    if (!rst_n)
    begin
      count_reg_id <= JUMP_STATUS_COUNTER_INIT_VALUE;
      count_reg_ex <= JUMP_STATUS_COUNTER_INIT_VALUE;
      history_reg  <= {HR_DEPTH{1'b0}};
    end
    else
    begin
      if(!PL_stall) 
      begin   
        count_reg_id <= HP_count;
        count_reg_ex <= count_reg_id;
      end

      if (rollback_en_ex)
        history_reg <= {history_ex[HR_DEPTH_UB:1], !prediction_result_branch_failed};        
      else if (corrected_en)
        history_reg <= (history_reg << 1) | corrected_result;  
    end 
  end

////////////////////////////////////////////////////////////////////////////////////

  wire index_conflict;
  wire [INDEX_WIDTH_UB:0]index;
  wire [INDEX_WIDTH_UB:0]index_id;
  wire [INDEX_WIDTH_UB:0]WR_index2;
  wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]WR_data2;

  PHT #(
    .INDEX_WIDTH(INDEX_WIDTH), 
    .JUMP_STATUS_COUNTER_WIDTH(JUMP_STATUS_COUNTER_WIDTH),
    .JUMP_STATUS_COUNTER_INIT_VALUE(JUMP_STATUS_COUNTER_INIT_VALUE)
  ) prediction_table_inst(
    .clk(clk),
    .rst_n(rst_n),

    .RD_index(index),
    .RD_count(HP_count),

    .WR_en1(rollback_en_id && (!index_conflict)),
    .WR_index1(index_id),
    .WR_count1(HP_count_id),

    .WR_en2(rollback_en_ex || corrected_en),
    .WR_index2(WR_index2),
    .WR_count2(WR_data2)
  );

/////////////////////////////////////////////////////////////////////////////////////

  wire [INDEX_WIDTH_UB:0]index_rid_ex, index_nrid_ex;
  assign WR_index2 = rollback_en_ex ? (rollback_en_id ? index_rid_ex : index_nrid_ex) : index;
 
  parallel_unsig_comparator_eq #(
    .WIDTH(INDEX_WIDTH)
  ) rid_conflict_inst(
    .data1(index_id),
    .data2(index_rid_ex),
    .compare_result(index_conflict)
  );

  index_hash #(
    .HR_WIDTH(HR_WIDTH),
    .INDEX_WIDTH(INDEX_WIDTH)
  ) index_inst(
    .pc(pc),
    .hr(history_reg[HR_WIDTH - 1: 0]),
    .index(index)
  );
  index_hash #(
    .HR_WIDTH(HR_WIDTH),
    .INDEX_WIDTH(INDEX_WIDTH)
  ) index_id_inst(
    .pc(pc_id),
    .hr(history_reg[HR_WIDTH: 1]),
    .index(index_id)
  );
  index_hash #(
    .HR_WIDTH(HR_WIDTH),
    .INDEX_WIDTH(INDEX_WIDTH)
  ) index_ex_rollback_id_inst(
    .pc(pc_ex),
    .hr(history_reg[HR_WIDTH + 1: 2]),
    .index(index_rid_ex)
  );
  index_hash #(
    .HR_WIDTH(HR_WIDTH),
    .INDEX_WIDTH(INDEX_WIDTH)
  ) index_ex_no_rollback_id_inst(
    .pc(pc_ex),
    .hr(history_reg[HR_WIDTH: 1]),
    .index(index_nrid_ex)
  );

////////////////////////////////////////////////////////////////////////////////////

  wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]WR_data_corrected, WR_data_rollback_ex;
  no_overflow_adder #(
    .WIDTH(JUMP_STATUS_COUNTER_WIDTH)
  ) corrected_adder_inst(
    .A(HP_count),
    .B(corrected_result ? N_ONE : P_ONE),
    .PO(),
    .NO(),
    .result(WR_data_corrected)
  );
  no_overflow_adder #(
    .WIDTH(JUMP_STATUS_COUNTER_WIDTH)
  ) rollback_ex_adder_inst(
    .A(HP_count_ex),
    .B(prediction_result_branch_failed ? P_ONE : N_ONE),
    .PO(),
    .NO(),
    .result(WR_data_rollback_ex)
  );
  assign WR_data2 = rollback_en_ex ? WR_data_rollback_ex : WR_data_corrected;
endmodule


module index_hash #(
  parameter HR_WIDTH = 10,
  parameter INDEX_WIDTH = 13
)(
  input  [31:0]pc, 
  input  [HR_WIDTH - 1:0]hr,
  output [INDEX_WIDTH - 1:0]index
);
  localparam HR_WIDTH_UB = HR_WIDTH - 1;
  localparam INDEX_WIDTH_UB = INDEX_WIDTH - 1;

  generate
  if(HR_WIDTH >= INDEX_WIDTH) begin
    wire [HR_WIDTH_UB:0]once_result;
    assign once_result = hr ^ pc[HR_WIDTH + 1:2];

    if(HR_WIDTH == INDEX_WIDTH)
      assign index = once_result;
    else begin
      wire [HR_WIDTH_UB:0]double_result;
      assign index = double_result[INDEX_WIDTH_UB:0];      
      
      localparam SUB = HR_WIDTH - INDEX_WIDTH;
      localparam NUM = INDEX_WIDTH / SUB + (INDEX_WIDTH % SUB ? 1 : 0);

      genvar i;
      for(i = 0; i < NUM; i = i + 1) begin
        localparam lb = i * SUB;
        localparam ub = lb + SUB - 1;
        assign double_result[ub:lb] = once_result[ub:lb] ^ once_result[HR_WIDTH_UB:HR_WIDTH_UB - SUB + 1];
      end
    end
  end else begin
    localparam INDEX_PC_TOP_POSITION = INDEX_WIDTH - HR_WIDTH + 1;
    assign index = {pc[INDEX_PC_TOP_POSITION: 2], hr[HR_WIDTH_UB: 0]};
  end
  endgenerate
endmodule