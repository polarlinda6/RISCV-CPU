`include "define.v"

module RAS #(
	parameter STACK_ADDR_WIDTH = 4
)(
	input  clk,
	input  rst_n,

	input  pop, 
	input  push,
	input  rollback_pop,
	input  rollback_push,

	input  [31:0]pc_add_4,
	output [31:0]jalr_pc_prediction
);

	localparam STACK_ADDR_WIDTH_UB = STACK_ADDR_WIDTH - 1;
	localparam [STACK_ADDR_WIDTH_UB:0]N_ONE = {STACK_ADDR_WIDTH{1'b1}};	
	localparam [STACK_ADDR_WIDTH_UB:0]P_ONE = {{STACK_ADDR_WIDTH_UB{1'b0}}, 1'b1};

	wire [STACK_ADDR_WIDTH_UB:0]offset;
	assign offset = push || rollback_push ? P_ONE : N_ONE;

	circular_stack #(
		.STACK_ADDR_WIDTH(STACK_ADDR_WIDTH)
	) ras_stack_inst(
		.clk(clk),
		.rst_n(rst_n),

		.WR_data_en(push),
		.din(pc_add_4),
		
		.WR_offset_en((push != pop) || (rollback_push != rollback_pop)),
		.offset(offset),
				
		.dout(jalr_pc_prediction)
	);	
endmodule


module circular_stack #(
	parameter STACK_ADDR_WIDTH = 4
)(
	input clk,
	input rst_n,

	input  WR_data_en,
	input  [31:0]din,

	input  WR_offset_en,
	input  [STACK_ADDR_WIDTH - 1:0]offset,

	output [31:0]dout
);

	localparam STACK_ADDR_WIDTH_UB = STACK_ADDR_WIDTH - 1;
	localparam STACK_DEPTH = 1 << STACK_ADDR_WIDTH;

	reg [STACK_ADDR_WIDTH_UB:0]stack_top_pointer;
	reg [31:0]regs[STACK_DEPTH - 1:0]; 

	assign dout = regs[stack_top_pointer];
	
	generate
		genvar i;
		for(i = 0; i < STACK_DEPTH; i = i + 1) begin
			always @(posedge clk) begin
				if (!rst_n) regs[i] <= `zeroword;
			end
		end
	endgenerate

/////////////////////////////////////////////////////////////////////////////  

	wire [STACK_ADDR_WIDTH_UB:0]stack_top_pointer_next;
	assign stack_top_pointer_next = WR_offset_en ? stack_top_pointer + offset : stack_top_pointer;

	always @(posedge clk) 
	begin
		if (!rst_n)
			begin
				stack_top_pointer <= {STACK_ADDR_WIDTH{1'b0}};
			end			
		else 
			begin					
				stack_top_pointer <= stack_top_pointer_next;	
				if (WR_data_en) regs[stack_top_pointer_next] <= din;
			end	
	end	
endmodule 