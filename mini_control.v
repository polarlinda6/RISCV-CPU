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

	input  MemRead_ex,
	input  MemRead_mem,

	output [1:0]Rs1_forward_signal,
	output [1:0]Rs2_forward_signal,
	
	input  B_type,
	output B_type_prediction_en,

	input  R_type,
	input  I_type,
	input  jal,
	input  jalr,
	input  jal_id,
	input  jalr_id,
	input  jalr_ex,
	input  PL_flush,
	input  PL_stall,

	input  [4:0]Rd,
	input  [4:0]Rs1_id,
	input  [4:0]ras_ra_track,

	output WR_ra_track_en,
	output ras_pop, 
	output ras_push,
	output ras_rollback_pop_id,
	output ras_rollback_push_id,
	output ras_rollback_push_ex,

	output jalr_prediction_en,	
	output PL_stall_inner
	);

  wire Rs1_hazard_id, Rs1_hazard_ex, Rs1_hazard_mem, Rs1_hazard_wb;
	wire Rs2_hazard_id, Rs2_hazard_ex, Rs2_hazard_mem, Rs2_hazard_wb;

	wire Rs1_hazard_ex_noload;			
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

/////////////////////////////////////////////////////////////////////////////////////

	wire Rd_is_ra, Rd_is_ra_id; 
	assign Rd_is_ra     = Rd == `ra;
	assign Rd_is_ra_id  = Rd_id == `ra;

	wire Rs1_is_ra, Rs1_is_ra_id;
	assign Rs1_is_ra    = Rs1 == `ra;
	assign Rs1_is_ra_id = Rs1_id == `ra;

	// assign PL_stall_inner     = jalr && (!Rs1_is_ra) && (Rs1_hazard_ex_noload || Rs1_hazard_mem_load);
	// assign jalr_prediction_en = jalr && Rs1_is_ra && (Rs1_hazard_id || Rs1_hazard_ex || Rs1_hazard_mem_load);

	// assign ras_pop  = (!PL_flush && !PL_stall && Rs1_is_ra && jalr);
	// assign ras_push = (!PL_flush && !PL_stall && Rd_is_ra && (jal || jalr));
	
	// assign ras_rollback_pop  = (PL_flush && Rd_is_ra_id && (jal_id || jalr_id));
	// assign ras_rollback_push = (PL_flush && Rs1_is_ra_id && jalr_id);


	// assign PL_stall_inner     = jalr &&  Rd_is_ra && (Rs1_hazard_ex_noload || Rs1_hazard_mem_load);
	// assign jalr_prediction_en = jalr && !Rd_is_ra && (Rs1_hazard_id || Rs1_hazard_ex || Rs1_hazard_mem_load);

	// assign ras_pop  = !PL_flush && !PL_stall && !Rd_is_ra && jalr;
	// assign ras_push = !PL_flush && !PL_stall &&  Rd_is_ra && (jal || jalr);
	
	// assign ras_rollback_pop_id  = PL_flush &&  Rd_is_ra_id && (jal_id || jalr_id);
	// assign ras_rollback_push_id = PL_flush && !Rd_is_ra_id && jalr_id;

	// assign ras_rollback_push_ex = PL_flush && jalr_ex;

	reg jalr_prediction_en_reg_id, jalr_prediction_en_reg_ex;
	wire Rs1_is_ra_track;
	assign Rs1_is_ra_track = Rs1 == ras_ra_track;

	assign PL_stall_inner     = jalr && !(Rs1_is_ra || Rs1_is_ra_track) && !Rs1_hazard_id && (Rs1_hazard_ex_noload || Rs1_hazard_mem_load);
	assign jalr_prediction_en = jalr &&  (Rs1_is_ra || Rs1_is_ra_track) && (Rs1_hazard_id || Rs1_hazard_ex || Rs1_hazard_mem_load);

	assign ras_pop  = !PL_flush && !(PL_stall || PL_stall_inner) && (Rs1_is_ra || Rs1_is_ra_track) && jalr;
	assign ras_push = !PL_flush && !(PL_stall || PL_stall_inner) && Rd_is_ra && (jal || jalr);
	
	assign ras_rollback_pop_id  = PL_flush && Rd_is_ra_id && (jal_id || jalr_id);
	assign ras_rollback_push_id = PL_flush && jalr_prediction_en_reg_id;

	assign ras_rollback_push_ex = PL_flush && jalr_prediction_en_reg_ex;

	
	assign WR_ra_track_en = (R_type || I_type) && Rs1_is_ra && (Rd != `zeroreg) && (ras_ra_track == `ra);



	always @(posedge clk) begin
		if(!rst_n) begin
			jalr_prediction_en_reg_id <= `zero;
			jalr_prediction_en_reg_ex <= `zero;
		end else if(!PL_stall) begin
			jalr_prediction_en_reg_id <= jalr_prediction_en;
			jalr_prediction_en_reg_ex <= jalr_prediction_en_reg_id;
		end
	end

////////////////////////////////////////////////////////////////////////////////////

	assign Rs1_hazard_id  = RegWrite_id && (Rd_id==Rs1);
	assign Rs1_hazard_ex  = RegWrite_ex && (Rd_ex==Rs1);
	assign Rs1_hazard_mem = RegWrite_mem && (Rd_mem==Rs1);
	assign Rs1_hazard_wb  = RegWrite_wb && (Rd_wb==Rs1);	

	assign Rs2_hazard_id  = RegWrite_id && (Rd_id==Rs2);
	assign Rs2_hazard_ex  = RegWrite_ex && (Rd_ex==Rs2);
	assign Rs2_hazard_mem = RegWrite_mem && (Rd_mem==Rs2);
	assign Rs2_hazard_wb  = RegWrite_wb && (Rd_wb==Rs2);	

	assign Rs1_hazard_ex_noload  = (!MemRead_ex) && Rs1_hazard_ex;

	assign Rs1_hazard_mem_load   = MemRead_mem && Rs1_hazard_mem;
	assign Rs1_hazard_mem_noload = (!MemRead_mem) && Rs1_hazard_mem;

	assign Rs2_hazard_mem_load   = MemRead_mem && Rs2_hazard_mem;
	assign Rs2_hazard_mem_noload = (!MemRead_mem) && Rs2_hazard_mem;
endmodule