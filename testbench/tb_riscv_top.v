`timescale 1ns / 1ps

module tb_riscv_top;
	reg clk;
	reg rst_n;
	wire stat_beq;
	wire stat_bne;
	wire stat_blt;
	wire stat_bge;
	wire stat_bltu;
	wire stat_bgeu;
	wire stat_jal;
	wire stat_jalr;
	wire stat_PL_flush;
	wire stat_PL_stall_if;	
    wire stat_PL_stall_ex;
	wire stat_ecall;
	wire Rd_x_warning_ram;
    wire unknown_instr_warning_main_decode;

	riscv_top uut (
        .clk(clk), 
        .rst_n(rst_n),
        
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
        
        .Rd_x_warning_ram(Rd_x_warning_ram),
        .unknown_instr_warning_main_decode(unknown_instr_warning_main_decode)
        );


    initial begin
        clk = 0;
        rst_n = 0;

        #100;
        rst_n = 1;
    end
    
    //50MHz
    always #10 clk= ~clk;

    reg ecall_reg;
    integer clk_total;
    integer instr_total;    
    integer stall_if_total;
    integer stall_ex_total;
    always @(posedge clk) begin
        if (!rst_n) begin            
            ecall_reg      = 0;
            clk_total      = 0;
            instr_total    = 0;
            stall_if_total = 0;
            stall_ex_total = 0;
        end else begin 
            if(ecall_reg || stat_ecall)
                ecall_reg = 1;
            else begin
                clk_total = clk_total + 1;                
                stall_if_total = stall_if_total + (stat_PL_stall_if ? 1 : 0);
                stall_ex_total = stall_ex_total + (stat_PL_stall_ex ? 1 : 0);
                instr_total = instr_total + (stat_PL_stall_if || stat_PL_stall_ex ? 0 : stat_PL_flush ? -2 : 1); 
            end 
        end
    end
    
    
    
    integer prediction_total[8:0];
    integer prediction_failed[8:0];

    always @(posedge clk) begin
        if (!rst_n) begin
            prediction_total[8] = 0; prediction_failed[8] = 0; // sum
            prediction_total[7] = 0; prediction_failed[7] = 0; // beq
            prediction_total[6] = 0; prediction_failed[6] = 0; // bne
            prediction_total[5] = 0; prediction_failed[5] = 0; // blt
            prediction_total[4] = 0; prediction_failed[4] = 0; // bge
            prediction_total[3] = 0; prediction_failed[3] = 0; // bltu
            prediction_total[2] = 0; prediction_failed[2] = 0; // bgeu
            prediction_total[1] = 0; prediction_failed[1] = 0; // jal
            prediction_total[0] = 0; prediction_failed[0] = 0; // jalr
        end else begin
            if (stat_beq || stat_bne || stat_blt || stat_bge || stat_bltu || stat_bgeu || stat_jal || stat_jalr) begin 
                prediction_total[8] = prediction_total[8] + 1;
                if (stat_PL_flush) prediction_failed[8] = prediction_failed[8] + 1;
            end
            if (stat_beq) begin
                prediction_total[7] = prediction_total[7] + 1;
                if (stat_PL_flush) prediction_failed[7] = prediction_failed[7] + 1;
            end
            if (stat_bne) begin
                prediction_total[6] = prediction_total[6] + 1;
                if (stat_PL_flush) prediction_failed[6] = prediction_failed[6] + 1;
            end
            if (stat_blt) begin
                prediction_total[5] = prediction_total[5] + 1;
                if (stat_PL_flush) prediction_failed[5] = prediction_failed[5] + 1;
            end
            if (stat_bge) begin
                prediction_total[4] = prediction_total[4] + 1;
                if (stat_PL_flush) prediction_failed[4] = prediction_failed[4] + 1;
            end
            if (stat_bltu) begin
                prediction_total[3] = prediction_total[3] + 1;
                if (stat_PL_flush) prediction_failed[3] = prediction_failed[3] + 1;
            end
            if (stat_bgeu) begin
                prediction_total[2] = prediction_total[2] + 1;
                if (stat_PL_flush) prediction_failed[2] = prediction_failed[2] + 1;
            end
            if (stat_jal) begin
                prediction_total[1] = prediction_total[1] + 1;
                if (stat_PL_flush) prediction_failed[1] = prediction_failed[1] + 1;
            end
            if (stat_jalr) begin
                prediction_total[0] = prediction_total[0] + 1;
                if (stat_PL_flush) prediction_failed[0] = prediction_failed[0] + 1;
            end
        end
    end
endmodule