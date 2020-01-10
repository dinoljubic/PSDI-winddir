
module phasecalc(
	input clock,
	input endata,
	input reset,
	input signed [12:0] X,
	input signed [12:0] Y,
	output reg signed [18:0] angle
	);

	wire fsm_reset;
	wire enable;
	wire start;
	assign fsm_reset = reset || endata;
	
	integer phase;
	always@*
		phase = angle>>>10;

	phasecalc_fsm fsm(
		.clock( clock ),
		.reset( fsm_reset ),
		.start( start ),
		.enable( enable )
		);
	
	//wire rst_cordic_gl, rst_cordic;
	wire signed [12:0] absX;
	assign absX = X[12] ? -X : X;
	wire signed [18:0] angle_nc;
	
	real angle_nc_dec;
	always@*
		angle_nc_dec =  angle_nc>>>10;

	rec2pol_2step r2p (
		.clock(clock),
		.reset(reset),
		.enable(enable),
		.start(start),
		.x(absX),
		.y(Y),
		.angle(angle_nc)
		);
		
		

	always@(posedge clock)
	begin
		if ( reset )
			angle <= 19'b0;
		else 
			if ( endata )
				angle <= X[12] ? (Y[12] ? -19'sh2D000-angle_nc : 19'sh2D000-angle_nc) : angle_nc;
	end

endmodule
