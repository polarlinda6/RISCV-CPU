`include "define.v"

module control(
	input  [4:0]Rd,
	input  [6:0]opcode,
	input  [2:0]func3,
	input  func7,
	
	output RegWrite, 
	output MemRead,
	output MemWrite,
	output ALU_DA_imme_signal,
	output ALU_DA_pc_signal,
	
	output B_type,
	output beq,
	output bne,
	output blt,
	output bge,
	output bltu,
	output bgeu,
	output jal,
	output jalr,
	
	output [2:0]RW_type,
	output [3:0]ALUctl,

	output unknown_instr_warning_main_decode
  );
	
	wire R_type;
	wire I_type;
	
	main_control main_control_inst(
		.Rd(Rd),
		.opcode(opcode),
		.func3(func3),
		
		.RegWrite(RegWrite),
		.MemRead(MemRead),
		.MemWrite(MemWrite),
		.ALU_DA_imme_signal(ALU_DA_imme_signal),
		.ALU_DA_pc_signal(ALU_DA_pc_signal),
		
		.beq(beq),
		.bne(bne),
		.blt(blt),
		.bge(bge),
		.bltu(bltu),
		.bgeu(bgeu),
		.jal(jal),
		.jalr(jalr),
		
		.RW_type(RW_type),
		
		.B_type(B_type),
		.R_type(R_type),
		.I_type(I_type),

		.unknown_instr_warning_main_decode(unknown_instr_warning_main_decode)
		);
	
	ALU_control ALU_control_inst(
		.B_type(B_type),
		.R_type(R_type),
		.I_type(I_type),
		
		.func3(func3),
		.func7(func7),
		
		.ALUctl(ALUctl)
		);
	
endmodule

module main_control(
	input  [4:0]Rd,
	input  [6:0]opcode,
	input  [2:0]func3,
	
	output RegWrite,
	output MemRead,
	output MemWrite,
	output ALU_DA_imme_signal,
	output ALU_DA_pc_signal,
	
	output beq,
	output bne,
	output blt,
	output bge,
	output bltu,
	output bgeu,
	output jal,
	output jalr,
	
	output [2:0]RW_type,
	
	output B_type,
	output R_type, 
	output I_type,

	output unknown_instr_warning_main_decode
);

	wire lui, auipc;
	wire load, store;

	assign unknown_instr_warning_main_decode = !(lui || auipc || jal || jalr || B_type || load || store || I_type || R_type);
	
	assign B_type=(opcode==`B_type);
	assign R_type=(opcode==`R_type);
	assign I_type=(opcode==`I_type);
	
	assign load=(opcode==`load);
	assign store=(opcode==`S_type);	
	
	assign lui=(opcode==`lui);
	assign auipc=(opcode==`auipc);
	
	assign jal = (opcode==`jal);
	assign jalr= (opcode==`jalr);
	assign beq = B_type && (func3==3'b000);
	assign bne = B_type && (func3==3'b001);
	assign blt = B_type && (func3==3'b100);
	assign bge = B_type && (func3==3'b101);
	assign bltu= B_type && (func3==3'b110);
	assign bgeu= B_type && (func3==3'b111);
	
	assign RW_type=func3;
	
	//MUX
	assign ALU_DA_pc_signal   = auipc;
	assign ALU_DA_imme_signal = lui || auipc || jalr || load || store || I_type;  //select imme	

	//enable
	wire RegWrite_instr_or;
	assign RegWrite= Rd && RegWrite_instr_or;	
	assign MemRead= load;
	assign MemWrite= store;

	large_fan_in_or #(
		.WIDTH(1),
		.OR_QUANTITY(7)
	) RegWrite_instr_or_inst(
		.din({lui, auipc, jal, jalr, load, I_type, R_type}),
		.dout(RegWrite_instr_or)
	);
endmodule


module ALU_control(
  input  B_type,
	input  R_type,
	input  I_type,
	
	input  [2:0]func3,
	input  func7,
	
	output [3:0]ALUctl
);
	
	wire [3:0]branchop;
	reg  [3:0]RIop;
	
	always@(*) begin
		case(func3)
			3'b000: RIop= (R_type & func7) ? `SUB : `ADD;
			3'b001: RIop= `SLL;
			3'b010: RIop= `SLT;
			3'b011: RIop= `SLTU;
			3'b100: RIop= `XOR;
			3'b101: RIop= func7 ? `SRA : `SRL;
			3'b110: RIop= `OR;
			3'b111: RIop= `AND;
		endcase
	end
	
	assign branchop= func3[1] ? `SLTU : (func3[2] ? `SLT : `SUB);
	
	//ADD: jalr, load, and store instructions calculate addresses.
	assign ALUctl= (R_type || I_type) ? RIop : (B_type ? branchop : `ADD);
endmodule