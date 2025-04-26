module riscv_top(
	input clk,
	input rst_n
    );

	wire [31:0]rom_addr;
	wire [31:0]ram_addr;
	wire [31:0]instr;
	wire [31:0]load_data;
	wire [31:0]store_data;
	wire W_en;
	wire R_en;
	wire [2:0]RW_type;
	
	instr_memory instr_memory_inst (
        .addr(rom_addr), 
        .instr(instr)
        );

	riscv riscv_inst (
        .clk(clk), 
        .rst_n(rst_n),    
        
        .rom_addr(rom_addr), 
        .instr(instr), 
        
        .W_en(W_en), 
        .R_en(R_en),   
        .RW_type(RW_type),
        .ram_addr(ram_addr),
        .load_data(load_data), 
        .store_data(store_data)
        );

	data_memory data_memory_inst (
        .clk(clk), 
        .rst_n(rst_n), 
        
        .W_en(W_en), 
        .R_en(R_en), 
        .addr(ram_addr), 
        .RW_type(RW_type), 
        .din(store_data), 
        .dout(load_data)
        );
endmodule