module instr_memory(
	input  [31:0]addr,
	output [31:0]instr
    );

	reg[31:0] ROM[30'h3fffffff:0];
	
    initial begin
        $readmemb("C:/Users/polar/Documents/CPU/CPU.srcs/sources_1/imports/src/rom_binary_file.txt", ROM);
    end
	
	wire [29:0]addr1;
	assign addr1 = addr[31:2];
	
    assign instr = ROM[addr[31:2]];
endmodule