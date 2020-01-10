`timescale 1ns / 1ns

module winddir_tb;

	// Inputs
	reg clock;
	reg newSample;
	reg reset;
	reg [11:0] rx1;
	reg [11:0] rx3;
	reg [11:0] rx4;
	reg [11:0] rx2;
	reg [3:0] spdmeanlen;

	// Outputs
	//wire signed [12:0] mod;
	wire signed [15:0] speed;
	wire signed [15:0] direction;
	wire signed [15:0] speedX,speedY;
	wire speeden;
	
	real spd, dir, spdX, spdY;
	always@*
	begin
		spd = real'(speed)/(1<<10);
		dir = real'(direction)/(1<<7);
		spdX = real'(speedX)/(1<<10);
		spdY = real'(speedY)/(1<<10);
	end
	

	parameter MAXSIMDATA = 2000;
	parameter
		// Switched Uw & dw
		rxuwX_file = "../simdata/data_rx4.hex", // upwind along X (left receiver)
		rxdwX_file = "../simdata/data_rx2.hex",
		rxuwY_file = "../simdata/data_rx3.hex",
		rxdwY_file = "../simdata/data_rx1.hex";
		
	reg signed [11:0]  vrxuw[0:MAXSIMDATA-1];
	reg signed [11:0]  vrxdw[0:MAXSIMDATA-1];
	reg signed [11:0]  vryuw[0:MAXSIMDATA-1];
	reg signed [11:0]  vrydw[0:MAXSIMDATA-1];

	// Instantiate the Unit Under Test (UUT)
	winddir uut(
		.clock(clock),
		.reset(reset),
		.endata(newSample),
		.rx1(rx1),
		.rx2(rx2),
		.rx3(rx3),
		.rx4(rx4),
		.speed(speed),
		.speedX(speedX),
		.speedY(speedY),
		.direction(direction),
		.spdmeanlen(spdmeanlen),
		.speeden(speeden)
	);

	initial begin
		$readmemh( rxuwX_file, vrxuw );
		$readmemh( rxdwX_file, vrxdw );
		$readmemh( rxuwY_file, vryuw );
		$readmemh( rxdwY_file, vrydw );
		
		spdmeanlen = 6;
	end
	
	// Initialize inputs:
	initial begin
		clock = 0;
		reset = 0;
		newSample = 0;
		rx4 = 0;
		rx2 = 0;
		rx1 = 0;
		rx3 = 0;
	end
	
	// Generate the clock (10 ns period, frequency = 100 MHz)
	initial
	begin
	  #11
	  forever #5 clock = ~clock;
	end
	
	// Generate sample clock
	initial
	begin
		#15 newSample = 1;
		forever
		begin
		#5 newSample = 0;
		#95 newSample = 1;
		end
	end
	
	// Apply reset:
	initial
	begin
		#101 
		reset = 1;
		#20
		reset = 0;
	end

	integer i;
	
	// Main verification program:
	initial
	begin
		# 1;
		@( negedge reset );
		# 1;
		@( negedge clock );

		// apply input data:
		for (i=0; i< MAXSIMDATA; i = i + 1 )
		begin
			@(posedge newSample); // When endata is high apply a new input sample:
			rx4 = vrxdw[i];
			rx2 = vrxuw[i];
			rx1 = vrydw[i];
			rx3	= vryuw[i];
		end
		repeat (100)
		@(negedge clock);
		$stop;

	end

endmodule