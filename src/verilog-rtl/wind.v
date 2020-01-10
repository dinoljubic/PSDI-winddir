module wind(
	input clock,
	input reset,
	input endata,
	input [3:0] spdmeanlen,
	input [11:0] rx1,
	input [11:0] rx2,
	output signed [15:0] speed,
	output validOutput
	);
	
	wire signed [12:0] Re1, Re2, Im1, Im2;
	
	real2cpx real2cpx1(
		.x(rx1),
		.clock(clock),
		.endata(endata),
		.reset(reset),
		.Im(Im1),
		.Re(Re1)
	);
	
	real2cpx real2cpx2(
		.x(rx2),
		.clock(clock),
		.endata(endata),
		.reset(reset),
		.Im(Im2),
		.Re(Re2)
	);
	
	wire signed [18:0]ph1, ph2;
	
	phasecalc phasecalc1(
		.clock(clock),
		.endata(endata),
		.reset(reset),
		.X(Re1),
		.Y(Im1),
		.angle(ph1)
	);
	
	phasecalc phasecalc2(
		.clock(clock),
		.endata(endata),
		.reset(reset),
		.X(Re2),
		.Y(Im2),
		.angle(ph2)
	);
	wire signed [18:0] phase;
	
	phasediff phdiff(
		.clock(clock),
		.phase1(ph1),
		.phase2(ph2),
		.diff(phase)
	);

	
	phase2speed ph2spd(
		.spdmeanlen(spdmeanlen),
		.clock(clock),
		.reset(reset),
		.endata(endata),
		.phase(phase),
		.speed(speed),
		.newAvg(validOutput)
	);

	
endmodule
