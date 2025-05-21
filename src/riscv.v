module riscv(
  input  clk,
  input  rst_n,

  output [31:0]rom_addr,
  input  [31:0]instr,

  output W_en,
  output R_en,
  output [2:0]RW_type_mem,
  output [31:0]ram_addr,
  input  [31:0]load_data,
  output [31:0]store_data,


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

  output unknown_instr_warning_main_decode
  );

  wire [4:0]Rd;
  wire [6:0]opcode;
  wire [2:0]func3;
  wire func7;
  wire ALU_DA_pc_signal;
  wire ALU_DA_imme_signal;
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
    .ALU_DA_pc_signal(ALU_DA_pc_signal),
    .ALU_DA_imme_signal(ALU_DA_imme_signal),
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
    .ALUctl(ALUctl),

    .unknown_instr_warning_main_decode(unknown_instr_warning_main_decode)
    );

  datapath datapath_inst (
    .clk(clk),
    .rst_n(rst_n),
    .instr(instr),

    .ALU_DA_pc_signal(ALU_DA_pc_signal),
    .ALU_DA_imme_signal(ALU_DA_imme_signal),
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
    .RW_type_mem(RW_type_mem),

    .rom_addr(rom_addr),
    .ram_addr(ram_addr),

    .Rd(Rd),
    .opcode(opcode),
    .func3(func3),
    .func7(func7),


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
    .stat_ecall(stat_ecall)
    );
endmodule
