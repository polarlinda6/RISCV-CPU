module instr_memory(
	input  [7:0]addr,
	output [31:0]instr
    );

	reg[31:0] ROM[255:0];
	
    initial begin
        $readmemb("C:/Users/polar/Documents/CPU/CPU.srcs/sources_1/imports/src/rom_binary_file.txt", ROM);
    end
	
    assign instr = ROM[addr];
endmodule