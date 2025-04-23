module ex_stage(
    input  ALU_DA_signal,
    input  ALU_DB_signal,
	input  [3:0]ALUctl,
    input  B_type,
	input  beq,
	input  bne,
	input  blt,
	input  bge,
	input  bltu,
	input  bgeu,
	input  jal,
	input  jalr,

	input  [31:0]pc_add_imme_ex_i,
	input  [31:0]pc_add_4_ex_i, 
	input  [31:0]jalr_pc_prediction_or_pc_ex_i,	  
    input  B_type_prediction_result_ex_i,
    
	output [31:0]pc_rollback_ex_o,
	

	input  [31:0]imme_ex_i,
	input  [31:0]Rs1_data_ex_i,
	input  [31:0]Rs2_data_ex_i,

    output [31:0]B,
	output [31:0]result_ex_o,


	input  [4:0]Rs1_ex_i,
	input  [4:0]Rs2_ex_i,
	input  [4:0]Rd_ex_mem_o,
	input  [4:0]Rd_mem_wb_o,

	input  [4:0]Rs1_id_ex_i,
	input  [4:0]Rs2_id_ex_i,
	input  [4:0]Rd_id_ex_o,

    input  RegWrite_ex_mem_o,
    input  RegWrite_mem_wb_o,


    input  RegWrite_id_ex_o,
	input  MemRead_id_ex_o,
	input  MemRead_ex_mem_o,

	input  MemWrite_id_o,
	input  MemWrite_id_ex_o,
	
    input  [31:0]result_ex_mem_o,
	input  [31:0]load_or_result_mem_wb_o,

	output forward_load,
	output PL_stall,
	output PL_flush
    );

	wire zero;
    wire [31:0]ALU_result;
    wire [31:0]A;
	
    wire [31:0]ALU_DA, ALU_DB;
    mux ALU_DA_mux (
        .data1(jalr_pc_prediction_or_pc_ex_i), 
        .data2(A), 
        .signal(ALU_DA_signal), 
        .dout(ALU_DA)
        );
    mux ALU_DB_mux (
        .data1(imme_ex_i), 
        .data2(B), 
        .signal(ALU_DB_signal), 
        .dout(ALU_DB)
        );
	alu alu_inst (
        .ALU_DA(ALU_DA), 
        .ALU_DB(ALU_DB), 
        .ALU_CTL(ALUctl), 
        .ALU_ZERO(zero), 
        .ALU_OverFlow(), 
        .ALU_DC(ALU_result)
        );


    mux result_mux_inst(
        .data1(pc_add_4_ex_i),
        .data2(ALU_result),
        .signal(jal | jalr),
        .dout(result_ex_o)
    );
    

	wire [1:0]forwardA, forwardB;
    forward_unit forward_unit_inst (
        .Rs1_id_ex_o(Rs1_ex_i), 
        .Rs2_id_ex_o(Rs2_ex_i), 
        .Rd_ex_mem_o(Rd_ex_mem_o), 
        .Rd_mem_wb_o(Rd_mem_wb_o), 

        .RegWrite_ex_mem_o(RegWrite_ex_mem_o), 
        .RegWrite_mem_wb_o(RegWrite_mem_wb_o),
        
        .forwardA(forwardA), 
        .forwardB(forwardB), 
        

        .Rs1_id_ex_i(Rs1_id_ex_i),
        .Rs2_id_ex_i(Rs2_id_ex_i),
        .Rd_id_ex_o(Rd_id_ex_o),

        .RegWrite_id_ex_o(RegWrite_id_ex_o),
        .MemRead_id_ex_o(MemRead_id_ex_o),
        .MemRead_ex_mem_o(MemRead_ex_mem_o), 

        .MemWrite_id_o(MemWrite_id_o),
        .MemWrite_id_ex_o(MemWrite_id_ex_o), 

        .forward_load(forward_load),
        .PL_stall(PL_stall)
        );
    mux3 mux3_forwardA (
        .data1(result_ex_mem_o), 
        .data2(load_or_result_mem_wb_o), 
        .data3(Rs1_data_ex_i), 
        .signal(forwardA), 
        .dout(A)
        );
    mux3 mux3_forwardB (
        .data1(result_ex_mem_o), 
        .data2(load_or_result_mem_wb_o), 
        .data3(Rs2_data_ex_i), 
        .signal(forwardB), 
        .dout(B)
        );


    wire [31:0] jalr_pc_new;
    assign jalr_pc_new= ALU_result & 32'hffffffe;
	branch_judge branch_judge_inst (
        .B_type(B_type),
        .beq(beq), 
        .bne(bne), 
        .blt(blt), 
        .bge(bge), 
        .bltu(bltu), 
        .bgeu(bgeu), 
        .jalr(jalr),

        .zero(zero), 
        .slt_result(ALU_result[0]), 
        .jalr_pc_new(jalr_pc_new),            
        
        .B_type_prediction_result(B_type_prediction_result_ex_i),
        .jalr_pc_prediciton(jalr_pc_prediction_or_pc_ex_i),

        .PL_flush(PL_flush)
        );
    mux3 branch_failed_inst(
        .data1(jalr_pc_new),
        .data2(pc_add_4_ex_i),
        .data3(pc_add_imme_ex_i),
        .signal({jalr, B_type_prediction_result_ex_i}),
        .dout(pc_rollback_ex_o)
    );
endmodule