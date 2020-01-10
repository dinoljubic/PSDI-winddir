
module phasecalc_fsm(
	input clock,
	input reset,
	output reg start,
	output reg enable
	);
	
	reg [3:0] cnt;
	
	always@(posedge clock)
	begin
		if (reset)
		begin
			cnt <= 4'b0;
			//start <= 0;
			//enable <= 0;
		end
		else
		if (cnt < 9)
			cnt <= cnt + 1;
	end
	
	
	always@*
	begin
	case( cnt )
		4'd0: begin start = 1; enable = 1; end
		4'd1: begin start = 0; enable = 1; end
		4'd9: begin start = 0; enable = 0; end
		default: begin start = 0; enable = 1; end
	endcase
	end
endmodule