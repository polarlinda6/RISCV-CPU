module riscv_top(
  input clk,
  input rst_n,

  output stat_beq,
  output stat_bne,
  output stat_blt,
  output stat_bge,
  output stat_bltu,
  output stat_bgeu,
  output stat_jal,
  output stat_jalr,
  output stat_PL_flush,
  output stat_PL_stall_if,
  output stat_PL_stall_ex,
  output stat_ecall,

  output Rd_x_warning_ram,
  output unknown_instr_warning_main_decode
);

  wire [31:0]rom_addr;
  wire [31:0]ram_addr;
  wire [31:0]instr;
  wire [31:0]load_data;
  wire [31:0]store_data;
  wire W_en;
  wire R_en;
  wire [2:0]RW_type;

  riscv riscv_inst (
    .clk(clk),
    .rst_n(rst_n),

    .rom_addr(rom_addr),
    .instr(instr),

    .W_en(W_en),
    .R_en(R_en),
    .RW_type_mem(RW_type),
    .ram_addr(ram_addr),
    .load_data(load_data),
    .store_data(store_data),

    .stat_beq(stat_beq),
    .stat_bne(stat_bne),
    .stat_blt(stat_blt),
    .stat_bge(stat_bge),
    .stat_bltu(stat_bltu),
    .stat_bgeu(stat_bgeu),
    .stat_jal(stat_jal),
    .stat_jalr(stat_jalr),
    .stat_PL_flush(stat_PL_flush),
    .stat_PL_stall_if(stat_PL_stall_if),
    .stat_PL_stall_ex(stat_PL_stall_ex),
    .stat_ecall(stat_ecall),

    .unknown_instr_warning_main_decode(unknown_instr_warning_main_decode)
    );

  memory memory_inst (
    .clk(clk),
    .rst_n(rst_n),

    .rom_addr(rom_addr),
    .instr(instr),

    .W_en(W_en),
    .R_en(R_en),
    .ram_addr(ram_addr),
    .RW_type(RW_type),
    .din(store_data),
    .dout(load_data),

    .Rd_x_warning_ram(Rd_x_warning_ram)
    );
endmodule