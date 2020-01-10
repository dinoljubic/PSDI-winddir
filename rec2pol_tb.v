`timescale 1ns / 1ns

/*
    Integrated Master in Electrical and Computer Engineering - FEUP
	
	EEC0055 - Digital Systems Design 2019/2020
	
	----------------------------------------------------------------------
	module rec2pol_tb - Basic testbench for the rec2pol module.
	
	Summary
	This module implements a basic testbench for the rec2pol module. 
	Includes the task "execcordic(X,Y)" to execute a rectangular to polar conversion
	and print the results with the relative errors
	
	----------------------------------------------------------------------	
	Date created: 4 Oct 2019
	Author: jca@fe.up.pt

	----------------------------------------------------------------------		
	This Verilog code is property of the University of Porto, Portugal
	Its utilization beyond the scope of the course Digital Systems Design
	(Projeto de Sistemas Digitais) of the Integrated Master in Electrical 
	and Computer Engineering requires explicit authorization from the author.
	
*/
module rec2pol_tb;

	// Inputs
	reg clock;
	reg reset;
	reg enable;
	reg start;
	reg [12:0] x0;
	reg [12:0] y0;

	// Outputs
	//wire signed [12:0] mod;
	wire signed [18:0] angle;

	// Instantiate the Unit Under Test (UUT)
	rec2pol_2step uut (
		.clock(clock), 
		.reset(reset), 
		.enable(enable), 
		.start(start), 
		.x(x0), 
		.y(y0), 
		//.mod( mod ), 
		.angle( angle )
	);

	// Initialize inputs:
	initial begin
		clock = 0;
		reset = 0;
		enable = 0;
		start = 0;
		x0 = 0;
		y0 = 0;
	end
	
	// Generate the clock (10 ns period, frequency = 100 MHz)
	initial
	begin
	  #11
	  forever #5 clock = ~clock;
	end
	
	// Apply reset:
	initial
	begin
	  #101 
	  reset = 1;
	  #20
	  reset = 0;
	end



	// set to zero to disable printing the simulation results 
	// by the task "execcordic"
	integer printresults = 1;
	real fracfactorangle = 1<<10;
	real PI = 3.1415926536;
	integer MAX=1<<11-1;
	integer R, theta_deg;
	real theta;
	integer signed x_rand, y_rand;
	integer i;
	integer N = 30;
	
	// Main verification program:
	initial
	begin
	  #10
	  // Wait for realising the reset:
	  @(negedge reset);
	  // Wait 10 clock cycles
	  //	This is not required but helps analysing the signals in the
      //    waveform window.
	  repeat (10)
	  	@(negedge clock);
	  
		  for (i=0; i < N; i=i+1)
		  begin
			R = $urandom_range(MAX*MAX,1);
			
		
			theta_deg = ($urandom(i)%180) - 90;
			theta = theta_deg * PI / 180;
						   
			x_rand = $rtoi($sqrt($unsigned(R))*$cos(theta));
			y_rand = $rtoi($sqrt($unsigned(R))*$sin(theta));
			
			execcordic( x_rand, y_rand );

		  end
	  // Call the task to start a conversion:
	  execcordic( 123, 456 );
	 
	  $stop;
	  
	end
	


	//--------------------------------------------------------------------
	// float parameters to convert the integer results to fractional results:
	//real fracfactor = 1<<16;

	
	// The X and Y in float format, required to compute the real values:
	real Xr, Yr;
	
	// The "true" values of modules, angle and the % errors:
	real real_mod, real_atan, err_mod, err_atan;
	
	//--------------------------------------------------------------------
	// Execute a CORDIC: 
	//   apply inputs, set enable to 1, raise start for 1 clock cycle, wait 32 clock cyles
	// set variable "printresults" to 1 to enable printing the results during simulation
	task execcordic;
	input signed [12:0] X;
	input signed [12:0] Y;
	begin
	   x0 = X;
	   y0 = Y;
	   
	   start = 1;
	   enable = 1;
	   @(negedge clock);
	   start = 0;
	   
	   repeat( 8 )
	   	@(negedge clock);
	   
	   enable = 0;
	   
	   // Wait some clocks to separate the calls to the task
	   repeat( 10 )
	   	@(negedge clock);
	   
	   if ( printresults )
	   begin  
	   	// Calculate the expected results:
	   	  Xr = X;
	   	  Yr = Y;
	   	  //real_mod = $sqrt( Xr*Xr+Yr*Yr);
	   	  real_atan = $atan2(Yr,Xr) * 180 / PI;
	   	  //err_mod = 100 * ( real_mod - (mod / fracfactor) ) / (mod / fracfactor);
	   	  err_atan = 100 * ( real_atan - (angle / fracfactorangle) ) / (angle / fracfactorangle);
	      
	   	  $display("Xi=%d, Yi = %d, Angle=%f drg Exptd: A=%f drg (ERRORs =  %f%%)",
	   	  		       X, Y, angle / fracfactorangle,
	   	  		       real_atan, err_atan );	
	    end
	
	end
	endtask


endmodule
// end of module rec2pol_tb
