module phase2speed(
	input clock,
	input endata,
	input reset,
	input [3:0] spdmeanlen,
	input signed [18:0] phase,
	output reg signed [15:0] speed,
	output reg newAvg
	);
	
	parameter N = 11;
	
	reg signed [31:0] acc;
	reg [N:0] counter;
	reg [2:0] state;
	reg [2:0] nextstate;
	
	// FSM
	always@(posedge clock)
	begin
	if ( reset )
		state <= 3'b0; else state <= nextstate;
	end
	
	always@*
	begin
		case (state)
		0: if ( endata ) nextstate = 1; else nextstate = state;
		1: nextstate = 2;
		2: if ( endata ) nextstate = 3; else nextstate = state;
		3: if ( counter == 0 ) nextstate = 4; else nextstate = 2;
		4: nextstate = 0;
		endcase
	end
	
	always@*
	begin
		case (state)
		0: newAvg = 0;
		1: begin newAvg = 0; counter = 1<<spdmeanlen; acc = 0; end
		2: newAvg = 0;
		3: begin newAvg = 0; acc = acc+phase; counter = counter-1; end
		4: begin newAvg = 1; speed = ((acc>>>spdmeanlen)*18026)>>>17; end
		endcase
	end

/*
	always@(posedge clock)
	begin
	if ( reset ) avgPhase<=0;
	else
		
	end
	*/
	endmodule
	