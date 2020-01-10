module winddir (
	input clock,
	input endata,
	input reset,
	input [3:0] spdmeanlen,
	input [11:0] rx1,
	input [11:0] rx2,
	input [11:0] rx3,
	input [11:0] rx4,
	output signed [15:0] speedX, speedY,
	output signed [15:0] speed,
	output signed [15:0] direction,
	output speeden
	);
	
	wire validSpdX, validSpdY;
	assign speeden = validSpdX;
	wind windX(
		.clock(clock),
		.reset(reset),
		.endata(endata),
		.rx1(rx2),
		.rx2(rx4),
		.speed(speedX),
		.spdmeanlen(spdmeanlen),
		.validOutput(validSpdX)
	);
	
	wind windY(
		.clock(clock),
		.reset(reset),
		.endata(endata),
		.rx1(rx3),
		.rx2(rx1),
		.speed(speedY),
		.spdmeanlen(spdmeanlen),
		.validOutput(validSpdY)
	);
	
	
	windrec2pol wrc2p (
		.clock(clock),
		.reset(reset),
		.validSpeed(validSpdX),
		.X(speedX),
		.Y(speedY),
		.angle(direction),
		.mod(speed)
	);
	
	
endmodule
	