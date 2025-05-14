`include "define.v"

module static_predictor(
	input clk,
	input rst_n,
	input PL_stall_ex,

	input imme_sig,
	output SP_prediction_result, 
	output SP_prediction_result_id,
	output SP_prediction_result_ex
);
	reg prediciont_result_reg_id, prediciont_result_reg_ex;

	always @(posedge clk)
	begin
		if (!rst_n)
			begin
				prediciont_result_reg_id <= `zero;
				prediciont_result_reg_ex <= `zero;
			end
		else
			begin
				if(!PL_stall_ex)
				begin
					prediciont_result_reg_id <= SP_prediction_result;
					prediciont_result_reg_ex <= prediciont_result_reg_id;
				end
			end
	end	

	assign SP_prediction_result_id = prediciont_result_reg_id;
	assign SP_prediction_result_ex = prediciont_result_reg_ex;
	assign SP_prediction_result = imme_sig;
endmodule