`include "define.v"

// Read and write by word to avoid generating adders
module memory(
	input  clk,
	input  rst_n,
	
    input  [31:0]rom_addr,
    output [31:0]instr,

	input  W_en,
	input  R_en,
	input  [31:0]ram_addr,
	input  [2:0]RW_type,
	input  [31:0]din,
	output [31:0]dout
    );

 	wire [31:0]Wr_data;
  	wire [31:0]Rd_data;	
    RAM RAM_inst(
        .clk(clk),
        .rst_n(rst_n),

        .rom_addr(rom_addr),
        .instr(instr),

        .ram_addr(ram_addr),
        .din(Wr_data),
        .dout(Rd_data),
        .W_en(W_en)
    );

	reg  [31:0]Wr_data_B;
	wire [31:0]Wr_data_H;
    always@(*)
    begin
        case(ram_addr[1:0])
            2'b00:Wr_data_B={Rd_data[31:8],din[7:0]};
            2'b01:Wr_data_B={Rd_data[31:16],din[7:0],Rd_data[7:0]};
            2'b10:Wr_data_B={Rd_data[31:24],din[7:0],Rd_data[15:0]};
            2'b11:Wr_data_B={din[7:0],Rd_data[23:0]};
        endcase
    end      
    assign Wr_data_H=(ram_addr[1]) ? {din[15:0],Rd_data[15:0]} : {Rd_data[31:16],din[15:0]};
    assign Wr_data=(RW_type[1:0]==2'b00) ? Wr_data_B :((RW_type[1:0]==2'b01) ? Wr_data_H : din);
        

    reg [7:0]Rd_data_B;
    wire [15:0]Rd_data_H;
    wire [31:0]Rd_data_B_ext;
    wire [31:0]Rd_data_H_ext;
        
    always@(*)
    begin
        case(ram_addr[1:0])
            2'b00:Rd_data_B=Rd_data[7:0];
            2'b01:Rd_data_B=Rd_data[15:8];
            2'b10:Rd_data_B=Rd_data[23:16];
            2'b11:Rd_data_B=Rd_data[31:24];
        endcase
    end   
    assign Rd_data_B_ext=(RW_type[2]) ? {24'd0,Rd_data_B} : {{24{Rd_data_B[7]}},Rd_data_B};
        
    assign Rd_data_H=(ram_addr[1]) ? Rd_data[31:16] : Rd_data[15:0];
    assign Rd_data_H_ext=(RW_type[2]) ? {16'd0,Rd_data_H} : {{16{Rd_data_H[15]}},Rd_data_H};
        
    assign dout=(RW_type[1:0]==2'b00) ? Rd_data_B_ext : ((RW_type[1:0]==2'b01) ? Rd_data_H_ext : Rd_data);
endmodule


module RAM(
    input  clk,
    input  rst_n,

    input  [31:0]rom_addr,
    output [31:0]instr,

    input  W_en,
    input  [31:0]ram_addr,
    input  [31:0]din,
    output [31:0]dout
);

    reg [31:0]RAM1[24'hffffff:0];
    reg [31:0]RAM2[24'hffffff:0];
    reg [31:0]RAM3[24'hffffff:0];
    reg [31:0]RAM4[24'hffffff:0];
    reg [31:0]RAM5[24'hffffff:0];
    reg [31:0]RAM6[24'hffffff:0];
    reg [31:0]RAM7[24'hffffff:0];
    reg [31:0]RAM8[24'hffffff:0];
    reg [31:0]RAM9[24'hffffff:0];
    reg [31:0]RAM10[24'hffffff:0];
    reg [31:0]RAM11[24'hffffff:0];
    reg [31:0]RAM12[24'hffffff:0];
    reg [31:0]RAM13[24'hffffff:0];
    reg [31:0]RAM14[24'hffffff:0];
    reg [31:0]RAM15[24'hffffff:0];
    reg [31:0]RAM16[24'hffffff:0];
    reg [31:0]RAM17[24'hffffff:0];
    reg [31:0]RAM18[24'hffffff:0];
    reg [31:0]RAM19[24'hffffff:0];
    reg [31:0]RAM20[24'hffffff:0];
    reg [31:0]RAM21[24'hffffff:0];
    reg [31:0]RAM22[24'hffffff:0];
    reg [31:0]RAM23[24'hffffff:0];
    reg [31:0]RAM24[24'hffffff:0];
    reg [31:0]RAM25[24'hffffff:0];
    reg [31:0]RAM26[24'hffffff:0];
    reg [31:0]RAM27[24'hffffff:0];
    reg [31:0]RAM28[24'hffffff:0];
    reg [31:0]RAM29[24'hffffff:0];
    reg [31:0]RAM30[24'hffffff:0];
    reg [31:0]RAM31[24'hffffff:0];
    reg [31:0]RAM32[24'hffffff:0];
    reg [31:0]RAM33[24'hffffff:0];
    reg [31:0]RAM34[24'hffffff:0];
    reg [31:0]RAM35[24'hffffff:0];
    reg [31:0]RAM36[24'hffffff:0];
    reg [31:0]RAM37[24'hffffff:0];
    reg [31:0]RAM38[24'hffffff:0];
    reg [31:0]RAM39[24'hffffff:0];
    reg [31:0]RAM40[24'hffffff:0];
    reg [31:0]RAM41[24'hffffff:0];
    reg [31:0]RAM42[24'hffffff:0];
    reg [31:0]RAM43[24'hffffff:0];
    reg [31:0]RAM44[24'hffffff:0];
    reg [31:0]RAM45[24'hffffff:0];
    reg [31:0]RAM46[24'hffffff:0];
    reg [31:0]RAM47[24'hffffff:0];
    reg [31:0]RAM48[24'hffffff:0];
    reg [31:0]RAM49[24'hffffff:0];
    reg [31:0]RAM50[24'hffffff:0];
    reg [31:0]RAM51[24'hffffff:0];
    reg [31:0]RAM52[24'hffffff:0];
    reg [31:0]RAM53[24'hffffff:0];
    reg [31:0]RAM54[24'hffffff:0];
    reg [31:0]RAM55[24'hffffff:0];
    reg [31:0]RAM56[24'hffffff:0];
    reg [31:0]RAM57[24'hffffff:0];
    reg [31:0]RAM58[24'hffffff:0];
    reg [31:0]RAM59[24'hffffff:0];
    reg [31:0]RAM60[24'hffffff:0];
    reg [31:0]RAM61[24'hffffff:0];
    reg [31:0]RAM62[24'hffffff:0];
    reg [31:0]RAM63[24'hffffff:0];
    reg [31:0]RAM64[24'hffffff:0];

    initial begin
        $readmemb("C:/Users/polar/Documents/CPU/CPU.srcs/sources_1/imports/src/rom_binary_file.txt", RAM1);
    end

    wire [63:0]rom_select, ram_select;
    chip_select rom_select_inst(
        .addr(rom_addr),
        .signal(rom_select)
    );
    chip_select ram_select_inst(
        .addr(ram_addr),
        .signal(ram_select)
    );

    parallel_mux #(
        .WIDTH(32),
        .MUX_QUANTITY(64)
    ) rom_mux64_inst(
        .din({RAM64[rom_addr[25:2]], RAM63[rom_addr[25:2]], RAM62[rom_addr[25:2]], RAM61[rom_addr[25:2]], RAM60[rom_addr[25:2]], RAM59[rom_addr[25:2]], RAM58[rom_addr[25:2]], RAM57[rom_addr[25:2]], RAM56[rom_addr[25:2]], RAM55[rom_addr[25:2]], RAM54[rom_addr[25:2]], RAM53[rom_addr[25:2]], RAM52[rom_addr[25:2]], RAM51[rom_addr[25:2]], RAM50[rom_addr[25:2]], RAM49[rom_addr[25:2]], RAM48[rom_addr[25:2]], RAM47[rom_addr[25:2]], RAM46[rom_addr[25:2]], RAM45[rom_addr[25:2]], RAM44[rom_addr[25:2]], RAM43[rom_addr[25:2]], RAM42[rom_addr[25:2]], RAM41[rom_addr[25:2]], RAM40[rom_addr[25:2]], RAM39[rom_addr[25:2]], RAM38[rom_addr[25:2]], RAM37[rom_addr[25:2]], RAM36[rom_addr[25:2]], RAM35[rom_addr[25:2]], RAM34[rom_addr[25:2]], RAM33[rom_addr[25:2]], RAM32[rom_addr[25:2]], RAM31[rom_addr[25:2]], RAM30[rom_addr[25:2]], RAM29[rom_addr[25:2]], RAM28[rom_addr[25:2]], RAM27[rom_addr[25:2]], RAM26[rom_addr[25:2]], RAM25[rom_addr[25:2]], RAM24[rom_addr[25:2]], RAM23[rom_addr[25:2]], RAM22[rom_addr[25:2]], RAM21[rom_addr[25:2]], RAM20[rom_addr[25:2]], RAM19[rom_addr[25:2]], RAM18[rom_addr[25:2]], RAM17[rom_addr[25:2]], RAM16[rom_addr[25:2]], RAM15[rom_addr[25:2]], RAM14[rom_addr[25:2]], RAM13[rom_addr[25:2]], RAM12[rom_addr[25:2]], RAM11[rom_addr[25:2]], RAM10[rom_addr[25:2]], RAM9[rom_addr[25:2]], RAM8[rom_addr[25:2]], RAM7[rom_addr[25:2]], RAM6[rom_addr[25:2]], RAM5[rom_addr[25:2]], RAM4[rom_addr[25:2]], RAM3[rom_addr[25:2]], RAM2[rom_addr[25:2]], RAM1[rom_addr[25:2]]}),
        .signal(rom_select),
        .dout(instr)
    );

    parallel_mux #(
        .WIDTH(32),
        .MUX_QUANTITY(64)
    ) ram_mux64_inst(
        .din({RAM64[ram_addr[25:2]], RAM63[ram_addr[25:2]], RAM62[ram_addr[25:2]], RAM61[ram_addr[25:2]], RAM60[ram_addr[25:2]], RAM59[ram_addr[25:2]], RAM58[ram_addr[25:2]], RAM57[ram_addr[25:2]], RAM56[ram_addr[25:2]], RAM55[ram_addr[25:2]], RAM54[ram_addr[25:2]], RAM53[ram_addr[25:2]], RAM52[ram_addr[25:2]], RAM51[ram_addr[25:2]], RAM50[ram_addr[25:2]], RAM49[ram_addr[25:2]], RAM48[ram_addr[25:2]], RAM47[ram_addr[25:2]], RAM46[ram_addr[25:2]], RAM45[ram_addr[25:2]], RAM44[ram_addr[25:2]], RAM43[ram_addr[25:2]], RAM42[ram_addr[25:2]], RAM41[ram_addr[25:2]], RAM40[ram_addr[25:2]], RAM39[ram_addr[25:2]], RAM38[ram_addr[25:2]], RAM37[ram_addr[25:2]], RAM36[ram_addr[25:2]], RAM35[ram_addr[25:2]], RAM34[ram_addr[25:2]], RAM33[ram_addr[25:2]], RAM32[ram_addr[25:2]], RAM31[ram_addr[25:2]], RAM30[ram_addr[25:2]], RAM29[ram_addr[25:2]], RAM28[ram_addr[25:2]], RAM27[ram_addr[25:2]], RAM26[ram_addr[25:2]], RAM25[ram_addr[25:2]], RAM24[ram_addr[25:2]], RAM23[ram_addr[25:2]], RAM22[ram_addr[25:2]], RAM21[ram_addr[25:2]], RAM20[ram_addr[25:2]], RAM19[ram_addr[25:2]], RAM18[ram_addr[25:2]], RAM17[ram_addr[25:2]], RAM16[ram_addr[25:2]], RAM15[ram_addr[25:2]], RAM14[ram_addr[25:2]], RAM13[ram_addr[25:2]], RAM12[ram_addr[25:2]], RAM11[ram_addr[25:2]], RAM10[ram_addr[25:2]], RAM9[ram_addr[25:2]], RAM8[ram_addr[25:2]], RAM7[ram_addr[25:2]], RAM6[ram_addr[25:2]], RAM5[ram_addr[25:2]], RAM4[ram_addr[25:2]], RAM3[ram_addr[25:2]], RAM2[ram_addr[25:2]], RAM1[ram_addr[25:2]]}),
        .signal(ram_select),
        .dout(dout)
    );

    always @(posedge clk)
    begin
        if(rst_n && W_en)
        begin
            if(ram_select[0])  RAM1[ram_addr[25:2]]  <= din;
            if(ram_select[1])  RAM2[ram_addr[25:2]]  <= din;
            if(ram_select[2])  RAM3[ram_addr[25:2]]  <= din;
            if(ram_select[3])  RAM4[ram_addr[25:2]]  <= din;
            if(ram_select[4])  RAM5[ram_addr[25:2]]  <= din;
            if(ram_select[5])  RAM6[ram_addr[25:2]]  <= din;
            if(ram_select[6])  RAM7[ram_addr[25:2]]  <= din;
            if(ram_select[7])  RAM8[ram_addr[25:2]]  <= din;
            if(ram_select[8])  RAM9[ram_addr[25:2]]  <= din;
            if(ram_select[9])  RAM10[ram_addr[25:2]] <= din;
            if(ram_select[10]) RAM11[ram_addr[25:2]] <= din;
            if(ram_select[11]) RAM12[ram_addr[25:2]] <= din;
            if(ram_select[12]) RAM13[ram_addr[25:2]] <= din;
            if(ram_select[13]) RAM14[ram_addr[25:2]] <= din;
            if(ram_select[14]) RAM15[ram_addr[25:2]] <= din;
            if(ram_select[15]) RAM16[ram_addr[25:2]] <= din;
            if(ram_select[16]) RAM17[ram_addr[25:2]] <= din;
            if(ram_select[17]) RAM18[ram_addr[25:2]] <= din;
            if(ram_select[18]) RAM19[ram_addr[25:2]] <= din;
            if(ram_select[19]) RAM20[ram_addr[25:2]] <= din;
            if(ram_select[20]) RAM21[ram_addr[25:2]] <= din;
            if(ram_select[21]) RAM22[ram_addr[25:2]] <= din;
            if(ram_select[22]) RAM23[ram_addr[25:2]] <= din;
            if(ram_select[23]) RAM24[ram_addr[25:2]] <= din;
            if(ram_select[24]) RAM25[ram_addr[25:2]] <= din;
            if(ram_select[25]) RAM26[ram_addr[25:2]] <= din;
            if(ram_select[26]) RAM27[ram_addr[25:2]] <= din;
            if(ram_select[27]) RAM28[ram_addr[25:2]] <= din;
            if(ram_select[28]) RAM29[ram_addr[25:2]] <= din;
            if(ram_select[29]) RAM30[ram_addr[25:2]] <= din;
            if(ram_select[30]) RAM31[ram_addr[25:2]] <= din;
            if(ram_select[31]) RAM32[ram_addr[25:2]] <= din;
            if(ram_select[32]) RAM33[ram_addr[25:2]] <= din;
            if(ram_select[33]) RAM34[ram_addr[25:2]] <= din;
            if(ram_select[34]) RAM35[ram_addr[25:2]] <= din;
            if(ram_select[35]) RAM36[ram_addr[25:2]] <= din;
            if(ram_select[36]) RAM37[ram_addr[25:2]] <= din;
            if(ram_select[37]) RAM38[ram_addr[25:2]] <= din;
            if(ram_select[38]) RAM39[ram_addr[25:2]] <= din;
            if(ram_select[39]) RAM40[ram_addr[25:2]] <= din;
            if(ram_select[40]) RAM41[ram_addr[25:2]] <= din;
            if(ram_select[41]) RAM42[ram_addr[25:2]] <= din;
            if(ram_select[42]) RAM43[ram_addr[25:2]] <= din;
            if(ram_select[43]) RAM44[ram_addr[25:2]] <= din;
            if(ram_select[44]) RAM45[ram_addr[25:2]] <= din;
            if(ram_select[45]) RAM46[ram_addr[25:2]] <= din;
            if(ram_select[46]) RAM47[ram_addr[25:2]] <= din;
            if(ram_select[47]) RAM48[ram_addr[25:2]] <= din;
            if(ram_select[48]) RAM49[ram_addr[25:2]] <= din;
            if(ram_select[49]) RAM50[ram_addr[25:2]] <= din;
            if(ram_select[50]) RAM51[ram_addr[25:2]] <= din;
            if(ram_select[51]) RAM52[ram_addr[25:2]] <= din;
            if(ram_select[52]) RAM53[ram_addr[25:2]] <= din;
            if(ram_select[53]) RAM54[ram_addr[25:2]] <= din;
            if(ram_select[54]) RAM55[ram_addr[25:2]] <= din;
            if(ram_select[55]) RAM56[ram_addr[25:2]] <= din;
            if(ram_select[56]) RAM57[ram_addr[25:2]] <= din;
            if(ram_select[57]) RAM58[ram_addr[25:2]] <= din;
            if(ram_select[58]) RAM59[ram_addr[25:2]] <= din;
            if(ram_select[59]) RAM60[ram_addr[25:2]] <= din;
            if(ram_select[60]) RAM61[ram_addr[25:2]] <= din;
            if(ram_select[61]) RAM62[ram_addr[25:2]] <= din;
            if(ram_select[62]) RAM63[ram_addr[25:2]] <= din;
            if(ram_select[63]) RAM64[ram_addr[25:2]] <= din;
        end
    end
endmodule


module chip_select(
    input [31:0]addr,
    output reg [63:0]signal
);

    always @(*)
    begin
        case(addr[31:26])
            6'h00: signal = 64'h0000000000000001;
            6'h01: signal = 64'h0000000000000002;
            6'h02: signal = 64'h0000000000000004;
            6'h03: signal = 64'h0000000000000008;
            6'h04: signal = 64'h0000000000000010;
            6'h05: signal = 64'h0000000000000020;
            6'h06: signal = 64'h0000000000000040;
            6'h07: signal = 64'h0000000000000080;
            6'h08: signal = 64'h0000000000000100;
            6'h09: signal = 64'h0000000000000200;
            6'h0A: signal = 64'h0000000000000400;
            6'h0B: signal = 64'h0000000000000800;
            6'h0C: signal = 64'h0000000000001000;
            6'h0D: signal = 64'h0000000000002000;
            6'h0E: signal = 64'h0000000000004000;
            6'h0F: signal = 64'h0000000000008000;
            6'h10: signal = 64'h0000000000010000;
            6'h11: signal = 64'h0000000000020000;
            6'h12: signal = 64'h0000000000040000;
            6'h13: signal = 64'h0000000000080000;
            6'h14: signal = 64'h0000000000100000;
            6'h15: signal = 64'h0000000000200000;
            6'h16: signal = 64'h0000000000400000;
            6'h17: signal = 64'h0000000000800000;
            6'h18: signal = 64'h0000000001000000;
            6'h19: signal = 64'h0000000002000000;
            6'h1A: signal = 64'h0000000004000000;
            6'h1B: signal = 64'h0000000008000000;
            6'h1C: signal = 64'h0000000010000000;
            6'h1D: signal = 64'h0000000020000000;
            6'h1E: signal = 64'h0000000040000000;
            6'h1F: signal = 64'h0000000080000000;
            6'h20: signal = 64'h0000000100000000;
            6'h21: signal = 64'h0000000200000000;
            6'h22: signal = 64'h0000000400000000;
            6'h23: signal = 64'h0000000800000000;
            6'h24: signal = 64'h0000001000000000;
            6'h25: signal = 64'h0000002000000000;
            6'h26: signal = 64'h0000004000000000;
            6'h27: signal = 64'h0000008000000000;
            6'h28: signal = 64'h0000010000000000;
            6'h29: signal = 64'h0000020000000000;
            6'h2A: signal = 64'h0000040000000000;
            6'h2B: signal = 64'h0000080000000000;
            6'h2C: signal = 64'h0000100000000000;
            6'h2D: signal = 64'h0000200000000000;
            6'h2E: signal = 64'h0000400000000000;
            6'h2F: signal = 64'h0000800000000000;
            6'h30: signal = 64'h0001000000000000;
            6'h31: signal = 64'h0002000000000000;
            6'h32: signal = 64'h0004000000000000;
            6'h33: signal = 64'h0008000000000000;
            6'h34: signal = 64'h0010000000000000;
            6'h35: signal = 64'h0020000000000000;
            6'h36: signal = 64'h0040000000000000;
            6'h37: signal = 64'h0080000000000000;
            6'h38: signal = 64'h0100000000000000;
            6'h39: signal = 64'h0200000000000000;
            6'h3A: signal = 64'h0400000000000000;
            6'h3B: signal = 64'h0800000000000000;
            6'h3C: signal = 64'h1000000000000000;
            6'h3D: signal = 64'h2000000000000000;
            6'h3E: signal = 64'h4000000000000000;
            6'h3F: signal = 64'h8000000000000000;
        endcase
    end    
endmodule