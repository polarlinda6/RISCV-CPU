`include "define.v"

module ras #(
	parameter STACK_ADDR_WIDTH = 4
)(
	input  clk,
	input  rst_n,
	input  PL_flush,	
	input  prediction_en,
	
	input  jal, 
	input  jalr,
	input  Rd_is_ra,
	input  [31:0]pc_add_4,
	
	input  jal_id, 
	input  jalr_id,
	input  Rd_is_ra_id,
	input  Rs1_is_ra_id,

	output [31:0]jalr_pc_prediction
);

	localparam STACK_ADDR_WIDTH_UB = STACK_ADDR_WIDTH - 1;
	localparam [STACK_ADDR_WIDTH_UB:0]N_ONE = {STACK_ADDR_WIDTH{1'b1}};	
	localparam [STACK_ADDR_WIDTH_UB:0]ZERO  = {STACK_ADDR_WIDTH{1'b0}};
	localparam [STACK_ADDR_WIDTH_UB:0]P_ONE = {ZERO[STACK_ADDR_WIDTH_UB:1], 1'b1};


	wire push, rollback_pop, rollback_push;
	assign push          = (!PL_flush) && Rd_is_ra && (jal || jalr);
	assign rollback_pop  = PL_flush && Rd_is_ra_id && (jal_id || jalr_id);
	assign rollback_push = PL_flush && Rs1_is_ra_id && jalr_id;

	wire [3:0]offset;
	assign offset = push || rollback_push ? P_ONE :
	                (rollback_pop || (jalr && prediction_en)) ? N_ONE : ZERO;

	circular_stack #(
		.STACK_ADDR_WIDTH(STACK_ADDR_WIDTH)
	) ras_stack_inst(
		.clk(clk),
		.rst_n(rst_n),
		.push(push),
		.din(pc_add_4),
		.dout(jalr_pc_prediction),
		 
		.offset(offset)
	);	
endmodule


module circular_stack #(
	parameter STACK_ADDR_WIDTH = 4
)(
	input clk,
	input rst_n,

	input  push,
	input  [31:0]din,
	output [31:0]dout,

	input  [3:0] offset 
);

	localparam STACK_ADDR_WIDTH_UB = STACK_ADDR_WIDTH - 1;
	localparam STACK_DEPTH = 1 << STACK_ADDR_WIDTH;

	reg [STACK_ADDR_WIDTH_UB:0]stack_top_pointer;
	reg [31:0]regs[STACK_DEPTH - 1:0]; 

	assign dout = regs[stack_top_pointer];
/////////////////////////////////////////////////////////////////////////////  

	wire [STACK_ADDR_WIDTH_UB:0]stack_top_pointer_next;
	assign stack_top_pointer_next = stack_top_pointer + offset;
	

	integer i;
	always @(posedge clk) 
	begin
		if (!rst_n)
			begin
				stack_top_pointer <= {STACK_ADDR_WIDTH{1'b0}};
        for (i = 0; i < STACK_DEPTH; i = i + 1) regs[i] <= `zeroword;
			end			
		else 
			begin					
				stack_top_pointer <= stack_top_pointer_next;	
				if (push) regs[stack_top_pointer_next] <= din;
			end	
	end	
endmodule 