`include "define.v"

module prediction_table #(
  parameter INDEX_WIDTH = 8,
  parameter JUMP_STATUS_COUNTER_WIDTH = 2 
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


  reg [JUMP_STATUS_COUNTER_WIDTH - 1:0]regs[TABLE_DEPTH - 1:0];  
  assign RD_count = regs[RD_index];


	integer i;
  initial begin
    for (i = 0; i < JUMP_STATUS_COUNTER_WIDTH; i = i + 1) regs[i]=`zeroword;  
  end

  always @(posedge clk)
  begin
    if(rst_n) 
    begin
      if(WR_en1) regs[WR_index1] <= WR_count1;
      if(WR_en2) regs[WR_index2] <= WR_count2;
    end
  end
endmodule