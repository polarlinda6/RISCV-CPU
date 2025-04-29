module meta_predictor #(
  parameter JUMP_STATUS_COUNTER_WIDTH = 2,
  parameter STAT_COUNTER_WIDTH = 5,
  parameter STAT_COUNTER_CLEAR_BITS = STAT_COUNTER_WIDTH / 2 + (STAT_COUNTER_WIDTH % 2 ? 1 : 0),
  parameter [STAT_COUNTER_WIDTH - 1:0]SP_STAT_COUNTER_INIT_VALUE = 1 << STAT_COUNTER_CLEAR_BITS
)(
  input  clk,
  input  rst_n,
  input  PL_stall,
  
  input  corrected_result,
  input  prediction_result_id,
  input  prediction_result_ex,
  
  input  corrected_en,
  input  rollback_en_id,
  input  rollback_en_ex,


  input  beq,
  input  bne,
  input  blt,
  input  bge,
  input  bltu,
  input  bgeu,

  input  beq_id, 
  input  bne_id,
  input  blt_id,
  input  bge_id,
  input  bltu_id,
  input  bgeu_id,

  input  beq_ex, 
  input  bne_ex,
  input  blt_ex,
  input  bge_ex,
  input  bltu_ex,
  input  bgeu_ex,

  input  SP_prediction_result,
  input  SP_prediction_result_id,
  input  SP_prediction_result_ex,
  
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
  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]LHP_bgeu_count_ex,


  output prediction_result
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

  wire [2:0]SP_trend_count, LHP_trend_count, GHP_trend_count;  
  wire [2:0]SP_trend_count_id, LHP_trend_count_id, GHP_trend_count_id;
  wire [2:0]SP_trend_count_ex, LHP_trend_count_ex, GHP_trend_count_ex;
  wire [STAT_COUNTER_WIDTH_UB:0]SP_stat_count, LHP_stat_count, GHP_stat_count;
  wire [STAT_COUNTER_WIDTH_UB:0]SP_stat_count_id, LHP_stat_count_id, GHP_stat_count_id;
  wire [STAT_COUNTER_WIDTH_UB:0]SP_stat_count_ex, LHP_stat_count_ex, GHP_stat_count_ex;

/////////////////////////////////////////////////////////////////////////////////////////////////////

  localparam SP_TREND_STAT_COUNTER_INIT_VALUE = {3'b000, SP_STAT_COUNTER_INIT_VALUE};
  localparam LHP_GHP_TREND_STAT_COUNTER_INIT_VALUE = {3'b000, {STAT_COUNTER_WIDTH{1'b0}}};

   always @(posedge clk) 
  begin 
    if(!rst_n)
    begin  
      SP_trend_stat_counter_regs[5][1] <= SP_TREND_STAT_COUNTER_INIT_VALUE;
      SP_trend_stat_counter_regs[5][0] <= SP_TREND_STAT_COUNTER_INIT_VALUE;
      SP_trend_stat_counter_regs[4][1] <= SP_TREND_STAT_COUNTER_INIT_VALUE;
      SP_trend_stat_counter_regs[4][0] <= SP_TREND_STAT_COUNTER_INIT_VALUE;
      SP_trend_stat_counter_regs[3][1] <= SP_TREND_STAT_COUNTER_INIT_VALUE;
      SP_trend_stat_counter_regs[3][0] <= SP_TREND_STAT_COUNTER_INIT_VALUE;        
      SP_trend_stat_counter_regs[2][1] <= SP_TREND_STAT_COUNTER_INIT_VALUE;
      SP_trend_stat_counter_regs[2][0] <= SP_TREND_STAT_COUNTER_INIT_VALUE;
      SP_trend_stat_counter_regs[1][1] <= SP_TREND_STAT_COUNTER_INIT_VALUE;
      SP_trend_stat_counter_regs[1][0] <= SP_TREND_STAT_COUNTER_INIT_VALUE;
      SP_trend_stat_counter_regs[0][1] <= SP_TREND_STAT_COUNTER_INIT_VALUE;
      SP_trend_stat_counter_regs[0][0] <= SP_TREND_STAT_COUNTER_INIT_VALUE;
    end
  end 
  
  generate
    genvar i, j;
    for (i = 0; i < 6; i = i + 1)
    begin
      for(j = 0; j < JUMP_STATUS_COUNTER_CAPACITY; j = j + 1) 
      begin
        always @(posedge clk)
        begin
          if(!rst_n)
          begin
            LHP_trend_stat_counter_regs[i][j] <= LHP_GHP_TREND_STAT_COUNTER_INIT_VALUE;
            GHP_trend_stat_counter_regs[i][j] <= LHP_GHP_TREND_STAT_COUNTER_INIT_VALUE;
          end
        end
      end
    end
  endgenerate

/////////////////////////////////////////////////////////////////////////////////////////////////////

  wire clear_en1, clear_en2;
  wire WR_SP_stat_en1, WR_LHP_stat_en1, WR_GHP_stat_en1;
  wire WR_SP_stat_en2, WR_LHP_stat_en2, WR_GHP_stat_en2;
  wire WR_SP_trend_en1, WR_LHP_trend_en1, WR_GHP_trend_en1;
  wire wr_SP_trend_en2, WR_LHP_trend_en2, WR_GHP_trend_en2;
 
  wire [2:0]WR_addr1, WR_addr2;
  wire WR_SP_index1, WR_SP_index2;
  wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]WR_LHP_index1, WR_LHP_index2;
  wire [JUMP_STATUS_COUNTER_WIDTH_UB:0]WR_GHP_index1, WR_GHP_index2;

  wire [2:0]WR_SP_trend_count1, WR_SP_trend_count2;
  wire [2:0]WR_LHP_trend_count1, WR_LHP_trend_count2;
  wire [2:0]WR_GHP_trend_count1, WR_GHP_trend_count2;

  wire [STAT_COUNTER_WIDTH_UB:0]WR_SP_stat_count1, WR_SP_stat_count2;
  wire [STAT_COUNTER_WIDTH_UB:0]WR_LHP_stat_count1, WR_LHP_stat_count2;
  wire [STAT_COUNTER_WIDTH_UB:0]WR_GHP_stat_count1, WR_GHP_stat_count2;


  localparam STAT_COUNTER_CLEAR_BITS_UB = STAT_COUNTER_CLEAR_BITS - 1;
  localparam [STAT_COUNTER_CLEAR_BITS_UB:0]ZERO = {STAT_COUNTER_CLEAR_BITS{1'b0}};

  always @(posedge clk)
  begin
    if(rst_n)
    begin 
      if(clear_en1)
      begin
        SP_trend_stat_counter_regs[WR_addr1][1][STAT_COUNTER_CLEAR_BITS_UB:0]  <= ZERO;
        SP_trend_stat_counter_regs[WR_addr1][0][STAT_COUNTER_CLEAR_BITS_UB:0]  <= ZERO;
        LHP_trend_stat_counter_regs[WR_addr1][3][STAT_COUNTER_CLEAR_BITS_UB:0] <= ZERO;
        LHP_trend_stat_counter_regs[WR_addr1][2][STAT_COUNTER_CLEAR_BITS_UB:0] <= ZERO;
        LHP_trend_stat_counter_regs[WR_addr1][1][STAT_COUNTER_CLEAR_BITS_UB:0] <= ZERO;
        LHP_trend_stat_counter_regs[WR_addr1][0][STAT_COUNTER_CLEAR_BITS_UB:0] <= ZERO;
        GHP_trend_stat_counter_regs[WR_addr1][3][STAT_COUNTER_CLEAR_BITS_UB:0] <= ZERO;
        GHP_trend_stat_counter_regs[WR_addr1][2][STAT_COUNTER_CLEAR_BITS_UB:0] <= ZERO;
        GHP_trend_stat_counter_regs[WR_addr1][1][STAT_COUNTER_CLEAR_BITS_UB:0] <= ZERO;
        GHP_trend_stat_counter_regs[WR_addr1][0][STAT_COUNTER_CLEAR_BITS_UB:0] <= ZERO;
      end
      else
      begin
        if(WR_SP_stat_en1)  SP_trend_stat_counter_regs[WR_addr1][WR_SP_index1][STAT_COUNTER_CLEAR_BITS_UB:0]   <= WR_SP_stat_count1[STAT_COUNTER_CLEAR_BITS_UB:0];
        if(WR_LHP_stat_en1) LHP_trend_stat_counter_regs[WR_addr1][WR_LHP_index1][STAT_COUNTER_CLEAR_BITS_UB:0] <= WR_LHP_stat_count1[STAT_COUNTER_CLEAR_BITS_UB:0];
        if(WR_GHP_stat_en1) GHP_trend_stat_counter_regs[WR_addr1][WR_GHP_index1][STAT_COUNTER_CLEAR_BITS_UB:0] <= WR_GHP_stat_count1[STAT_COUNTER_CLEAR_BITS_UB:0];
      end

      if(clear_en2)
      begin
        SP_trend_stat_counter_regs[WR_addr2][1][STAT_COUNTER_CLEAR_BITS_UB:0]  <= ZERO;
        SP_trend_stat_counter_regs[WR_addr2][0][STAT_COUNTER_CLEAR_BITS_UB:0]  <= ZERO;
        LHP_trend_stat_counter_regs[WR_addr2][3][STAT_COUNTER_CLEAR_BITS_UB:0] <= ZERO;
        LHP_trend_stat_counter_regs[WR_addr2][2][STAT_COUNTER_CLEAR_BITS_UB:0] <= ZERO;
        LHP_trend_stat_counter_regs[WR_addr2][1][STAT_COUNTER_CLEAR_BITS_UB:0] <= ZERO;
        LHP_trend_stat_counter_regs[WR_addr2][0][STAT_COUNTER_CLEAR_BITS_UB:0] <= ZERO;
        GHP_trend_stat_counter_regs[WR_addr2][3][STAT_COUNTER_CLEAR_BITS_UB:0] <= ZERO;
        GHP_trend_stat_counter_regs[WR_addr2][2][STAT_COUNTER_CLEAR_BITS_UB:0] <= ZERO;
        GHP_trend_stat_counter_regs[WR_addr2][1][STAT_COUNTER_CLEAR_BITS_UB:0] <= ZERO;
        GHP_trend_stat_counter_regs[WR_addr2][0][STAT_COUNTER_CLEAR_BITS_UB:0] <= ZERO;
      end
      else 
      begin
        if(WR_SP_stat_en2)  SP_trend_stat_counter_regs[WR_addr2][WR_SP_index2][STAT_COUNTER_CLEAR_BITS_UB:0]   <= WR_SP_stat_count2[STAT_COUNTER_CLEAR_BITS_UB:0];
        if(WR_LHP_stat_en2) LHP_trend_stat_counter_regs[WR_addr2][WR_LHP_index2][STAT_COUNTER_CLEAR_BITS_UB:0] <= WR_LHP_stat_count2[STAT_COUNTER_CLEAR_BITS_UB:0];
        if(WR_GHP_stat_en2) GHP_trend_stat_counter_regs[WR_addr2][WR_GHP_index2][STAT_COUNTER_CLEAR_BITS_UB:0] <= WR_GHP_stat_count2[STAT_COUNTER_CLEAR_BITS_UB:0];
      end

      if(WR_SP_stat_en1)  SP_trend_stat_counter_regs[WR_addr1][WR_SP_index1][STAT_COUNTER_WIDTH_UB:STAT_COUNTER_CLEAR_BITS]   <= WR_SP_stat_count1[STAT_COUNTER_WIDTH_UB:STAT_COUNTER_CLEAR_BITS];
      if(WR_LHP_stat_en1) LHP_trend_stat_counter_regs[WR_addr1][WR_LHP_index1][STAT_COUNTER_WIDTH_UB:STAT_COUNTER_CLEAR_BITS] <= WR_LHP_stat_count1[STAT_COUNTER_WIDTH_UB:STAT_COUNTER_CLEAR_BITS];
      if(WR_GHP_stat_en1) GHP_trend_stat_counter_regs[WR_addr1][WR_GHP_index1][STAT_COUNTER_WIDTH_UB:STAT_COUNTER_CLEAR_BITS] <= WR_GHP_stat_count1[STAT_COUNTER_WIDTH_UB:STAT_COUNTER_CLEAR_BITS];
      if(WR_SP_stat_en2)  SP_trend_stat_counter_regs[WR_addr2][WR_SP_index2][STAT_COUNTER_WIDTH_UB:STAT_COUNTER_CLEAR_BITS]   <= WR_SP_stat_count2[STAT_COUNTER_WIDTH_UB:STAT_COUNTER_CLEAR_BITS];
      if(WR_LHP_stat_en2) LHP_trend_stat_counter_regs[WR_addr2][WR_LHP_index2][STAT_COUNTER_WIDTH_UB:STAT_COUNTER_CLEAR_BITS] <= WR_LHP_stat_count2[STAT_COUNTER_WIDTH_UB:STAT_COUNTER_CLEAR_BITS];
      if(WR_GHP_stat_en2) GHP_trend_stat_counter_regs[WR_addr2][WR_GHP_index2][STAT_COUNTER_WIDTH_UB:STAT_COUNTER_CLEAR_BITS] <= WR_GHP_stat_count2[STAT_COUNTER_WIDTH_UB:STAT_COUNTER_CLEAR_BITS];

      if(WR_SP_trend_en1)  SP_trend_stat_counter_regs[WR_addr1][WR_SP_index1][2 + STAT_COUNTER_WIDTH:STAT_COUNTER_WIDTH]   <= WR_SP_trend_count1;
      if(WR_LHP_trend_en1) LHP_trend_stat_counter_regs[WR_addr1][WR_LHP_index1][2 + STAT_COUNTER_WIDTH:STAT_COUNTER_WIDTH] <= WR_LHP_trend_count1;
      if(WR_GHP_trend_en1) GHP_trend_stat_counter_regs[WR_addr1][WR_GHP_index1][2 + STAT_COUNTER_WIDTH:STAT_COUNTER_WIDTH] <= WR_GHP_trend_count1;
      if(WR_SP_trend_en2)  SP_trend_stat_counter_regs[WR_addr2][WR_SP_index2][2 + STAT_COUNTER_WIDTH:STAT_COUNTER_WIDTH]   <= WR_SP_trend_count2;
      if(WR_LHP_trend_en2) LHP_trend_stat_counter_regs[WR_addr2][WR_LHP_index2][2 + STAT_COUNTER_WIDTH:STAT_COUNTER_WIDTH] <= WR_LHP_trend_count2;
      if(WR_GHP_trend_en2) GHP_trend_stat_counter_regs[WR_addr2][WR_GHP_index2][2 + STAT_COUNTER_WIDTH:STAT_COUNTER_WIDTH] <= WR_GHP_trend_count2;
    end
  end

  prediction_writer #(
    .JUMP_STATUS_COUNTER_WIDTH(JUMP_STATUS_COUNTER_WIDTH),
    .STAT_COUNTER_WIDTH(STAT_COUNTER_WIDTH)
  ) prediction_writer_inst(
    .clk(clk),
    .rst_n(rst_n),
    .PL_stall(PL_stall),

    .corrected_result(corrected_result),    
    .prediction_result_id(prediction_result_id),
    .prediction_result_ex(prediction_result_ex),

    .corrected_en(corrected_en),
    .rollback_en_id(rollback_en_id),
    .rollback_en_ex(rollback_en_ex),


    .addr(addr),
    .addr_id(addr_id),
    .addr_ex(addr_ex),

    .SP_prediction_result(SP_prediction_result),
    .SP_prediction_result_id(SP_prediction_result_id),
    .SP_prediction_result_ex(SP_prediction_result_ex),

    .LHP_count(LHP_count),
    .LHP_count_id(LHP_count_id),
    .LHP_count_ex(LHP_count_ex),

    .GHP_count(GHP_count),
    .GHP_count_id(GHP_count_id),
    .GHP_count_ex(GHP_count_ex),

    .SP_stat_count(SP_stat_count),
    .SP_stat_count_id(SP_stat_count_id),
    .SP_stat_count_ex(SP_stat_count_ex),

    .LHP_stat_count(LHP_stat_count),
    .LHP_stat_count_id(LHP_stat_count_id),
    .LHP_stat_count_ex(LHP_stat_count_ex),

    .GHP_stat_count(GHP_stat_count),
    .GHP_stat_count_id(GHP_stat_count_id),
    .GHP_stat_count_ex(GHP_stat_count_ex),

    .SP_trend_count(SP_trend_count),
    .SP_trend_count_id(SP_trend_count_id),
    .SP_trend_count_ex(SP_trend_count_ex),

    .LHP_trend_count(LHP_trend_count),
    .LHP_trend_count_id(LHP_trend_count_id),
    .LHP_trend_count_ex(LHP_trend_count_ex),

    .GHP_trend_count(GHP_trend_count),
    .GHP_trend_count_id(GHP_trend_count_id),
    .GHP_trend_count_ex(GHP_trend_count_ex),


    .clear_en1(clear_en1),
    .clear_en2(clear_en2),

    .WR_SP_stat_en1(WR_SP_stat_en1),
    .WR_LHP_stat_en1(WR_LHP_stat_en1),
    .WR_GHP_stat_en1(WR_GHP_stat_en1),

    .WR_SP_stat_en2(WR_SP_stat_en2),
    .WR_LHP_stat_en2(WR_LHP_stat_en2),
    .WR_GHP_stat_en2(WR_GHP_stat_en2),

    .WR_SP_trend_en1(WR_SP_trend_en1),
    .WR_LHP_trend_en1(WR_LHP_trend_en1),
    .WR_GHP_trend_en1(WR_GHP_trend_en1),

    .WR_SP_trend_en2(WR_SP_trend_en2),
    .WR_LHP_trend_en2(WR_LHP_trend_en2),
    .WR_GHP_trend_en2(WR_GHP_trend_en2),

    .WR_addr1(WR_addr1),
    .WR_addr2(WR_addr2),

    .WR_SP_index1(WR_SP_index1),
    .WR_SP_index2(WR_SP_index2),    
    .WR_LHP_index1(WR_LHP_index1),
    .WR_LHP_index2(WR_LHP_index2),
    .WR_GHP_index1(WR_GHP_index1),
    .WR_GHP_index2(WR_GHP_index2),

    .WR_SP_trend_count1(WR_SP_trend_count1),
    .WR_SP_trend_count2(WR_SP_trend_count2),
    .WR_LHP_trend_count1(WR_LHP_trend_count1),
    .WR_LHP_trend_count2(WR_LHP_trend_count2),
    .WR_GHP_trend_count1(WR_GHP_trend_count1),
    .WR_GHP_trend_count2(WR_GHP_trend_count2),

    .WR_SP_stat_count1(WR_SP_stat_count1),
    .WR_SP_stat_count2(WR_SP_stat_count2),
    .WR_LHP_stat_count1(WR_LHP_stat_count1),
    .WR_LHP_stat_count2(WR_LHP_stat_count2),
    .WR_GHP_stat_count1(WR_GHP_stat_count1),
    .WR_GHP_stat_count2(WR_GHP_stat_count2)
  );

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
    .STAT_COUNTER_WIDTH(STAT_COUNTER_WIDTH)
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

//////////////////////////////////////////////////////////////////////////////////////////////////////  

  wire [3 + STAT_COUNTER_WIDTH_UB:0]SP_trend_stat_count, LHP_trend_stat_count, GHP_trend_stat_count;
  assign SP_trend_stat_count  = SP_trend_stat_counter_regs[addr][SP_prediction_result];
  assign LHP_trend_stat_count = LHP_trend_stat_counter_regs[addr][LHP_count];
  assign GHP_trend_stat_count = GHP_trend_stat_counter_regs[addr][GHP_count];

  assign SP_stat_count  = SP_trend_stat_count [STAT_COUNTER_WIDTH_UB:0];
  assign LHP_stat_count = LHP_trend_stat_count[STAT_COUNTER_WIDTH_UB:0];
  assign GHP_stat_count = GHP_trend_stat_count[STAT_COUNTER_WIDTH_UB:0];

  assign SP_trend_count  = SP_trend_stat_count [2 + STAT_COUNTER_WIDTH:STAT_COUNTER_WIDTH];
  assign LHP_trend_count = LHP_trend_stat_count[2 + STAT_COUNTER_WIDTH:STAT_COUNTER_WIDTH];
  assign GHP_trend_count = GHP_trend_stat_count[2 + STAT_COUNTER_WIDTH:STAT_COUNTER_WIDTH];


  wire [3 + STAT_COUNTER_WIDTH_UB:0]SP_trend_stat_count_id, LHP_trend_stat_count_id, GHP_trend_stat_count_id;
  assign SP_trend_stat_count_id  = SP_trend_stat_counter_regs[addr][SP_prediction_result_id];
  assign LHP_trend_stat_count_id = LHP_trend_stat_counter_regs[addr][LHP_count_id];
  assign GHP_trend_stat_count_id = GHP_trend_stat_counter_regs[addr][GHP_count_id];

  assign SP_stat_count_id  = SP_trend_stat_count_id [STAT_COUNTER_WIDTH_UB:0];
  assign LHP_stat_count_id = LHP_trend_stat_count_id[STAT_COUNTER_WIDTH_UB:0];
  assign GHP_stat_count_id = GHP_trend_stat_count_id[STAT_COUNTER_WIDTH_UB:0];

  assign SP_trend_count_id  = SP_trend_stat_count_id [2 + STAT_COUNTER_WIDTH:STAT_COUNTER_WIDTH];
  assign LHP_trend_count_id = LHP_trend_stat_count_id[2 + STAT_COUNTER_WIDTH:STAT_COUNTER_WIDTH];
  assign GHP_trend_count_id = GHP_trend_stat_count_id[2 + STAT_COUNTER_WIDTH:STAT_COUNTER_WIDTH];


  wire [3 + STAT_COUNTER_WIDTH_UB:0]SP_trend_stat_count_ex, LHP_trend_stat_count_ex, GHP_trend_stat_count_ex;
  assign SP_trend_stat_count_ex  = SP_trend_stat_counter_regs[addr][SP_prediction_result_ex];
  assign LHP_trend_stat_count_ex = LHP_trend_stat_counter_regs[addr][LHP_count_ex];
  assign GHP_trend_stat_count_ex = GHP_trend_stat_counter_regs[addr][GHP_count_ex];
 
  assign SP_stat_count_ex  = SP_trend_stat_count_ex [STAT_COUNTER_WIDTH_UB:0];
  assign LHP_stat_count_ex = LHP_trend_stat_count_ex[STAT_COUNTER_WIDTH_UB:0];
  assign GHP_stat_count_ex = GHP_trend_stat_count_ex[STAT_COUNTER_WIDTH_UB:0];

  assign SP_trend_count_ex  = SP_trend_stat_count_ex [2 + STAT_COUNTER_WIDTH:STAT_COUNTER_WIDTH];
  assign LHP_trend_count_ex = LHP_trend_stat_count_ex[2 + STAT_COUNTER_WIDTH:STAT_COUNTER_WIDTH];
  assign GHP_trend_count_ex = GHP_trend_stat_count_ex[2 + STAT_COUNTER_WIDTH:STAT_COUNTER_WIDTH];

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
  ) addr_mux6_inst(
    .data({BEQ_ADDR, BNE_ADDR, BLT_ADDR, BGE_ADDR, BLTU_ADDR, BGEU_ADDR}),
    .signal({beq, bne, blt, bge, bltu, bgeu}),
    .dout(addr)
  );
  parallel_mux #(
    .WIDTH(3),
    .MUX_QUANTITY(6)
  ) addr_id_mux6_inst(
    .data({BEQ_ADDR, BNE_ADDR, BLT_ADDR, BGE_ADDR, BLTU_ADDR, BGEU_ADDR}),
    .signal({beq_id, bne_id, blt_id, bge_id, bltu_id, bgeu_id}),
    .dout(addr_id)
  );  
  parallel_mux #(
    .WIDTH(3),
    .MUX_QUANTITY(6)
  ) addr_ex_mux6_inst(
    .data({BEQ_ADDR, BNE_ADDR, BLT_ADDR, BGE_ADDR, BLTU_ADDR, BGEU_ADDR}),
    .signal({beq_ex, bne_ex, blt_ex, bge_ex, bltu_ex, bgeu_ex}),
    .dout(addr_ex)
  );


  parallel_mux #(
    .WIDTH(JUMP_STATUS_COUNTER_WIDTH),
    .MUX_QUANTITY(6)
  ) count_mux6_inst(
    .data({LHP_beq_count, LHP_bne_count, LHP_blt_count, LHP_bge_count, LHP_bltu_count, LHP_bgeu_count}),
    .signal({beq, bne, blt, bge, bltu, bgeu}),
    .dout(LHP_count)
  );
  parallel_mux #(
    .WIDTH(JUMP_STATUS_COUNTER_WIDTH),
    .MUX_QUANTITY(6)
  ) count_id_mux6_inst(
    .data({LHP_beq_count_id, LHP_bne_count_id, LHP_blt_count_id, LHP_bge_count_id, LHP_bltu_count_id, LHP_bgeu_count_id}),
    .signal({beq_id, bne_id, blt_id, bge_id, bltu_id, bgeu_id}),
    .dout(LHP_count_id)
  );
  parallel_mux #(
    .WIDTH(JUMP_STATUS_COUNTER_WIDTH),
    .MUX_QUANTITY(6)
  ) count_ex_mux6_inst(
    .data({LHP_beq_count_ex, LHP_bne_count_ex, LHP_blt_count_ex, LHP_bge_count_ex, LHP_bltu_count_ex, LHP_bgeu_count_ex}),
    .signal({beq_ex, bne_ex, blt_ex, bge_ex, bltu_ex, bgeu_ex}),
    .dout(LHP_count_ex)
  );
endmodule