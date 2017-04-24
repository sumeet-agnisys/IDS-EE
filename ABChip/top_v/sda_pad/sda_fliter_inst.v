/*---------------------------------------------
module 	: sda_pad.v 
designer : Greg Glennon
descr		: handles the output driver for sda 
---------------------------------------------*/
module sda_pad (SDA_OUT, SCL_DLY, SDA);
input SDA_OUT;
input SCL_DLY;
inout SDA;

reg HOLD;

initial HOLD = 0;

always @(negedge SCL_DLY)
	begin
		HOLD = 1;
		#300;
		HOLD=0;
	end
	
// Latch the output signal to provide a stable hold time	
wire SDA_HOLD = !HOLD ? SDA_OUT : SDA_HOLD;
	
// Pass the latched output value out on SDA	
assign SDA = !SDA_HOLD ? 1'b0 : 1'bz; 

endmodule
