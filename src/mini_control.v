`include "define.v"

module mini_control(
	input  clk,
	input  rst_n,

	input  [4:0]Rs1,
	input  [4:0]Rs2,

	input  [4:0]Rd_id,
	input  [4:0]Rd_ex,
	input  [4:0]Rd_mem,
	input  [4:0]Rd_wb,

	input  RegWrite_id,
	input  RegWrite_ex,
	input  RegWrite_mem,
	input  RegWrite_wb,

	input  MemRead_id,
	input  MemRead_ex,
	input  MemRead_mem,

	output [1:0]Rs1_forward_signal,
	output [1:0]Rs2_forward_signal,
	
	input  B_type,
	output B_type_prediction_en,


	input  jal,
	input  jalr,
	input  jal_id,
	input  jalr_id,
	input  PL_flush,
	input  PL_stall_ex,

	input  [4:0]Rd,
	input  [2:0]func3,
	input  [31:0]imme,
	input  I_type,
	input  forwardA_data_eq_jalr_prediction_result,

	input  [4:0]RAS_ra_track,
	output WR_ra_track_en,
	output [4:0]WR_ra_track_data,

	output RAS_pop, 
	output RAS_push,
	output RAS_rollback_pop_id,
	output RAS_rollback_push_id,
	output RAS_rollback_push_ex,

	output jalr_prediction_en,	
	output PL_stall_if
	);

  wire Rs1_hazard_id, Rs1_hazard_ex, Rs1_hazard_mem, Rs1_hazard_wb;
	wire Rs2_hazard_id, Rs2_hazard_ex, Rs2_hazard_mem, Rs2_hazard_wb;

	wire Rs1_hazard_id_load;
	wire Rs1_hazard_ex_load, Rs1_hazard_ex_noload;			
	wire Rs1_hazard_mem_load, Rs1_hazard_mem_noload; 
	wire Rs2_hazard_mem_load, Rs2_hazard_mem_noload;

///////////////////////////////////////////////////////////////////////////////////

	assign Rs1_forward_signal[0]= Rs1_hazard_wb;
	assign Rs1_forward_signal[1]= Rs1_hazard_mem_noload;

	assign Rs2_forward_signal[0]= Rs2_hazard_wb;
	assign Rs2_forward_signal[1]= Rs2_hazard_mem_noload;
	
	assign B_type_prediction_en = B_type && (Rs1_hazard_id || Rs2_hazard_id || 
	                                         Rs1_hazard_ex || Rs2_hazard_ex ||
																	         Rs1_hazard_mem_load || Rs2_hazard_mem_load);

////////////////////////////////////////////////////////////////////////////////////

	assign Rs1_hazard_id  = RegWrite_id  && (Rd_id==Rs1);
	assign Rs1_hazard_ex  = RegWrite_ex  && (Rd_ex==Rs1);
	assign Rs1_hazard_mem = RegWrite_mem && (Rd_mem==Rs1);
	assign Rs1_hazard_wb  = RegWrite_wb  && (Rd_wb==Rs1);	

	assign Rs2_hazard_id  = RegWrite_id  && (Rd_id==Rs2);
	assign Rs2_hazard_ex  = RegWrite_ex  && (Rd_ex==Rs2);
	assign Rs2_hazard_mem = RegWrite_mem && (Rd_mem==Rs2);
	assign Rs2_hazard_wb  = RegWrite_wb  && (Rd_wb==Rs2);	


	assign Rs1_hazard_id_load    = MemRead_id && Rs1_hazard_id;

	assign Rs1_hazard_ex_load    = MemRead_ex && Rs1_hazard_ex;
	assign Rs1_hazard_ex_noload  = (!MemRead_ex) && Rs1_hazard_ex;

	assign Rs1_hazard_mem_load   = MemRead_mem && Rs1_hazard_mem;
	assign Rs1_hazard_mem_noload = (!MemRead_mem) && Rs1_hazard_mem;

	assign Rs2_hazard_mem_load   = MemRead_mem && Rs2_hazard_mem;
	assign Rs2_hazard_mem_noload = (!MemRead_mem) && Rs2_hazard_mem;

///////////////////////////////////////////////////////////////////////////////////////	
	
	reg  RAS_pop_reg_id, RAS_pop_reg_ex;	

	wire PL_allow;
	wire Rd_is_ra, Rd_is_ra_id; 

	assign RAS_pop  = PL_allow && (jalr_prediction_en || forwardA_data_eq_jalr_prediction_result) && jalr;
	assign RAS_push = PL_allow && Rd_is_ra && (jal || jalr);
	
	assign RAS_rollback_pop_id  = PL_flush && Rd_is_ra_id && (jal_id || jalr_id);
	assign RAS_rollback_push_id = PL_flush && RAS_pop_reg_id;

	assign RAS_rollback_push_ex = PL_flush && RAS_pop_reg_ex;

////////////////////////////////////////////////////////////////////////////////////////

	assign Rd_is_ra    = Rd == `ra;
	assign Rd_is_ra_id = Rd_id == `ra;
	assign PL_allow    = !PL_flush && !PL_stall_ex && !PL_stall_if;

	always @(posedge clk) begin
		if(!rst_n) begin
			RAS_pop_reg_id <= `zero;
			RAS_pop_reg_ex <= `zero;
		end else if(!PL_stall_ex) begin
			RAS_pop_reg_id <= RAS_pop;
			RAS_pop_reg_ex <= RAS_pop_reg_id;
		end
	end

/////////////////////////////////////////////////////////////////////////////////////

	wire I_imme_is_zero;	
	wire Rs1_no_ra,	Rs1_is_ra;


	wire RAS_hit;	
	assign PL_stall_if        = jalr && !RAS_hit && !Rs1_hazard_id && (Rs1_hazard_ex_noload || Rs1_hazard_mem_load);
	assign jalr_prediction_en = jalr &&  RAS_hit && (Rs1_hazard_id || Rs1_hazard_ex || Rs1_hazard_mem_load);

	wire compliant_return, hit_track_mv;		
	assign compliant_return = (Rd == `zeroreg) && Rs1_is_ra && I_imme_is_zero; //jalr x0, ra, 0          
	assign hit_track_mv     = (Rs1 == RAS_ra_track) && Rs1_no_ra;              //jalr Rd, RAS_ra_track, imme
	assign RAS_hit          = compliant_return || hit_track_mv;


	wire RAS_track_mv;
	assign WR_ra_track_en   = RAS_track_mv;
	assign WR_ra_track_data = Rd;	

	wire mv;
	assign mv           = I_type && (func3==3'b000) && I_imme_is_zero; //addi Rd, Rs1, 0
	assign RAS_track_mv = mv && Rs1_is_ra;                             //mv Rd, ra

/////////////////////////////////////////////////////////////////////////////////////////

	wire I_imme_no_zero;
	assign I_imme_is_zero = !I_imme_no_zero;
	large_fan_in_or #(
		.WIDTH(1),
		.OR_QUANTITY(12)
	) no_zero_imme_inst(
		.din(imme[11:0]),
		.dout(I_imme_no_zero)
	);	
	
	assign Rs1_no_ra = Rs1 != `ra;
	assign Rs1_is_ra = !Rs1_no_ra;
endmodule