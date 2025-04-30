`include "define.v"

module instr_decode(
	input [31:0]instr,
	
	output [6:0]opcode,
	output [2:0]func3,
	output func7,
	output [4:0]Rs1,
	output [4:0]Rs2,
	output [4:0]Rd,
	output [31:0]imme,

	output ecall
	);
	 
	assign ecall = instr == `ecall;  


	wire I_type;
	wire U_type;
	wire J_type;
	wire B_type;
	wire S_type;
	
	wire [31:0]I_imme;
	wire [31:0]U_imme;
	wire [31:0]J_imme;
	wire [31:0]B_imme;
	wire [31:0]S_imme;
	
	
	assign opcode= instr[6:0];
	assign func3 = instr[14:12];
	assign func7 = instr[30];	
	assign Rd    = instr[11:7];
	assign Rs1   = (J_type || U_type) ? `zeroreg : instr[19:15];
	assign Rs2   = (J_type || U_type || I_type) ? `zeroreg : instr[24:20];

	
	assign I_type= (opcode==`jalr) || (opcode==`load) || (opcode==`I_type);
	assign U_type= (opcode==`lui) || (opcode==`auipc);
	assign B_type= (opcode==`B_type);
	assign S_type= (opcode==`S_type);
	assign J_type= (opcode==`jal);
	
	assign I_imme= {{20{instr[31]}},instr[31:20]}; 
	assign U_imme= {instr[31:12],{12{1'b0}}};
	assign B_imme= {{20{instr[31]}},instr[7],instr[30:25],instr[11:8],1'b0};
	assign S_imme= {{20{instr[31]}},instr[31:25],instr[11:7]}; 
	assign J_imme= {{12{instr[31]}},instr[19:12],instr[20],instr[30:21],1'b0};   	

	assign imme= I_type ? I_imme :
				       U_type ? U_imme :
				 			 B_type ? B_imme :
							 S_type ? S_imme : J_imme;
endmodule
