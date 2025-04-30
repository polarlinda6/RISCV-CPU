`include "define.v"

module if_stage(
	input  clk,
	input  rst_n,
	output [31:0]rom_addr,

	input  [31:0]instr_if_i,
    output [31:0]instr_if_o,

	output [31:0]pc_add_imme,
    output [31:0]pc_add_4,    
    output [31:0]jalr_pc_jump_or_pc, 
    output B_type_prediction_result,


    input  [31:0]pc_rollback,   
    input  [4:0]Rs1_id_o,
    input  jal_id_o,
    input  jalr_id_o, 
    
    
    input  B_type_id_o,
    input  beq_id_o,
    input  bne_id_o,
    input  blt_id_o,
    input  bge_id_o,
    input  bltu_id_o,
    input  bgeu_id_o,
    input  [31:0]pc_if_id_o,
    input  B_type_prediction_result_if_id_o,

    input  B_type_branch_failed,
    input  beq_branch_failed,
    input  bne_branch_failed,
    input  blt_branch_failed,
    input  bge_branch_failed,
    input  bltu_branch_failed,
    input  bgeu_branch_failed,
    input  [31:0]pc_branch_filled,
    input  B_type_prediction_result_branch_failed,


    output [4:0]regs_Rs1_if_o,
    output [4:0]regs_Rs2_if_o,
    input  [31:0]regs_Rs1_data_if_i,
    input  [31:0]regs_Rs2_data_if_i,

    input  [31:0]result_ex_mem_o,
    input  [31:0]load_or_result_mem_wb_o,
	
    input  [4:0]Rd_id_o,
    input  [4:0]Rd_id_ex_o,
 	input  [4:0]Rd_mem_wb_o,
	input  [4:0]Rd_ex_mem_o,

	input  RegWrite_id_o,
	input  RegWrite_id_ex_o,
	input  RegWrite_ex_mem_o,
	input  RegWrite_mem_wb_o,

	input  MemRead_id_ex_o,
	input  MemRead_ex_mem_o,

	input  PL_stall,
    input  PL_flush
    );
    
    wire [31:0]pc;
    wire [31:0]jalr_pc_prediction;	

    wire PL_stall_inner;

	assign rom_addr = pc;
    assign instr_if_o = PL_stall_inner ? `nop : instr_if_i;


    wire jal;
    wire jalr;
    wire B_type;
    wire beq;
    wire bne;
    wire blt;
    wire bge;
    wire bltu;
    wire bgeu;
    wire [2:0]func3;
    wire [31:0]imme;

    wire ras_pop;
    wire ras_push;
    wire ras_rollback_pop;
    wire ras_rollback_push;
    wire jalr_prediction_en;
    wire B_type_prediction_en;

    wire B_type_result;
    wire [31:0]forwardA_data, forwardB_data;


////////////////////////////////////////////////////////////////

    //pc_add_imme + pc_add_4 + pc_jump
    wire [31:0]pc_jump;

    wire [31:0]A;
    mux3 adderA_mux3_inst(
        .din1(jalr_pc_prediction),
        .din2(forwardA_data),
        .din3(pc),
        .signal({jalr_prediction_en, jalr}),
        .dout(A)
    );
    cla_adder32 pc_add_imme_inst(
        .A(A),
        .B(imme),
        .cin(`zero),
        .result(pc_add_imme),
        .cout()
    );
    cla_adder32 pc_add_4_inst(
        .A(pc),
        .B(32'd4),
        .cin(`zero),
        .result(pc_add_4),
        .cout()
    );   
    mux jalr_set_mux_inst(
        .din1(pc_add_imme & 32'hfffffffe),
        .din2(pc_add_imme),
        .signal(jalr),
        .dout(pc_jump)
    );


   //jalr_pc_jump_or_pc
    mux jalr_pc_jump_or_pc_mux_inst(
        .din1(pc_jump),
        .din2(pc),
        .signal(jalr),
        .dout(jalr_pc_jump_or_pc)
    );

   //pc
    wire [31:0]pc_new;
    mux3 pc_data_mux3_inst(
        .din1(pc_rollback),
        .din2(pc_jump),
        .din3(pc_add_4),
        .signal({PL_flush, jal || jalr || (B_type && B_type_result)}),
        .dout(pc_new)
    );    
    pc_reg pc_reg_inst (
        .clk(clk), 
        .rst_n(rst_n),

        .PL_stall(PL_stall || PL_stall_inner),       
        .pc_new(pc_new), 
        .pc_out(pc)
    );

///////////////////////////////////////////////////////////////////////////////////////

   //fast comparator   
    wire compare_result;
   
    fast_comparator #(
        .WIDTH(32)
    ) comparator_inst(
        .data1(forwardA_data),
        .data2(forwardB_data),
        .func3(func3),
        .compare_result(compare_result)
    );

    //B_type_result
    mux #(
        .WIDTH(1)
    ) B_type_result_mux_inst(
        .din1(B_type_prediction_result),
        .din2(compare_result),
        .signal(B_type_prediction_en),
        .dout(B_type_result)
    );

/////////////////////////////////////////////////////////////////////////////////////

    //branch predictor   
    branch_predictor branch_predictor_inst(
        .clk(clk), 
        .rst_n(rst_n),
        .PL_stall(PL_stall || PL_stall_inner),
        .PL_flush(PL_flush),
 
        .B_type_prediction_result(B_type_prediction_result),
        .jalr_pc_prediction(jalr_pc_prediction),
      
        .ras_pop(ras_pop),
        .ras_push(ras_push),
        .ras_rollback_pop(ras_rollback_pop),
        .ras_rollback_push(ras_rollback_push),

        .pc_add_4(pc_add_4),
        .imme(imme),

        .B_type(B_type),
        .beq(beq),
        .bne(bne),
        .blt(blt),
        .bge(bge),
        .bltu(bltu),
        .bgeu(bgeu),
        .pc(pc),
        .corrected_result(B_type_result),

        .B_type_id(B_type_id_o),
        .beq_id(beq_id_o),
        .bne_id(bne_id_o),
        .blt_id(blt_id_o),
        .bge_id(bge_id_o),
        .bltu_id(bltu_id_o),
        .bgeu_id(bgeu_id_o),
        .pc_id(pc_if_id_o),
        .B_type_prediction_result_id(B_type_prediction_result_if_id_o),

        .B_type_branch_failed(B_type_branch_failed),
        .beq_branch_failed(beq_branch_failed),
        .bne_branch_failed(bne_branch_failed),
        .blt_branch_failed(blt_branch_failed),
        .bge_branch_failed(bge_branch_failed),
        .bltu_branch_failed(bltu_branch_failed),
        .bgeu_branch_failed(bgeu_branch_failed),
        .pc_branch_filled(pc_branch_filled),
        .B_type_prediction_result_branch_failed(B_type_prediction_result_branch_failed)
    );

////////////////////////////////////////////////////////////////////////
    
    //mini decode
    wire [4:0] Rd; 

    mini_decode mini_decode_inst(
        .instr(instr_if_i),	

        .jal(jal),
        .jalr(jalr),
        .B_type(B_type),
        .beq(beq),
        .bne(bne),
        .blt(blt),
        .bge(bge),
        .bltu(bltu),
        .bgeu(bgeu),
        
        .Rs1(regs_Rs1_if_o),
        .Rs2(regs_Rs2_if_o),

        .Rd(Rd),    
        .func3(func3),
        .imme(imme)
    );

    //mini control
    wire [1:0]Rs1_forward_signal;
    wire [1:0]Rs2_forward_signal;

    mini_control mini_control_inst(
        .Rs1(regs_Rs1_if_o),
        .Rs2(regs_Rs2_if_o),

        .Rd_id(Rd_id_o),                
        .Rd_ex(Rd_id_ex_o),
        .Rd_mem(Rd_ex_mem_o),
        .Rd_wb(Rd_mem_wb_o),

        .RegWrite_id(RegWrite_id_o),
        .RegWrite_ex(RegWrite_id_ex_o),
        .RegWrite_mem(RegWrite_ex_mem_o),
        .RegWrite_wb(RegWrite_mem_wb_o),

        .MemRead_ex(MemRead_id_ex_o),
        .MemRead_mem(MemRead_ex_mem_o),

        .Rs1_forward_signal(Rs1_forward_signal),
        .Rs2_forward_signal(Rs2_forward_signal),
       

        .B_type(B_type),       
        .B_type_prediction_en(B_type_prediction_en),


        .jal(jal),
        .jalr(jalr),             
        .jal_id(jal_id_o),
        .jalr_id(jalr_id_o),     
        .PL_flush(PL_flush),
        .PL_stall(PL_stall || PL_stall_inner),

        .Rd(Rd),      
        .Rs1_id(Rs1_id_o),

        .ras_pop(ras_pop),
        .ras_push(ras_push),
        .ras_rollback_pop(ras_rollback_pop),
        .ras_rollback_push(ras_rollback_push),

        .jalr_prediction_en(jalr_prediction_en),        
        .PL_stall_inner(PL_stall_inner)
    );

    //forward
    mux3 #(
        .WIDTH(32)
    ) forwardA_data_mux3_inst(
        .din1(result_ex_mem_o),
        .din2(load_or_result_mem_wb_o),
        .din3(regs_Rs1_data_if_i),
        .signal(Rs1_forward_signal),
        .dout(forwardA_data)
    );
    mux3 #(
        .WIDTH(32)
    ) forwardB_data_mux3_inst(
        .din1(result_ex_mem_o),
        .din2(load_or_result_mem_wb_o),
        .din3(regs_Rs2_data_if_i),
        .signal(Rs2_forward_signal),
        .dout(forwardB_data)
    );
endmodule
