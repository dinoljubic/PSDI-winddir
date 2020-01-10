module winddir (
	input clock,
	input endata,
	input reset,
	input [11:0] rx1,
	input [11:0] rx2,
	input [11:0] rx3,
	input [11:0] rx4,
	output [15:0] speed,
	output [15:0] direction
	);
	
	wire signed [15:0] speedX, speedY;
	wire validSpdX, validSpdY;
	
	wind windX(
		.clock(clock),
		.reset(reset),
		.endata(endata),
		.rx1(rx2),
		.rx2(rx4),
		.speed(speedX),
		.validOutput(validSpdX)
	);
	
	wind windY(
		.clock(clock),
		.reset(reset),
		.endata(endata),
		.rx1(rx3),
		.rx2(rx1),
		.speed(speedY),
		.validOutput(validSpdY)
	);
	
	real spdx,spdy;
	always@*
	begin
		spdx = (speedX/real'(1<<10));
		spdy = (speedY/real'(1<<10));
	end
	
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
	