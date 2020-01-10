`timescale 1ns / 1ns

module wind_tb;

	// Inputs
	reg clock;
	reg newSample;
	reg reset;
	reg [11:0] rx4;
	reg [11:0] rx2;

	// Outputs
	//wire signed [12:0] mod;
	wire signed [15:0] speed;
	wire validOutput;
	
	parameter MAXSIMDATA = 2000;
	parameter
		rxuw_file = "../simdata/data_rx2.hex", // upwind along X (left receiver)
		rxdw_file = "../simdata/data_rx4.hex";
		
	reg signed [11:0]  vrxuw[0:MAXSIMDATA-1];
	reg signed [11:0]  vrxdw[0:MAXSIMDATA-1];

	// Instantiate the Unit Under Test (UUT)
	wind uut(
		.clock(clock),
		.reset(reset),
		.endata(newSample),
		.rx1(rx2),
		.rx2(rx4),
		.speed(speed),
		.validOutput(validOutput)
	);

	initial begin
		$readmemh( rxuw_file, vrxuw );
		$readmemh( rxdw_file, vrxdw );
	end
	
	// Initialize inputs:
	initial begin
		clock = 0;
		reset = 0;
		newSample = 0;
		rx4 = 0;
		rx2 = 0;
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
		end
		repeat (100)
		@(negedge clock);
		$stop;

	end

endmodule