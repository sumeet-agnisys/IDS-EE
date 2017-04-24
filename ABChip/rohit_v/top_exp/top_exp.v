
module top_block #(
    
    //  PARAMETERS
    parameter bus_width   = 32,
    parameter addr_width  = 14,
    
    parameter block_offset  = {(addr_width){1'b0}},
    
    
    parameter Block1_address_width = addr_width
    )
    
    (
	    //Block1_ids
    output   Block1_idsdata_enb,
   // output [31 : 0] Block1_idsdata_D_r,
    
    output   Block1_idsenb_enb,
  //  output  Block1_idsenb_E_r,
        	
    //AMBA signals
    input hclk,
    input hresetn,
    input hwrite,
    input [addr_width-1 : 0] haddr,
    input [bus_width-1 : 0] hwdata,
    output [bus_width-1 : 0] hrdata,
    output hready,
    input [1 : 0] htrans,
    input [2 : 0] hsize,
    output [1 : 0] hresp,
    input [3 : 0] hprot,
    input hsel,
    input [2 : 0] hburst

	);
	
	//wire   Block1_idsdata_enb,
    wire [31 : 0] Block1_idsdata_D_r;
    
    //wire   Block1_idsenb_enb,
    wire  Block1_idsenb_E_r;
    
    wire  [31 : 0] Block1_idsresult_F_in;
    wire   Block1_idsresult_F_in_enb;
    
	
 	
     Block1_ids #(.addr_width(addr_width),.block_offset( 'h0)) Block1_idsinst(
    .data_enb(Block1_idsdata_enb),
    .data_D_r(Block1_idsdata_D_r),
    .enb_enb(Block1_idsenb_enb),
    .enb_E_r(Block1_idsenb_E_r),
    .result_F_in(Block1_idsresult_F_in),
    .result_F_in_enb(Block1_idsresult_F_in_enb),
    
    .hclk(hclk),
    .hresetn(hresetn),
    .hwrite(hwrite),
    .haddr(haddr),
    .hwdata(hwdata),
    .hrdata(hrdata),
    .hready(hready),
    .htrans(htrans),
    .hsize(hsize),
    .hresp(hresp),
    .hprot(hprot),
    .hsel(hsel),
    .hburst(hburst));
	
	ext_logic #(.addr_width(addr_width),.block_offset( 'h0)) ext_logic_inst(
			.data(Block1_idsdata_D_r),
			.result_r(Block1_idsresult_F_in),
			.result_r_in_enb(Block1_idsresult_F_in_enb),
			.we(Block1_idsenb_E_r),
			.clk(hclk),
			.rst(hresetn)
	);
    
endmodule
