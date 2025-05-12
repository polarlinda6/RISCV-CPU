`include "define.v"

module PHT #(
  parameter INDEX_WIDTH = 8,
  parameter JUMP_STATUS_COUNTER_WIDTH = 2,
  parameter [JUMP_STATUS_COUNTER_WIDTH - 1: 0]JUMP_STATUS_COUNTER_INIT_VALUE = 0
)(
	input  clk,
	input  rst_n,

  input  [INDEX_WIDTH - 1:0]RD_index,
  output [JUMP_STATUS_COUNTER_WIDTH - 1:0]RD_count,

  input  WR_en1,  
  input  [INDEX_WIDTH - 1:0]WR_index1,
  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]WR_count1,

  input  WR_en2,
  input  [INDEX_WIDTH - 1:0]WR_index2,
  input  [JUMP_STATUS_COUNTER_WIDTH - 1:0]WR_count2
);

  localparam TABLE_DEPTH = 1 << INDEX_WIDTH;
  localparam TABLE_DEPTH_UB = TABLE_DEPTH - 1;
  localparam JUMP_STATUS_COUNTER_WIDTH_UB = JUMP_STATUS_COUNTER_WIDTH - 1;

  reg [JUMP_STATUS_COUNTER_WIDTH_UB:0]regs[TABLE_DEPTH_UB:0];  
  assign RD_count = regs[RD_index];


  generate
    genvar i;
    for (i = 0; i < TABLE_DEPTH; i = i + 1) 
    begin
      always @(posedge clk)
      begin
        if(!rst_n) regs[i] <= JUMP_STATUS_COUNTER_INIT_VALUE;
      end
    end
  endgenerate


  always @(posedge clk)
  begin
    if(rst_n)
    begin
      if(WR_en1) regs[WR_index1] <= WR_count1;
      if(WR_en2) regs[WR_index2] <= WR_count2;
    end
  end
endmodule