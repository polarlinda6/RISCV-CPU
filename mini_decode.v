`include "define.v"

module mini_decode(
 	input [31:0]instr,
	
 	output jal,
 	output jalr, 	
 	output B_type,  
  output beq, 
  output bne, 
  output blt,
  output bge,
  output bltu,
  output bgeu,
 	
 	output [4:0]Rs1,
	output [4:0]Rs2,	 	
  
  output [4:0]Rd,
  output [2:0]func3,
 	output [31:0]imme
 	);
  
 	assign Rd   = instr[11:7]; 	
 	assign Rs1  = instr[19:15];
	assign Rs2  = instr[24:20];
	assign func3= instr[14:12];


	wire [6:0]opcode;
	assign opcode=instr[6:0];

 	assign jal   = (opcode==`jal);
 	assign jalr  = (opcode==`jalr);
 	assign B_type= (opcode==`B_type);

	assign beq = B_type && (func3==3'b000);
	assign bne = B_type && (func3==3'b001);
	assign blt = B_type && (func3==3'b100);
	assign bge = B_type && (func3==3'b101);
	assign bltu= B_type && (func3==3'b110);
	assign bgeu= B_type && (func3==3'b111);


  wire [31:0]jal_imme, jalr_imme, B_imme;
 	assign jal_imme=  {{12{instr[31]}},instr[19:12],instr[20],instr[30:21],1'b0};   
 	assign jalr_imme= {{20{instr[31]}},instr[31:20]}; 
 	assign B_imme=    {{20{instr[31]}},instr[7],instr[30:25],instr[11:8],1'b0};

 	
 	assign imme=jal ? jal_imme : 
              jalr ? jalr_imme : B_imme;
endmodule
