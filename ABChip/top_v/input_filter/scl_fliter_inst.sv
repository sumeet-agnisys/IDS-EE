/*---------------------------------------------
module 	: input_filter.v 
designer : Greg Glennon
descr		: handles the 50ns glitch filter
---------------------------------------------*/
module input_filter (input PAD_IN, output logic PAD_OUT);

assign PAD_OUT = PAD_IN; 
/*
wire INB = !PAD_IN;
wire #50 INB_DLY = INB;

always @(*)
if(!(INB | INB_DLY))
	PAD_OUT = 1'b1;

always @(*)
if(INB & INB_DLY)
	PAD_OUT = 1'b0;
*/
endmodule
