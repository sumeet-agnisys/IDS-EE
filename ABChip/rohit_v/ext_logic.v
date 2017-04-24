
module ext_logic #(
    
    //  PARAMETERS
    parameter bus_width   = 32,
    parameter addr_width  = 14,
    
    parameter block_offset  = {(addr_width){1'b0}},
    
    
    parameter Block1_address_width = addr_width
    )
    
    (
		input rst,			// reset given from master
		input clk, 			// clock from the master
		input [31:0]data, 	// data from ids slave
		input	 we,      	// write enable signal from slave
		output reg [31:0]result_r,   	// result given to slave
		output reg result_r_in_enb
    );
    reg [31:0]result_0;
    reg [31:0]result_1;
    reg [31:0]result_2;
    reg result_r_in_enb_0;
    reg result_r_in_enb_1;
    reg result_r_in_enb_2;
 
    always@(posedge clk)
    begin
	    if(!rst)
	    begin
		    result_0=32'h0;
		    result_r_in_enb_0 <='b0;
	    end
	    else
	    begin
		    if(we)
		    begin
			    result_0=data;
			    result_r_in_enb_0 <='b1;
		    end					
		    else
			    result_r_in_enb_0 <='b0;
	    end
    end
		    
    always @(posedge clk)
        begin
        if(!rst)
            begin
                result_1 <=32'b0;
                result_2 <=32'b0;
                result_r <= 32'b0;

		result_r_in_enb <='b0;    
    		result_r_in_enb_1 <='b0;  
    		result_r_in_enb_2 <='b0;  
            end
        else
            begin
		// for data send stages
                result_1 <= result_0;
                result_2 <= result_1;
                result_r <= result_2;
                // for enable signal stages		
		result_r_in_enb_1 <= result_r_in_enb_0;
                result_r_in_enb_2 <= result_r_in_enb_1;
                result_r_in_enb   <= result_r_in_enb_2;
            end
    end  //always clk
	

	
endmodule
