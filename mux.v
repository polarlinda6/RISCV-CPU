module mux #(
	parameter WIDTH = 32
)(
	input  [WIDTH - 1:0]data1,
	input  [WIDTH - 1:0]data2,
	input  signal,
	output [WIDTH - 1:0]dout
    );
	
	assign dout = signal ? data1 : data2;
endmodule


module mux3 #(
	parameter WIDTH = 32
)(
	input  [WIDTH - 1:0]data1,
	input  [WIDTH - 1:0]data2,
	input  [WIDTH - 1:0]data3,
	input  [1:0]signal,
	output [WIDTH - 1:0]dout
    );
	
	assign dout = signal[1] ? data1 : 
	              signal[0] ? data2 : data3;
endmodule


module parallel_mux #(
    parameter WIDTH = 32,
    parameter MUX_QUANTITY = 4
)(
    input  [WIDTH * MUX_QUANTITY - 1:0]data,
    input  [MUX_QUANTITY - 1:0]signal,
    output [WIDTH - 1:0] dout
);

    localparam ZERO = {WIDTH{1'b0}};


    wire [WIDTH - 1:0]result[MUX_QUANTITY - 1:0];

    generate
			genvar i;
			for (i = 0; i < MUX_QUANTITY; i = i + 1) 
			begin
				localparam lb = WIDTH * i;
				localparam ub = lb + WIDTH - 1;
				assign result[i] = signal[i] ? data[ub: lb] : ZERO;
			end

			for (i = 0; i < MUX_QUANTITY; i = i + 1)
			begin 
	      assign dout = dout | signal[i];
		  end
  	endgenerate
endmodule