module datapath(
	input  clk,
	input  rst_n,
	input  [31:0]instr,

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

    input  RegWrite,
	input  MemRead,
	input  MemWrite,
	input  [2:0]RW_type_id,	


	input  [31:0]load_data,
    output [31:0]store_data,
	
	output R_en,
	output W_en,
	output [2:0]RW_type,
	
	output [31:0]rom_addr,
	output [31:0]ram_addr,


    output [4:0]Rd, 
	output [6:0]opcode,
	output [2:0]func3,
	output func7,


    output stat_beq, 
    output stat_bne,
    output stat_blt,
    output stat_bge,
    output stat_bltu,
    output stat_bgeu,
    output stat_jal,
    output stat_jalr,
    output stat_PL_flush,

    output stat_PL_stall,
    output stat_PL_stall_inner,
    output stat_ecall
    );

    //forward
    wire [31:0]result_ex_mem_o;
    wire [31:0]load_or_result_mem_wb_o;

    //hazard
    // wire [4:0]Rd_id_o;  //Rd
	wire [4:0]Rd_id_ex_o;
	wire [4:0]Rd_ex_mem_o;
    wire [4:0]Rd_mem_wb_o;

    //wire RegWrite_id_o; //RegWrite;
    wire RegWrite_id_ex_o;
    wire RegWrite_ex_mem_o;
    wire RegWrite_mem_wb_o;

    wire [4:0]Rs1_id_o;
    wire [4:0]Rs2_id_o;

    wire MemRead_id_ex_o;
    wire MemRead_ex_mem_o;
    //wire MemWrite_id_o; //MemWrite
    wire MemWrite_ex_mem_o;

	wire PL_stall;
	wire PL_flush;

    //write read memory
    //wire MemRead_ex_mem_o;
    //wire MemWrite_ex_mem_o;
	wire [2:0]RW_type_ex_mem_o;


    assign R_en=MemRead_ex_mem_o;
    assign W_en=MemWrite_ex_mem_o;
    assign RW_type=RW_type_ex_mem_o;
    assign ram_addr=result_ex_mem_o;

////////////////////////////////////////////////////////////////////

    wire [4:0]prediction_Rs1_if_o;
    wire [4:0]prediction_Rs2_if_o;
	wire [31:0]prediction_Rs1_data_id_o;
    wire [31:0]prediction_Rs2_data_id_o;
    
    wire B_type_id_ex_o;
	wire beq_id_ex_o;
	wire bne_id_ex_o;
	wire blt_id_ex_o;
	wire bge_id_ex_o;
	wire bltu_id_ex_o;
	wire bgeu_id_ex_o;
    wire B_type_result_id_ex_o;
    wire [31:0]jalr_pc_jump_or_pc_id_ex_o;
    wire [31:0]pc_rollback_ex_o;

    //wire B_type_id_o;
	//wire beq_id_o;
	//wire bne_id_o;
	//wire blt_id_o;
	//wire bge_id_o;
	//wire bltu_id_o;
	//wire bgeu_id_o;
    //wire jalr_id_o;
    wire [31:0]jalr_pc_jump_or_pc_if_id_o;
    wire B_type_result_if_id_o;
    //wire [4:0]Rd_id_o;
    //wire [4:0]Rs1_id_o;

	
    wire [31:0]instr_if_o;
    wire [31:0]pc_add_imme_if_o;
    wire [31:0]pc_add_4_if_o;
    wire [31:0]jalr_pc_jump_or_pc_if_o;
    wire B_type_result_if_o;
	
    if_stage if_stage_inst (
        .clk(clk), 
        .rst_n(rst_n), 
        .rom_addr(rom_addr),

        .instr_if_i(instr),
        .instr_if_o(instr_if_o),

        //branch prediction
        .pc_add_imme(pc_add_imme_if_o),
        .pc_add_4(pc_add_4_if_o),
        .jalr_pc_jump_or_pc(jalr_pc_jump_or_pc_if_o), 
        .B_type_result(B_type_result_if_o),

        .pc_rollback(pc_rollback_ex_o),
        .Rs1_id_o(Rs1_id_o),
        .jal_id_o(jal),
        .jalr_id_o(jalr),  
 
        .B_type_id_o(B_type),  
        .beq_id_o(beq),
        .bne_id_o(bne),
        .blt_id_o(blt),
        .bge_id_o(bge),
        .bltu_id_o(bltu),
        .bgeu_id_o(bgeu),           
        .pc_if_id_o(jalr_pc_jump_or_pc_if_id_o),   
        .B_type_result_if_id_o(B_type_result_if_id_o), 
    
        
        .B_type_branch_failed(B_type_id_ex_o),
        .beq_branch_failed(beq_id_ex_o),
        .bne_branch_failed(bne_id_ex_o),
        .blt_branch_failed(blt_id_ex_o),
        .bge_branch_failed(bge_id_ex_o),
        .bltu_branch_failed(bltu_id_ex_o),
        .bgeu_branch_failed(bgeu_id_ex_o),
        .pc_branch_filled(jalr_pc_jump_or_pc_id_ex_o),
        .B_type_result_branch_failed(B_type_result_id_ex_o),
   

        .regs_Rs1_if_o(prediction_Rs1_if_o),
        .regs_Rs2_if_o(prediction_Rs2_if_o),
        .regs_Rs1_data_if_i(prediction_Rs1_data_id_o),
        .regs_Rs2_data_if_i(prediction_Rs2_data_id_o),

        //forward
        .Rd_id_o(Rd), 
        .Rd_id_ex_o(Rd_id_ex_o),
        .Rd_ex_mem_o(Rd_ex_mem_o),
        .Rd_mem_wb_o(Rd_mem_wb_o),

        .RegWrite_id_o(RegWrite),
        .RegWrite_id_ex_o(RegWrite_id_ex_o),
        .RegWrite_ex_mem_o(RegWrite_ex_mem_o),
        .RegWrite_mem_wb_o(RegWrite_mem_wb_o),

        .MemRead_ex_mem_o(MemRead_ex_mem_o),
        .MemRead_id_ex_o(MemRead_id_ex_o),

        .result_ex_mem_o(result_ex_mem_o),
        .load_or_result_mem_wb_o(load_or_result_mem_wb_o),


        .PL_stall(PL_stall),
        .PL_flush(PL_flush),

        .PL_stall_inner(stat_PL_stall_inner)
        );
    
    

    wire [31:0]pc_add_imme_if_id_o;
    wire [31:0]pc_add_4_if_id_o;

    wire [31:0]instr_if_id_o;
    
    if_id_regs if_id_regs_inst(
        .clk(clk), 
        .rst_n(rst_n), 
        
        .pc_add_imme_if_id_i(pc_add_imme_if_o), 
        .pc_add_imme_if_id_o(pc_add_imme_if_id_o), 

        .pc_add_4_if_id_i(pc_add_4_if_o),
        .pc_add_4_if_id_o(pc_add_4_if_id_o),

        .jalr_pc_jump_or_pc_if_id_i(jalr_pc_jump_or_pc_if_o),
        .jalr_pc_jump_or_pc_if_id_o(jalr_pc_jump_or_pc_if_id_o),

        .B_type_result_if_id_i(B_type_result_if_o),
        .B_type_result_if_id_o(B_type_result_if_id_o),

        .instr_if_id_i(instr_if_o), 
        .instr_if_id_o(instr_if_id_o),
        
        .PL_stall(PL_stall),
        .PL_flush(PL_flush)
        );
    
    
    wire ecall_id_o;
    wire [31:0]imme_id_o;
    wire [31:0]Rs1_data_id_o;
    wire [31:0]Rs2_data_id_o;

    id_stage id_stage_inst (
        .clk(clk), 
        .rst_n(rst_n), 
        .instr_id_i(instr_if_id_o),  
        
        //branch prediction
        .prediction_Rs1_id_i(prediction_Rs1_if_o),
        .prediction_Rs2_id_i(prediction_Rs2_if_o),
        .prediction_Rs1_data_id_o(prediction_Rs1_data_id_o),   
        .prediction_Rs2_data_id_o(prediction_Rs2_data_id_o),

        //write regs
        .Rd_id_i(Rd_mem_wb_o),
        .RegWrite_id_i(RegWrite_mem_wb_o),
        .Wr_reg_data_id_i(load_or_result_mem_wb_o),      
        
  
        .Rs1_id_o(Rs1_id_o),
        .Rs2_id_o(Rs2_id_o),      
        .imme_id_o(imme_id_o), 
        .Rs1_data_id_o(Rs1_data_id_o), 
        .Rs2_data_id_o(Rs2_data_id_o),

        .Rd_id_o(Rd),        
        .opcode_id_o(opcode), 
        .func3_id_o(func3), 
        .func7_id_o(func7),

        .ecall_id_o(ecall_id_o)
        );
    

    wire [2:0]RW_type_id_ex_o;

    
    wire [31:0]pc_add_imme_id_ex_o;
    wire [31:0]pc_add_4_id_ex_o;

    wire [31:0]imme_id_ex_o;
	wire [31:0]Rs1_data_id_ex_o;
	wire [31:0]Rs2_data_id_ex_o;
    //wire [4:0]Rs1_id_ex_o;
	wire [4:0]Rs2_id_ex_o;

    wire ALU_DA_pc_signal_id_ex_o;
    wire ALU_DA_imme_signal_id_ex_o;    
	wire [3:0]ALUctl_id_ex_o;
    wire jal_id_ex_o;
    wire jalr_id_ex_o;
    wire [4:0]Rs1_id_ex_o;
    wire MemWrite_id_ex_o;
    wire ecall_id_ex_o;

    id_ex_regs id_ex_regs_inst (
        .clk(clk), 
        .rst_n(rst_n), 
        
        .pc_add_imme_id_ex_i(pc_add_imme_if_id_o),
        .pc_add_4_id_ex_i(pc_add_4_if_id_o),
        .jalr_pc_jump_or_pc_id_ex_i(jalr_pc_jump_or_pc_if_id_o),
        .B_type_result_id_ex_i(B_type_result_if_id_o),

        .pc_add_imme_id_ex_o(pc_add_imme_id_ex_o), 
        .pc_add_4_id_ex_o(pc_add_4_id_ex_o),
        .jalr_pc_jump_or_pc_id_ex_o(jalr_pc_jump_or_pc_id_ex_o),
        .B_type_result_id_ex_o(B_type_result_id_ex_o),

        .imme_id_ex_i(imme_id_o), 
        .Rs1_data_id_ex_i(Rs1_data_id_o), 
        .Rs2_data_id_ex_i(Rs2_data_id_o), 
        .Rd_id_ex_i(Rd),
        .Rs1_id_ex_i(Rs1_id_o),
        .Rs2_id_ex_i(Rs2_id_o),
        
        .imme_id_ex_o(imme_id_ex_o), 
        .Rs1_data_id_ex_o(Rs1_data_id_ex_o), 
        .Rs2_data_id_ex_o(Rs2_data_id_ex_o),
        .Rd_id_ex_o(Rd_id_ex_o),
        .Rs1_id_ex_o(Rs1_id_ex_o),
        .Rs2_id_ex_o(Rs2_id_ex_o),
    
        //control signals
        .ALU_DA_pc_signal_id_ex_i(ALU_DA_pc_signal), 
        .ALU_DA_imme_signal_id_ex_i(ALU_DA_imme_signal), 
        .ALUctl_id_ex_i(ALUctl), 
        .B_type_id_ex_i(B_type),
        .beq_id_ex_i(beq), 
        .bne_id_ex_i(bne), 
        .blt_id_ex_i(blt), 
        .bge_id_ex_i(bge), 
        .bltu_id_ex_i(bltu), 
        .bgeu_id_ex_i(bgeu), 
        .jal_id_ex_i(jal),
        .jalr_id_ex_i(jalr), 
        .RegWrite_id_ex_i(RegWrite),
        .MemRead_id_ex_i(MemRead), 
        .MemWrite_id_ex_i(MemWrite), 
        .RW_type_id_ex_i(RW_type_id), 
        .ecall_id_ex_i(ecall_id_o),

        .ALU_DA_pc_signal_id_ex_o(ALU_DA_pc_signal_id_ex_o),         
        .ALU_DA_imme_signal_id_ex_o(ALU_DA_imme_signal_id_ex_o), 
        .ALUctl_id_ex_o(ALUctl_id_ex_o), 
        .B_type_id_ex_o(B_type_id_ex_o),
        .beq_id_ex_o(beq_id_ex_o), 
        .bne_id_ex_o(bne_id_ex_o), 
        .blt_id_ex_o(blt_id_ex_o), 
        .bge_id_ex_o(bge_id_ex_o), 
        .bltu_id_ex_o(bltu_id_ex_o), 
        .bgeu_id_ex_o(bgeu_id_ex_o), 
        .jal_id_ex_o(jal_id_ex_o),
        .jalr_id_ex_o(jalr_id_ex_o), 
        .RegWrite_id_ex_o(RegWrite_id_ex_o),
        .MemRead_id_ex_o(MemRead_id_ex_o), 
        .MemWrite_id_ex_o(MemWrite_id_ex_o), 
        .RW_type_id_ex_o(RW_type_id_ex_o), 
        .ecall_id_ex_o(ecall_id_ex_o),
        
        .PL_stall(PL_stall),
        .PL_flush(PL_flush)
        );
        

    wire [31:0]B;


    wire [31:0]result_ex_o;
    wire forward_load_ex_o;

    ex_stage ex_stage_inst (
        .clk(clk),
        .rst_n(rst_n),
        .ecall(ecall_id_ex_o),

        .ALU_DA_pc_signal(ALU_DA_pc_signal_id_ex_o),
        .ALU_DA_imme_signal(ALU_DA_imme_signal_id_ex_o), 
        .ALUctl(ALUctl_id_ex_o),
        .B_type(B_type_id_ex_o),
        .beq(beq_id_ex_o), 
        .bne(bne_id_ex_o), 
        .blt(blt_id_ex_o), 
        .bge(bge_id_ex_o), 
        .bltu(bltu_id_ex_o), 
        .bgeu(bgeu_id_ex_o), 
        .jal(jal_id_ex_o),
        .jalr(jalr_id_ex_o), 

        .pc_add_imme_ex_i(pc_add_imme_id_ex_o), 
        .pc_add_4_ex_i(pc_add_4_id_ex_o),
        .jalr_pc_jump_or_pc_ex_i(jalr_pc_jump_or_pc_id_ex_o),
        .B_type_result_ex_i(B_type_result_id_ex_o),


        .pc_rollback_ex_o(pc_rollback_ex_o),

        .imme_ex_i(imme_id_ex_o), 
        .Rs1_data_ex_i(Rs1_data_id_ex_o), 
        .Rs2_data_ex_i(Rs2_data_id_ex_o), 

        .B(B),
        .result_ex_o(result_ex_o), 

        //forword
        .Rs1_ex_i(Rs1_id_ex_o), 
        .Rs2_ex_i(Rs2_id_ex_o), 
        .Rd_ex_mem_o(Rd_ex_mem_o), 
        .Rd_mem_wb_o(Rd_mem_wb_o), 

        .Rs1_id_ex_i(Rs1_id_o),
        .Rs2_id_ex_i(Rs2_id_o),
        .Rd_id_ex_o(Rd_id_ex_o),

        .RegWrite_ex_mem_o(RegWrite_ex_mem_o),
        .RegWrite_mem_wb_o(RegWrite_mem_wb_o),


        .RegWrite_id_ex_o(RegWrite_id_ex_o),
        .MemRead_id_ex_o(MemRead_id_ex_o),
        .MemRead_ex_mem_o(MemRead_ex_mem_o),

        .MemWrite_id_o(MemWrite),
        .MemWrite_id_ex_o(MemWrite_id_ex_o),

        .result_ex_mem_o(result_ex_mem_o), 
        .load_or_result_mem_wb_o(load_or_result_mem_wb_o), 

        .forward_load(forward_load_ex_o),
        .PL_flush(PL_flush),
        .PL_stall(PL_stall)
        );
            

    wire forward_load_ex_mem_o;    
    wire [31:0]Rs2_data_ex_mem_o;    
        
    ex_mem_regs ex_mem_regs_inst (
        .clk(clk), 
        .rst_n(rst_n), 
        
        .result_ex_mem_i(result_ex_o), 
        .Rs2_data_ex_mem_i(B), 
        .Rd_ex_mem_i(Rd_id_ex_o),

        .result_ex_mem_o(result_ex_mem_o), //forward
        .Rs2_data_ex_mem_o(Rs2_data_ex_mem_o), 
        .Rd_ex_mem_o(Rd_ex_mem_o),    

        .forward_load_ex_mem_i(forward_load_ex_o),
        .forward_load_ex_mem_o(forward_load_ex_mem_o),
        
        //control signals
        .RegWrite_ex_mem_i(RegWrite_id_ex_o),
        .MemRead_ex_mem_i(MemRead_id_ex_o), 
        .MemWrite_ex_mem_i(MemWrite_id_ex_o), 
        .RW_type_ex_mem_i(RW_type_id_ex_o), 

        .RegWrite_ex_mem_o(RegWrite_ex_mem_o),
        .MemRead_ex_mem_o(MemRead_ex_mem_o),  
        .MemWrite_ex_mem_o(MemWrite_ex_mem_o),
        .RW_type_ex_mem_o(RW_type_ex_mem_o)
        );


    wire [31:0]load_or_result_mem_o;    
    
    mem_stage mem_stage_inst(
        .Rs2_data_mem_i(Rs2_data_ex_mem_o), 
        .load_data_mem_wb_o(load_or_result_mem_wb_o),
        .forward_load_mem_i(forward_load_ex_mem_o), 
        .store_data(store_data),

        .result_mem_i(result_ex_mem_o), 
        .load_data_mem_i(load_data), 
        .MemRead_mem_i(MemRead_ex_mem_o), 
        .load_or_result_mem_o(load_or_result_mem_o)
        );
    

    mem_wb_regs mem_wb_regs_inst (
        .clk(clk),
        .rst_n(rst_n),
        
        .load_or_result_mem_wb_i(load_or_result_mem_o),         
        .RegWrite_mem_wb_i(RegWrite_ex_mem_o),
        .Rd_mem_wb_i(Rd_ex_mem_o),
        
        .load_or_result_mem_wb_o(load_or_result_mem_wb_o),
        .RegWrite_mem_wb_o(RegWrite_mem_wb_o), 
        .Rd_mem_wb_o(Rd_mem_wb_o)
        );

///////////////////////////////////////////////////////////////////////

    assign stat_beq      = beq_id_ex_o; 
    assign stat_bne      = bne_id_ex_o;
    assign stat_blt      = blt_id_ex_o;
    assign stat_bge      = bge_id_ex_o;
    assign stat_bltu     = bltu_id_ex_o;
    assign stat_bgeu     = bgeu_id_ex_o;
    assign stat_jal      = jal_id_ex_o;
    assign stat_jalr     = jalr_id_ex_o;
    assign stat_PL_flush = PL_flush;

    assign stat_PL_stall = PL_stall;
    //assign stat_PL_stall_inner = PL_stall_inner;
    assign stat_ecall = ecall_id_ex_o;
endmodule