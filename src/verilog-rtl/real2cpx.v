
// outputs are delayed by 6 samples (5 for loading bufer and 1 for 
// FIR filter calculation )
module real2cpx(
	input clock,
	input endata,
	input reset,
	input signed [11:0] x,
	output reg signed [12:0] Im,
	output signed [12:0] Re
	);

reg signed [11:0] buffer [6:0];

wire signed [20:0] mult_res;
wire signed [12:0] diff1, diff2;
wire signed [20:0] mult1, mult2;

assign diff1 = buffer[6] - buffer[0];
assign diff2 = buffer[4] - buffer[2];
assign mult1 = diff1*9'sb000111101;
assign mult2 = diff2*9'sb010100000;
assign mult_res = mult1 + mult2;


assign Re = buffer[4];


always@(posedge clock)
begin
	if ( reset )
	begin
		buffer[0] <= 12'b0;
		buffer[1] <= 12'b0;
		buffer[2] <= 12'b0;
		buffer[3] <= 12'b0;
		buffer[4] <= 12'b0;
		buffer[5] <= 12'b0;
		buffer[6] <= 12'b0;
		Im <= 13'b0;
	end

	else if ( endata )
	begin
		buffer[0] <= x;
		buffer[1] <= buffer[0];
		buffer[2] <= buffer[1];
		buffer[3] <= buffer[2];
		buffer[4] <= buffer[3];
		buffer[5] <= buffer[4];
		buffer[6] <= buffer[5];
		Im <= mult_res[20:8];
	end
end

endmodule