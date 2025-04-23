`include "define.v"

module mini_control(
	input  jalr,
	input  B_type,
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


	output PL_stall_inner,	
	output jalr_prediction_en,
	output B_type_prediction_en,
	output [1:0]Rs1_forward_signal,
	output [1:0]Rs2_forward_signal
	);

	wire Rs1_is_ra;
	assign Rs1_is_ra = Rs1 == `ra;

  wire Rs1_hazard_id, Rs1_hazard_ex, Rs1_hazard_mem, Rs1_hazard_wb;
	assign Rs1_hazard_id=  RegWrite_id && (Rd_id==Rs1);
	assign Rs1_hazard_ex=  RegWrite_ex && (Rd_ex==Rs1);
	assign Rs1_hazard_mem= RegWrite_mem && (Rd_mem==Rs1);
	assign Rs1_hazard_wb=  RegWrite_wb && (Rd_wb==Rs1);	

	wire Rs2_hazard_id, Rs2_hazard_ex, Rs2_hazard_mem, Rs2_hazard_wb;
	assign Rs2_hazard_id=  RegWrite_id && (Rd_id==Rs2);
	assign Rs2_hazard_ex=  RegWrite_ex && (Rd_ex==Rs2);
	assign Rs2_hazard_mem= RegWrite_mem && (Rd_mem==Rs2);
	assign Rs2_hazard_wb=  RegWrite_wb && (Rd_wb==Rs2);	

	
	wire Rs1_hazard_ex_noload;
	assign Rs1_hazard_ex_noload  = (!MemRead_ex) && Rs1_hazard_ex;

	wire Rs1_hazard_mem_load, Rs1_hazard_mem_noload; 
	assign Rs1_hazard_mem_load   = MemRead_mem && Rs1_hazard_mem;
	assign Rs1_hazard_mem_noload = (!MemRead_mem) && Rs1_hazard_mem;

	wire Rs2_hazard_mem_load, Rs2_hazard_mem_noload;
	assign Rs2_hazard_mem_load   = MemRead_mem && Rs2_hazard_mem;
	assign Rs2_hazard_mem_noload = (!MemRead_mem) && Rs2_hazard_mem;



	assign Rs1_forward_signal[0]= Rs1_hazard_wb;
	assign Rs1_forward_signal[1]= Rs1_hazard_mem_noload;

	assign Rs2_forward_signal[0]= Rs2_hazard_wb;
	assign Rs2_forward_signal[1]= Rs2_hazard_mem_noload;
	

	assign PL_stall_inner= jalr && (!Rs1_is_ra) && (Rs1_hazard_ex_noload || Rs1_hazard_mem_load);

	assign jalr_prediction_en = jalr && Rs1_is_ra && (Rs1_hazard_id ||
															  	                  Rs1_hazard_ex ||
																                    Rs1_hazard_mem_load);

	assign B_type_prediction_en = B_type && (Rs1_hazard_id || Rs2_hazard_id || 
	                                         Rs1_hazard_ex || Rs2_hazard_ex ||
																	         Rs1_hazard_mem_load || Rs2_hazard_mem_load);
endmodule