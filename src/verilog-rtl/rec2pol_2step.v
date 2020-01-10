/*

    Integrated Master in Electrical and Computer Engineering - FEUP
	
	EEC0055 - Digital Systems Design 2019/2020
	
	----------------------------------------------------------------------
	module rec2pol 
	
	Summary
	CORDIC vectoring mode - convert rectangular coords to polar coords
	
	----------------------------------------------------------------------	
	Date created: 1 Nov 2019
	Author: jca@fe.up.pt

	----------------------------------------------------------------------		
	This Verilog code is property of the University of Porto, Portugal
	Its utilization beyond the scope of the course Digital Systems Design
	(Projeto de Sistemas Digitais) of the Integrated Master in Electrical 
	and Computer Engineering requires explicit authorization from the author.

*/

module rec2pol_2step( 
                input clock,
				input reset,
				input enable,              // set and keep high to enable iteration
				input start,               // set to 1 for one clock to start 
				input  signed [12:0] x,    // X component
				input  signed [12:0] y,    // Y component
				output signed [18:0] angle // Angle in degrees, (9.10)
			  );
			  

// ROM address is the iteration counter:
wire [3:0] icnt_1, icnt_2;
assign icnt_2 = icnt_1 + 1;

// ROM data out: (6.10)
wire [15:0] rom_data_1;
wire [15:0] rom_data_2;
			  
ATAN_ROM  ATAN_ROM_1(
                 .addr( icnt_1 ),
				 .data( rom_data_1 )
			   );
			   
ATAN_ROM  ATAN_ROM_2(
				.addr( icnt_2 ),
				.data( rom_data_2 )
);

// Iteration counter:
ITERCOUNTER ITERCOUNTER_1(
                 .clock(clock),
				 .reset(reset),
				 .start(start),
				 .enable(enable),
				 .count( icnt_1 )
			   );

	
// Registers for the Cordic vectoring mode:
reg signed [12:0] xr_2, yr_2;
reg signed [18:0] zr_2;

wire signed [12:0] xr_1, yr_1;
wire signed [18:0] zr_1;

integer ang_dec;
always @*
	ang_dec = angle>>10;


// first (and odd increments)
assign xr_1 = ~yr_2[12] ? xr_2 + (yr_2 >>> icnt_1) : xr_2 - (yr_2 >>> icnt_1);
assign yr_1 = ~yr_2[12] ? yr_2 - (xr_2 >>> icnt_1) : yr_2 + (xr_2 >>> icnt_1);
assign zr_1 = ~yr_2[12] ? zr_2 + ( $unsigned(rom_data_1) ) : zr_2 - ( $unsigned(rom_data_1) );

// Main datapath:
always @(posedge clock)
if ( reset )
begin
  xr_2 <= 13'd0; 
  yr_2 <= 13'd0;
  zr_2 <= 19'd0;
end
else
begin
  if ( enable )
  begin
    if ( start )
    begin
		xr_2 <= x;
		yr_2 <= y;
		zr_2 <= 19'd0;
    end
    else
    begin
		xr_2 <= ~yr_1[12] ? xr_1 + (yr_1 >>> icnt_2) : xr_1 - (yr_1 >>> icnt_2);
		yr_2 <= ~yr_1[12] ? yr_1 - (xr_1 >>> icnt_2) : yr_1 + (xr_1 >>> icnt_2);
		zr_2 <= ~yr_1[12] ? zr_1 + ( $unsigned(rom_data_2) ) : zr_1 - ( $unsigned(rom_data_2) );
    end
  end
end

assign angle = zr_2 ;

endmodule