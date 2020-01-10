module windrec2pol(
	input clock,
	input validSpeed,
	input reset,
	input signed [15:0] X,
	input signed [15:0] Y,
	output wire signed [15:0] angle,
	output wire signed [15:0] mod
	);

	wire fsm_reset;
	wire enable;
	wire start;
	assign fsm_reset = reset || validSpeed;
	
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
	wire signed [15:0] absX;
	assign absX = X[15] ? -X : X;
	wire signed [18:0] angle_nc;
	
	real angle_nc_dec;
	always@*
		angle_nc_dec = angle_nc>>>10;

	rec2pol_2step_1 r2p (
		.clock(clock),
		.reset(reset),
		.enable(enable),
		.start(start),
		.x(absX),
		.y(Y),
		.angle(angle_nc),
		.mod(mod)
		);
		
	reg signed [18:0] angle10;
	assign angle = angle10[18:3];
	
	always@(posedge clock)
	begin
		if ( reset )
			angle10 <= 19'b0;
		else 
			if ( validSpeed )
				angle10 <= X[15] ? (Y[15] ? -19'sh2D000-angle_nc : 19'sh2D000-angle_nc) : angle_nc;
	end

endmodule
