`timescale 1ns/1ns

module real2cpx_tb;

parameter CLOCK_PERIOD    	= 50; // ns

parameter MAX_X_VALUE     	= (1<<11)-1; // Maximum integer part of random X
parameter SINE_FREQ			= 17;
parameter SAMPLE_FREQ		= 100;
parameter INPUT_DELAY		= 5;

parameter ERROR_THR			= 0.08;
parameter MAX_TESTS			= 20;

reg 				clk;
reg					reset;
reg signed	[11:0]	x;
wire signed	[12:0]	Re;
wire signed	[12:0]	Im;

real Im_dec, Re_dec;

always@*
begin
	Im_dec = Im;
	Re_dec = Re;
end

real2cpx real2cpx_ut (
	.clock(clk),
	.reset(reset),
	.x(x),
	.Re(Re),
	.Im(Im)
);

// Set up initial values and the clock signal
initial
begin
	$display("Start simulation...");
	clk = 0;
	reset = 0;
	
	x = 12'b0;
	# 100
	
	forever #(CLOCK_PERIOD/2) clk = ~clk;
end

// Generate a reset pulse
initial
begin
	$display("Reset uut...");

	# 100
	reset = 1;
	# 100
	reset = 0;
end

real PI = 3.1415926536;
integer counter = -INPUT_DELAY*2;
real phase_in = 0, phase_expected, Re_exp,Im_exp, err_phase;
integer err_counter = 0;

// Data to sendto the module
initial
begin
	$display("Initializing test...");
	@(negedge reset);
	@(posedge clk);
	
	repeat (INPUT_DELAY*2) // initialize (load buffer)
	begin
		phase_in = real'(SINE_FREQ)/SAMPLE_FREQ*counter*2*PI;
		x = MAX_X_VALUE*$cos(phase_in);
		
		@(posedge clk); //wait for posedge
		counter = counter+1; //increment counter
	end
	
	$display("Beginning test...");

	repeat (MAX_TESTS)
	begin
		phase_in = real'(SINE_FREQ)/SAMPLE_FREQ*counter*2*PI;
		x = MAX_X_VALUE*$cos(phase_in);
		@(posedge clk); //wait for posedge
		// expected output phase is delayed by INPUT_DELAY steps
		
		// Expected values
		Re_exp = getx(counter);
		Im_exp = gety(counter);
		
		counter = counter+1; //increment counter
		err_phase = real'(Im-Im_exp)/Im_exp;
		//if (err_phase > ERROR_THR)
		//begin
			$display("%5d Re=%4.4f, Im=%4.4f --- Exptd: Re=%4.4f, Im=%4.4f --- Error=%2.4f", counter, Re, Im, Re_exp,Im_exp, err_phase);
			err_counter=err_counter+1;
		//end
	end
	
	$display("Test finished with %d errors.", err_counter);
	
	$stop;
end


function real getx(
	input integer cnt
);
begin
	getx = real'(MAX_X_VALUE*$cos(real'(SINE_FREQ)/SAMPLE_FREQ*(cnt-INPUT_DELAY)*2*PI));
end
endfunction

function real gety(
	input integer cnt
);
begin
	gety = real'((getx(cnt-3)-getx(cnt+3))*0.23828125 + (getx(cnt-1)-getx(cnt+1))*0.625);
end
endfunction


endmodule
