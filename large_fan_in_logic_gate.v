module large_fan_in_or #(
	parameter WIDTH = 32,
	parameter OR_QUANTITY = 4
)(
	input [WIDTH * OR_QUANTITY - 1:0]din,
	output [WIDTH - 1:0]dout
);

	localparam WIDTH_UB = WIDTH - 1;
	localparam BASE_FAN_IN = 3;

	generate
	if(OR_QUANTITY <= BASE_FAN_IN)
	begin 				
		localparam lb1 = 0;
		localparam ub1 = lb1 + WIDTH_UB;
		localparam lb2 = ub1 + 1;
		localparam ub2 = lb2 + WIDTH_UB;
		localparam lb3 = ub2 + 1;
		localparam ub3 = lb3 + WIDTH_UB;

		if(OR_QUANTITY == 3)
			assign dout = din[ub1:lb1] | din[ub2:lb2] | din[ub3:lb3];
		else if(OR_QUANTITY == 2)
			assign dout = din[ub1:lb1] | din[ub2:lb2];
		else if(OR_QUANTITY == 1)
			assign dout = din;
	end
	else if(OR_QUANTITY == 4)
	begin
		localparam lb1 = 0;
		localparam ub1 = lb1 + WIDTH * 2 - 1;
		localparam lb2 = ub1 + 1;
		localparam ub2 = lb2 + WIDTH * 2 - 1;

		wire [WIDTH_UB:0]result1, result2;
		large_fan_in_or #(
			.WIDTH(WIDTH),
			.OR_QUANTITY(2)
		) large_fan_in_or2_1_inst(
			.din(din[ub1:lb1]), 
			.dout(result1)
		);
		large_fan_in_or #(
			.WIDTH(WIDTH),
			.OR_QUANTITY(2)
		) large_fan_in_or2_2_inst(
			.din(din[ub2:lb2]), 
			.dout(result2)
		);

		assign dout = result1 | result2;
	end
	else 
	begin
		localparam SPLIT_QUANTITY = OR_QUANTITY / BASE_FAN_IN + (OR_QUANTITY % BASE_FAN_IN ? 1 : 0);
		localparam REMAING_QUANTITY = OR_QUANTITY - SPLIT_QUANTITY * 2;

		wire [BASE_FAN_IN * WIDTH - 1:0]result;

		localparam lb1 = 0;
		localparam ub1 = lb1 + SPLIT_QUANTITY * WIDTH - 1;
		localparam lb2 = ub1 + 1;
		localparam ub2 = lb2 + SPLIT_QUANTITY * WIDTH - 1;
		localparam lb3 = ub2 + 1;
		localparam ub3 = WIDTH * OR_QUANTITY - 1;

		localparam rlb1 = 0;
		localparam rub1 = rlb1 + WIDTH_UB;
		localparam rlb2 = rub1 + 1;
		localparam rub2 = rlb2 + WIDTH_UB;
		localparam rlb3 = rub2 + 1;
		localparam rub3 = rlb3 + WIDTH_UB;
		
		large_fan_in_or #(
			.WIDTH(WIDTH),
			.OR_QUANTITY(SPLIT_QUANTITY)
		) large_fan_in_or1_inst(
			.din(din[ub1:lb1]), 
			.dout(result[rub1:rlb1])
		);
		large_fan_in_or #(
			.WIDTH(WIDTH),
			.OR_QUANTITY(SPLIT_QUANTITY)
		) large_fan_in_or2_inst(
			.din(din[ub2:lb2]), 
			.dout(result[rub2:rlb2])
		);
		large_fan_in_or #(
			.WIDTH(WIDTH),
			.OR_QUANTITY(REMAING_QUANTITY)
		) large_fan_in_or3_inst(
			.din(din[ub3:lb3]), 
			.dout(result[rub3:rlb3])
		);
		large_fan_in_or #(
			.WIDTH(WIDTH),
			.OR_QUANTITY(BASE_FAN_IN)
		) large_fan_in_or_result_inst(
			.din(result), 
			.dout(dout)
		);
	end
	endgenerate
endmodule