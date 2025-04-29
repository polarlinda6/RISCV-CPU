`include "define.v"

module id_ex_regs(
	input clk,
	input rst_n,
	
	input [31:0]pc_add_imme_id_ex_i,
    input [31:0]pc_add_4_id_ex_i,
    input [31:0]jalr_pc_jump_or_pc_id_ex_i,
    input B_type_prediction_result_id_ex_i, 

	output reg [31:0]pc_add_imme_id_ex_o,
    output reg [31:0]pc_add_4_id_ex_o,
    output reg [31:0]jalr_pc_jump_or_pc_id_ex_o,
    output reg B_type_prediction_result_id_ex_o,
    	
	input [31:0]imme_id_ex_i,
	input [31:0]Rs1_data_id_ex_i,
	input [31:0]Rs2_data_id_ex_i,
	input [4:0]Rd_id_ex_i,
	input [4:0]Rs1_id_ex_i,
	input [4:0]Rs2_id_ex_i,
	
	output reg [31:0]imme_id_ex_o,
	output reg [31:0]Rs1_data_id_ex_o,
	output reg [31:0]Rs2_data_id_ex_o,
	output reg [4:0]Rd_id_ex_o,
	output reg [4:0]Rs1_id_ex_o,
	output reg [4:0]Rs2_id_ex_o,
	
	//control signals
	input ALU_DA_signal_id_ex_i,	
    input ALU_DB_signal_id_ex_i,
	input [3:0]ALUctl_id_ex_i,
    input B_type_id_ex_i,
	input beq_id_ex_i,
	input bne_id_ex_i,
	input blt_id_ex_i,
	input bge_id_ex_i,
	input bltu_id_ex_i,
	input bgeu_id_ex_i,
	input jal_id_ex_i,
	input jalr_id_ex_i,
    input RegWrite_id_ex_i,
	input MemRead_id_ex_i,
	input MemWrite_id_ex_i,
	input [2:0]RW_type_id_ex_i,

	output reg ALU_DA_signal_id_ex_o,	
	output reg ALU_DB_signal_id_ex_o,
	output reg [3:0]ALUctl_id_ex_o,
    output reg B_type_id_ex_o,
	output reg beq_id_ex_o,
	output reg bne_id_ex_o,
	output reg blt_id_ex_o,
	output reg bge_id_ex_o,
	output reg bltu_id_ex_o,
	output reg bgeu_id_ex_o,
	output reg jal_id_ex_o,
	output reg jalr_id_ex_o,
    output reg RegWrite_id_ex_o,
	output reg MemRead_id_ex_o,
	output reg MemWrite_id_ex_o,
	output reg [2:0]RW_type_id_ex_o,
	

	input PL_flush,
	input PL_stall
    );

        
    always@(posedge clk)
        begin
            if(!rst_n || PL_flush || PL_stall)
                begin 
                    //non-standard nop: add x0, x0, x0
                    pc_add_imme_id_ex_o<=`zeroword;
                    pc_add_4_id_ex_o<=`zeroword;
                    jalr_pc_jump_or_pc_id_ex_o<=`zeroword;    
                    B_type_prediction_result_id_ex_o<=`zero;

                    imme_id_ex_o<=`zeroword;
                    Rs1_data_id_ex_o<=`zeroword;
                    Rs2_data_id_ex_o<=`zeroword;
                    Rd_id_ex_o<=`zeroreg;
                    Rs1_id_ex_o<=`zeroreg;
                    Rs2_id_ex_o<=`zeroreg;

                    ALU_DA_signal_id_ex_o<=`zero;                    
                    ALU_DB_signal_id_ex_o<=`zero;
                    ALUctl_id_ex_o<=4'b0000;
                    B_type_id_ex_o<=`zero;
                    beq_id_ex_o<=`zero;
                    bne_id_ex_o<=`zero;
                    blt_id_ex_o<=`zero;
                    bge_id_ex_o<=`zero;
                    bltu_id_ex_o<=`zero;
                    bgeu_id_ex_o<=`zero;
                    jal_id_ex_o<=`zero;
                    jalr_id_ex_o<=`zero;
                    RegWrite_id_ex_o<=`zero;
                    MemRead_id_ex_o<=`zero;
                    MemWrite_id_ex_o<=`zero;
                    RW_type_id_ex_o<=3'b000;
                end
            else 
                begin
                    pc_add_imme_id_ex_o<=pc_add_imme_id_ex_i;
                    pc_add_4_id_ex_o<=pc_add_4_id_ex_i;
                    jalr_pc_jump_or_pc_id_ex_o<=jalr_pc_jump_or_pc_id_ex_i;  
                    B_type_prediction_result_id_ex_o<=B_type_prediction_result_id_ex_i;

                    imme_id_ex_o<=imme_id_ex_i;
                    Rs1_data_id_ex_o<=Rs1_data_id_ex_i;
                    Rs2_data_id_ex_o<=Rs2_data_id_ex_i;
                    Rd_id_ex_o<=Rd_id_ex_i;
                    Rs1_id_ex_o<=Rs1_id_ex_i;
                    Rs2_id_ex_o<=Rs2_id_ex_i;

                    ALU_DA_signal_id_ex_o<=ALU_DA_signal_id_ex_i;                
                    ALU_DB_signal_id_ex_o<=ALU_DB_signal_id_ex_i;
                    ALUctl_id_ex_o<=ALUctl_id_ex_i;
                    B_type_id_ex_o<=B_type_id_ex_i;
                    beq_id_ex_o<=beq_id_ex_i;
                    bne_id_ex_o<=bne_id_ex_i;
                    blt_id_ex_o<=blt_id_ex_i;
                    bge_id_ex_o<=bge_id_ex_i;
                    bltu_id_ex_o<=bltu_id_ex_i;
                    bgeu_id_ex_o<=bgeu_id_ex_i;
                    jal_id_ex_o<=jal_id_ex_i;
                    jalr_id_ex_o<=jalr_id_ex_i;
                    RegWrite_id_ex_o<=RegWrite_id_ex_i;
                    MemRead_id_ex_o<=MemRead_id_ex_i;
                    MemWrite_id_ex_o<=MemWrite_id_ex_i;
                    RW_type_id_ex_o<=RW_type_id_ex_i;
                end
        end
endmodule