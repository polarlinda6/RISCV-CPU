module mux #(
	parameter WIDTH = 32
)(
	input  [WIDTH - 1:0]din1,
	input  [WIDTH - 1:0]din2,
	input  signal,
	output [WIDTH - 1:0]dout
  );
	
	assign dout = signal ? din1 : din2;
endmodule


module mux3 #(
	parameter WIDTH = 32
)(
	input  [WIDTH - 1:0]din1,
	input  [WIDTH - 1:0]din2,
	input  [WIDTH - 1:0]din3,
	input  [1:0]signal,
	output [WIDTH - 1:0]dout
  );
	
	assign dout = signal[1] ? din1 : 
	              signal[0] ? din2 : din3;
endmodule


module parallel_mux #(
	parameter WIDTH = 32,
	parameter MUX_QUANTITY = 4
)(
	input  [WIDTH * MUX_QUANTITY - 1:0]din,
	input  [MUX_QUANTITY - 1:0]signal,
	output [WIDTH - 1:0]dout
);

	localparam ZERO = {WIDTH{1'b0}};

	wire [WIDTH * MUX_QUANTITY - 1:0]result;

	generate
		genvar i;
		for (i = 0; i < MUX_QUANTITY; i = i + 1) 
		begin
			localparam lb = WIDTH * i;
			localparam ub = lb + WIDTH - 1;

			assign result[ub:lb] = signal[i] ? din[ub:lb] : ZERO;
		end
	endgenerate

	large_fan_in_or #(
		.WIDTH(WIDTH),
		.OR_QUANTITY(MUX_QUANTITY)
	) or_inst(
		.din(result),
		.dout(dout)
	);
endmodule