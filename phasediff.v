module phasediff(
	input clock,
	input signed [18:0] phase1,
	input signed [18:0] phase2,
	output reg signed [18:0] diff
	);
	
	wire signed [19:0] diff_nc;
	assign diff_nc = phase2-phase1;
	
	
	real ph1,ph2,phnc,ph;
	always @*
	begin
		ph1 = phase1 >>> 10;
		ph2 = phase2 >>> 10;
		phnc = diff_nc >>> 10;
		ph = diff >>> 10;
	end
	
	reg signed temp;
	
	always@(posedge clock)
	begin
		if (diff_nc > 20'sh2D000)
			{temp, diff} <= $signed(diff_nc - 20'h5A000);
		else if (diff_nc < 20'shD3000)
			{temp, diff} <= $signed(diff_nc + 20'h5A000);
		else
			{temp, diff} <= diff_nc;
	end
	
	
endmodule
	