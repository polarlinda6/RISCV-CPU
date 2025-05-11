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
	output [31:0]jalr_prediction_result,

	input  WR_ra_track_en,
	input  [4:0]WR_ra_track_data,
	output [4:0]ra_track
);

	localparam STACK_ADDR_WIDTH_UB = STACK_ADDR_WIDTH - 1;

	wire [STACK_ADDR_WIDTH_UB:0]offset;
	wire en, rollback_en_id, rollback_en_ex;

	reg [4:0]ra_track_reg;
	reg [31:0]jalr_prediction_result_reg;

	always @(posedge clk) begin
		if(!rst_n) begin
			ra_track_reg <= `ra;
			jalr_prediction_result_reg <= `zeroword;
		end	else if(pop) begin
			ra_track_reg <= ra_track;
			jalr_prediction_result_reg <= jalr_prediction_result;
		end
	end

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

/////////////////////////////////////////////////////////////////////////////////////

	wire WR_addr_data_en, WR_ra_data_en;
	assign WR_addr_data_en = push || (rollback_pop_id && rollback_push_ex);
	assign WR_ra_data_en   = WR_ra_track_en || WR_addr_data_en;

	circular_stack #(
		.WIDTH(32),
		.STACK_ADDR_WIDTH(STACK_ADDR_WIDTH),
		.INIT_VALUE(`zeroword)
	) addr_stack_inst(
		.clk(clk),
		.rst_n(rst_n),

		.WR_data_en(WR_addr_data_en),
		.din(push ? pc_add_4 : jalr_prediction_result_reg),

		.WR_offset_en(en || rollback_en_id || rollback_en_ex),
		.offset(offset),

		.dout(jalr_prediction_result)
	);	

	circular_stack #(
		.WIDTH(5),
		.STACK_ADDR_WIDTH(STACK_ADDR_WIDTH),
		.INIT_VALUE(`ra)
	) ra_track_stack_inst(
		.clk(clk),
		.rst_n(rst_n),

		.WR_data_en(WR_ra_data_en),
		.din(WR_ra_track_en ? WR_ra_track_data : push ? `ra : ra_track_reg),

		.WR_offset_en(en || rollback_en_id || rollback_en_ex),
		.offset(offset),

		.dout(ra_track)
	);	
endmodule


module circular_stack #(
	parameter WIDTH = 32,
	parameter STACK_ADDR_WIDTH = 4,
	parameter INIT_VALUE = `zeroword
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
				if (!rst_n) regs[i] <= INIT_VALUE;
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