`include "define.v"

module ex_stage(
    input  clk,
    input  rst_n,
    input  ecall,

    input  ALU_DA_pc_signal,
    input  ALU_DA_imme_signal,
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
	input  [31:0]jalr_pc_jump_or_pc_ex_i,	  
    input  B_type_result_ex_i,
    
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
	output PL_stall_ex,
	output PL_flush
    );

    reg ecall_reg;
    always @(posedge clk) begin
        if(!rst_n) 
            ecall_reg <= `zero;
        else if(!ecall_reg)
            ecall_reg <= ecall;
    end

    wire PL_stall_inner;
    assign PL_stall_ex = ecall_reg || ecall || PL_stall_inner;

//////////////////////////////////////////////////////////////////////////////////////////

	wire zero;
    wire [31:0]ALU_result;
    wire [31:0]A;
	
    wire [31:0]ALU_DA, ALU_DB;
    mux ALU_DA_mux (
        .din1(jalr_pc_jump_or_pc_ex_i), 
        .din2(A), 
        .signal(ALU_DA_pc_signal), 
        .dout(ALU_DA)
    );
    mux ALU_DB_mux (
        .din1(imme_ex_i), 
        .din2(B), 
        .signal(ALU_DA_imme_signal), 
        .dout(ALU_DB)
    );
	ALU ALU_inst (
        .ALU_DA(ALU_DA), 
        .ALU_DB(ALU_DB), 
        .ALU_CTL(ALUctl), 
        .ALU_ZERO(zero), 
        .ALU_OverFlow(), 
        .ALU_DC(ALU_result)
    );


    mux result_mux_inst(
        .din1(pc_add_4_ex_i),
        .din2(ALU_result),
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
        .PL_stall_ex(PL_stall_inner)
    );
    mux3 mux3_forwardA (
        .din1(result_ex_mem_o), 
        .din2(load_or_result_mem_wb_o), 
        .din3(Rs1_data_ex_i), 
        .signal(forwardA), 
        .dout(A)
    );
    mux3 mux3_forwardB (
        .din1(result_ex_mem_o), 
        .din2(load_or_result_mem_wb_o), 
        .din3(Rs2_data_ex_i), 
        .signal(forwardB), 
        .dout(B)
    );


    wire [31:0] jalr_pc_jump_actual;
    assign jalr_pc_jump_actual= ALU_result & 32'hffffffe;
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
        .jalr_pc_jump_actual(jalr_pc_jump_actual),            
        
        .B_type_result(B_type_result_ex_i),
        .jalr_pc_jump(jalr_pc_jump_or_pc_ex_i),

        .PL_flush(PL_flush)
    );
    mux3 branch_failed_mux3_inst(
        .din1(jalr_pc_jump_actual),
        .din2(pc_add_4_ex_i),
        .din3(pc_add_imme_ex_i),
        .signal({jalr, B_type_result_ex_i}),
        .dout(pc_rollback_ex_o)
    );
endmodule