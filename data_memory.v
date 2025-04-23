`include "define.v"

// Read and write by word to avoid generating adders
module data_memory(
	input  clk,
	input  rst_n,
	
	input  W_en,
	input  R_en,
	input  [31:0]addr,
	input  [2:0]RW_type,
	input  [31:0]din,
	output [31:0]dout
    );

	reg [31:0]RAM[255:0];	
	wire [31:0]Rd_data;	
	assign Rd_data=RAM[addr[9:2]]; //Circular Address
	
	
	integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) RAM[i]=`zeroword;
    end
	
	
	reg [31:0]Wr_data_B;
	wire [31:0]Wr_data_H;
	wire [31:0]Wr_data;
	
    always@(*)
    begin
        case(addr[1:0])
            2'b00:Wr_data_B={Rd_data[31:8],din[7:0]};
            2'b01:Wr_data_B={Rd_data[31:16],din[7:0],Rd_data[7:0]};
            2'b10:Wr_data_B={Rd_data[31:24],din[7:0],Rd_data[15:0]};
            2'b11:Wr_data_B={din[7:0],Rd_data[23:0]};
        endcase
    end      
    assign Wr_data_H=(addr[1]) ? {din[15:0],Rd_data[15:0]} : {Rd_data[31:16],din[15:0]};
    assign Wr_data=(RW_type[1:0]==2'b00) ? Wr_data_B :((RW_type[1:0]==2'b01) ? Wr_data_H : din);
    
    always@(posedge clk)
    begin
        if(W_en) RAM[addr[9:2]] <= Wr_data; //Circular Address
    end


    reg [7:0]Rd_data_B;
    wire [15:0]Rd_data_H;
    wire [31:0]Rd_data_B_ext;
    wire [31:0]Rd_data_H_ext;
    
    always@(*)
    begin
        case(addr[1:0])
            2'b00:Rd_data_B=Rd_data[7:0];
            2'b01:Rd_data_B=Rd_data[15:8];
            2'b10:Rd_data_B=Rd_data[23:16];
            2'b11:Rd_data_B=Rd_data[31:24];
        endcase
    end   
    assign Rd_data_B_ext=(RW_type[2]) ? {24'd0,Rd_data_B} : {{24{Rd_data_B[7]}},Rd_data_B};
    
    assign Rd_data_H=(addr[1]) ? Rd_data[31:16] : Rd_data[15:0];
    assign Rd_data_H_ext=(RW_type[2]) ? {16'd0,Rd_data_H} : {{16{Rd_data_H[15]}},Rd_data_H};
    
    assign dout=(RW_type[1:0]==2'b00) ? Rd_data_B_ext : ((RW_type[1:0]==2'b01) ? Rd_data_H_ext : Rd_data);
endmodule