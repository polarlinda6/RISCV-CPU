module riscv(
	input  clk,
	input  rst_n,	
	
    output [7:0]rom_addr,
	input  [31:0]instr,
	
	output W_en,
	output R_en,
	output [2:0]RW_type,
	output [31:0]ram_addr,		
	input  [31:0]load_data,
	output [31:0]store_data
    );
	
    wire [4:0]Rd;
	wire [6:0]opcode;
	wire [2:0]func3;
	wire func7;
	wire ALU_DA_signal;	
    wire ALU_DB_signal;
    wire B_type;
	wire beq;
	wire bne;
	wire blt;
	wire bge;
	wire bltu;
	wire bgeu;	
	wire jal;
	wire jalr;
	wire [3:0]ALUctl;
    wire RegWrite;
	wire MemWrite;
	wire MemRead;
	wire [2:0]RW_type_id;
	
	
	control control_inst (
        .Rd(Rd),
        .opcode(opcode), 
        .func3(func3), 
        .func7(func7), 
        
        .RegWrite(RegWrite),
        .MemRead(MemRead), 
        .MemWrite(MemWrite), 
        .ALU_DA_signal(ALU_DA_signal),        
        .ALU_DB_signal(ALU_DB_signal), 
        .B_type(B_type),
        .beq(beq), 
        .bne(bne), 
        .blt(blt), 
        .bge(bge), 
        .bltu(bltu), 
        .bgeu(bgeu),
        .jal(jal),
        .jalr(jalr),  
        .RW_type(RW_type_id), 
        .ALUctl(ALUctl)
        );
	
	datapath datapath_inst (
        .clk(clk), 
        .rst_n(rst_n), 
        .instr(instr), 

        .ALU_DA_signal(ALU_DA_signal),        
        .ALU_DB_signal(ALU_DB_signal),
        .ALUctl(ALUctl),  
        .B_type(B_type),
        .beq(beq), 
        .bne(bne), 
        .blt(blt), 
        .bge(bge), 
        .bltu(bltu), 
        .bgeu(bgeu),
        .jal(jal),
        .jalr(jalr), 
        .RegWrite(RegWrite),
        .MemRead(MemRead), 
        .MemWrite(MemWrite), 
        .RW_type_id(RW_type_id), 
        
        .load_data(load_data), 
        .store_data(store_data),
        
        .R_en(R_en), 
        .W_en(W_en),  
        .RW_type(RW_type),  

        .rom_addr(rom_addr), 
        .ram_addr(ram_addr),
        
        .Rd(Rd),
        .opcode(opcode),
        .func3(func3),
        .func7(func7)
        );
endmodule
