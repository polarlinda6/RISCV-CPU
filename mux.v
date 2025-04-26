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
	output [WIDTH - 1:0]dout
);

	localparam WIDTH_UB = WIDTH - 1;
	localparam ZERO = {WIDTH{1'b0}};


	wire [MUX_QUANTITY - 1:0]result[WIDTH_UB:0];

	generate
		genvar i, j;
		for (i = 0; i < MUX_QUANTITY; i = i + 1) 
		begin
			localparam lb = WIDTH * i;
			localparam ub = lb + WIDTH - 1;

			wire [WIDTH_UB:0]result_inner;
			assign result_inner = signal[i] ? data[ub: lb] : ZERO;

			for(j = 0; j < WIDTH; j = j + 1)
			begin
				assign result[j][i] = result_inner[j];
			end
		end

		for (i = 0; i < WIDTH; i = i + 1)
		begin 
			assign dout[i] = |result[i];
		end
	endgenerate
endmodule