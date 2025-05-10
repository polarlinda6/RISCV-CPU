`include "define.v"

module RAS #(
	parameter STACK_ADDR_WIDTH = 4
)(
	input  clk,
	input  rst_n,

	input  pop, 
	input  push,
	input  rollback_pop_id,
	input  rollback_push_id,
	input  rollback_push_ex,

	input  [31:0]pc_add_4,
	output [31:0]jalr_pc_prediction

	// input  
	// input  [4:0]Rid_addr_track_i,
	// output [4:0]Rid_addr_track_o
);

	localparam STACK_ADDR_WIDTH_UB = STACK_ADDR_WIDTH - 1;

	wire [STACK_ADDR_WIDTH_UB:0]offset;
	wire en, rollback_en_id, rollback_en_ex;


	circular_stack #(
		.WIDTH(32),
		.STACK_ADDR_WIDTH(STACK_ADDR_WIDTH)
	) addr_stack_inst(
		.clk(clk),
		.rst_n(rst_n),

		.WR_data_en(push),
		.din(pc_add_4),

		.WR_offset_en(en || rollback_en_id || rollback_en_ex),
		.offset(offset),

		.dout(jalr_pc_prediction)
	);	

	// circular_stack #(
	// 	.WIDTH(5),
	// 	.STACK_ADDR_WIDTH(STACK_ADDR_WIDTH)
	// ) addr_track_stack_inst(
	// 	.clk(clk),
	// 	.rst_n(rst_n),

	// 	.WR_data_en(push || rollback_push),
	// 	.din(addr_track),
		
	// 	.WR_offset_en((push != pop) || (rollback_push != rollback_pop)),
	// 	.offset(offset),
				
	// 	.dout(jalr_pc_prediction)
	// );	

	// always @(posedge clk) begin
	// 	if(!rst_n) 
	// 		jalr_pc_prediction_reg <= `zeroword;
	// 	else if(pop)
	// 		jalr_pc_prediction_reg <= jalr_pc_prediction;
	// end

////////////////////////////////////////////////////////////////////////////////

	assign en             = pop || push;
	assign rollback_en_id = rollback_pop_id || rollback_push_id;
	assign rollback_en_ex = rollback_push_ex;

////////////////////////////////////////////////////////////////////////////////

	localparam [STACK_ADDR_WIDTH_UB:0]ZERO  = {STACK_ADDR_WIDTH{1'b0}};
	localparam [STACK_ADDR_WIDTH_UB:0]N_ONE = {STACK_ADDR_WIDTH{1'b1}};	
	localparam [STACK_ADDR_WIDTH_UB:0]P_ONE = {{STACK_ADDR_WIDTH_UB{1'b0}}, 1'b1};
	localparam [STACK_ADDR_WIDTH_UB:0]P_TWO = {{(STACK_ADDR_WIDTH_UB-1){1'b0}}, 2'b10};

	wire ZERO_signal, N_ONE_signal, P_ONE_signal, P_TWO_signal;
	assign ZERO_signal  = rollback_pop_id && rollback_push_ex;
	assign N_ONE_signal = pop  || (!rollback_en_ex && rollback_pop_id);
	assign P_ONE_signal = push || (!rollback_en_ex && rollback_push_id) || (!rollback_en_id && rollback_push_ex);
	assign P_TWO_signal = rollback_push_id && rollback_push_ex; 

	parallel_mux #(
		.WIDTH(STACK_ADDR_WIDTH),
		.MUX_QUANTITY(4)
	) offset_mux4_inst(
		.din({ZERO, N_ONE, P_ONE, P_TWO}),
		.signal({ZERO_signal, N_ONE_signal, P_ONE_signal, P_TWO_signal}),
		.dout(offset)
	);
endmodule


module circular_stack #(
	parameter WIDTH = 32,
	parameter STACK_ADDR_WIDTH = 4
)(
	input clk,
	input rst_n,

	input  WR_data_en,
	input  [WIDTH - 1:0]din,

	input  WR_offset_en,
	input  [STACK_ADDR_WIDTH - 1:0]offset,

	output [WIDTH - 1:0]dout
);

	localparam STACK_ADDR_WIDTH_UB = STACK_ADDR_WIDTH - 1;
	localparam STACK_DEPTH = 1 << STACK_ADDR_WIDTH;

	reg [STACK_ADDR_WIDTH_UB:0]stack_top_pointer;
	reg [WIDTH - 1:0]regs[STACK_DEPTH - 1:0]; 

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