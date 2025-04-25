module history_predictor #(
  parameter JUMP_STATUS_COUNTER_WIDTH = 2,
  parameter INDEX_HR_WIDTH = 5,
  parameter INDEX_PC_WIDTH = 3
)(
  input  clk,
  input  rst_n,  
  input  PL_stall,

  input  corrected_result,
  input  prediction_result_branch_failed,

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

  localparam HR_DEPTH = INDEX_HR_WIDTH + 2;
  localparam HR_DEPTH_UB = HR_DEPTH - 1;

  localparam INDEX_WIDTH = INDEX_HR_WIDTH + INDEX_PC_WIDTH;
  localparam INDEX_WIDTH_UB = INDEX_WIDTH - 1;
  localparam JUMP_STATUS_COUNTER_WIDTH_UB = JUMP_STATUS_COUNTER_WIDTH - 1;  

  localparam [JUMP_STATUS_COUNTER_WIDTH_UB:0]N_ONE  = {JUMP_STATUS_COUNTER_WIDTH{1'b1}};  
  localparam [JUMP_STATUS_COUNTER_WIDTH_UB:0]ZERO   = {JUMP_STATUS_COUNTER_WIDTH{1'b0}};  
  localparam [JUMP_STATUS_COUNTER_WIDTH_UB:0]P_ONE  = {ZERO[JUMP_STATUS_COUNTER_WIDTH_UB: 1], 1'b1};


  reg [JUMP_STATUS_COUNTER_WIDTH_UB:0]count_reg_id, count_reg_ex;
  reg [HR_DEPTH_UB:0]history_reg;

  assign HP_count_id = count_reg_id;
  assign HP_count_ex = count_reg_ex;  
  
////////////////////////////////////////////////////////////////////////////////

  always @(posedge clk)
  begin
    if (!rst_n)
      begin
        count_reg_id <= ZERO;
        count_reg_ex <= ZERO;
        history_reg <= {HR_DEPTH{1'b0}};
      end
    else
      begin
        if(!PL_stall) 
        begin   
          count_reg_id <= HP_count;
          count_reg_ex <= count_reg_id;
        end

        if (rollback_en_ex)
          history_reg <= history_reg >> (rollback_en_id ? 2 : 1);        
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

  prediction_table #(
    .INDEX_WIDTH(INDEX_WIDTH), 
    .JUMP_STATUS_COUNTER_WIDTH(JUMP_STATUS_COUNTER_WIDTH)
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

  wire [INDEX_WIDTH_UB:0]index_ex;

  localparam INDEX_PC_TOP_POSITION = INDEX_PC_WIDTH + 1;
  assign index    = {pc[INDEX_PC_TOP_POSITION: 2], history_reg[INDEX_HR_WIDTH - 1: 0]};
  assign index_id = {pc_id[INDEX_PC_TOP_POSITION: 2], history_reg[INDEX_HR_WIDTH: 1]};
  assign index_ex = {pc_ex[INDEX_PC_TOP_POSITION: 2], history_reg[INDEX_HR_WIDTH + 1: 2]};

  assign WR_index2 = rollback_en_ex ? index_ex : index;

  parallel_unsig_comparator_eq #(
    .WIDTH(INDEX_WIDTH)
  ) eq_inst(
    .data1(index_id),
    .data2(index_ex),
    .compare_result(index_conflict)
  );

//////////////////////////////////////////////////////////////////////////////////////

  wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]count_offset;
  assign count_offset = corrected_result ? N_ONE : P_ONE;

  wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]counter_offset_ex;
  assign count_offset_ex = prediction_result_branch_failed ? P_ONE : N_ONE;
  
  wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]A, B;
  assign A = rollback_en_ex ? HP_count_ex     : HP_count;
  assign B = rollback_en_ex ? count_offset_ex : count_offset;

  no_overflow_adder #(
    .WIDTH(JUMP_STATUS_COUNTER_WIDTH)
  ) adder_inst(
    .A(A),
    .B(B),
    .result(WR_data2)
  );
endmodule