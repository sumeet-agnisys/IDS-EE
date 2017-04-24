/*---------------------------------------
module	: regs.sv
designer	: Greg Glennon
Descript : implements the register map
modified by: sumeet vishwas
---------------------------------------*/
module register (REG_ADDR, DATA_IN, READ, WRITE, SCL_DLY, 
	DATA_OUT, VCVGA, PD, VCO_SEL, Pwr_mode, Vup, 
	Vdn, Vco_fixed_select, v_source_select, load_select,
	seq_load_select, count, rampTime, reset);


//, Vmin, Vmax);

	input [7:0] REG_ADDR;
	input [7:0] DATA_IN;
	input READ;
	input WRITE;
	input SCL_DLY;
	input reset;

	output [7:0] DATA_OUT;
	output [7:0] rampTime;
/*`ifdef VOLTAGE_RANGE
	output [7:0] Vmin;
	output [7:0] Vmax;
`endif*/
	output [2:0] VCVGA; // pga control
	output PD;  // pga enable
	output [7:0] VCO_SEL; // vco frequency select
	output Pwr_mode, Vup, Vdn, Vco_fixed_select, v_source_select;
	output [4:0] load_select, count;
	output [7:5] seq_load_select;
	
	wire [2:0] VCVGA;
	wire [7:0] VCVGA_reg;
	wire PD;
	
	
	wire Vup, Vdn, Vco_fixed_select;
	wire  v_source_select ;
	wire  [7:0] VCO_SEL;
	wire [4:0] count, load_select;
	wire [7:0] rampTime;
	wire Pwr_mode ; // 0=low vdd standby; 1=full
	wire [7:5] seq_load_select;
	wire reset;



	integer i;
	reg[7:0] reg_bank[7:0]; // Instantiate register bank
	reg [7:0] DATA_OUT;
	reg UP;
	reg down;
	reg  clk;
	reg [4:0] count_reg;
	reg [4:0] load_select_reg;
	reg [7:5] seq_load_select_reg;
	reg Pwr_mode_reg = 1; // 0=low vdd standby; 1=full
	reg Vup_reg;
	reg Vdn_reg;
	reg Vco_fixed_select_reg=1;
	reg v_source_select_reg;
	reg [7:0] VCO_SEL_reg;
	reg [7:0] rampTime_reg;
	
i2c_fsm i2c_fsm_inst4 (SCL_DLY, DATA_IN, DATA_OUT, REG_ADDR, READ, WRITE);


initial
	begin
		DATA_OUT = 8'h00;
		for(i=0;i<8;i=i+1)
			reg_bank[i][7:0]=i*2;
	//		reg_bank[i][7:0]=i*0;
	clk = 0; 
end // initial

always #1 clk = ~clk;


	// when in read mode, if reg_addr size is less than 8, read out the reg_addr from reg_bank
	always @(posedge READ)
		if(REG_ADDR < 8)
			DATA_OUT <= reg_bank[REG_ADDR];
		else  // else send out 1s on data
			DATA_OUT <= 8'hFF;

	always @(negedge SCL_DLY) // write only on negedge of scl_dly into the register bank
		if(WRITE) begin
			if(REG_ADDR==1)
				 reg_bank[REG_ADDR] <= DATA_IN;
			else if (Pwr_mode_reg) // write only when voltage is fully ON
				 reg_bank[REG_ADDR] <= DATA_IN;
		end

	// Pull register values for functions
	assign VCVGA_reg[7:0]		= reg_bank[0][7:0]; // address 0 with 8 bits for pga 
	assign VCVGA[2:0]		= VCVGA_reg[2:0]; // only send out first 3 bits
	assign PD 			= reg_bank[0][3]; // pga enable 
	
	assign Pwr_mode			= Pwr_mode_reg; // power mode selection
	assign Vup			= Vup_reg; // increase voltage
	assign Vdn			= Vdn_reg; // decrease voltage
	assign Vco_fixed_select		= Vco_fixed_select_reg; // vco control to select fixed voltage (1) or regulator (0)
	// selects between manual ramping (1) or constant driver (0)
	assign VCO_SEL[7:0]		= VCO_SEL_reg[7:0]; // vco select control is only addr 2

	/*`ifndef VOLTAGE_RANGE
	 assign Vmax			= Vmax_reg;	
	 assign Vmin			= Vmin_reg;
	`else
	 assign Vmax =5; Vmin=3;
	`endif // VOLTAGE_RANGE
*/
	assign load_select[4:0]		= load_select_reg[4:0];
	assign seq_load_select[7:5]	= seq_load_select_reg[7:5]; 
	assign count[4:0]			= count_reg[4:0]; // repeat counter for voltage ramping
	assign rampTime[7:0]			= rampTime_reg[7:0]; // total ramp up or down time
	assign v_source_select 	= v_source_select_reg; // selects between manual ramping (1) or constant driver (0)


//`ifdef infinite_loop
always @(posedge clk) begin
if (reset) begin
Pwr_mode_reg		<= reg_bank[1][0];
Vup_reg			<= reg_bank[1][1];
Vdn_reg			<= reg_bank[1][2];
Vco_fixed_select_reg	<= reg_bank[1][3];
`ifndef RAMP_model
 v_source_select_reg	<= reg_bank[1][4];
 `else                                         
 v_source_select_reg	<= 1;
`endif 
VCO_SEL_reg[7:0]	<= reg_bank[2][7:0];
                                          
/*`ifndef VOLTAGE_RANGE
 Vmax_reg		<= reg_bank[3];	
 Vmin_reg		<= reg_bank[4];
 `else                                         
 Vmax_reg <=5; Vmin_reg<=3;
`endif
*/

load_select_reg[4:0]	<= reg_bank[5][4:0];
seq_load_select_reg[7:5]<= reg_bank[5][7:5];
count_reg[4:0]		<= reg_bank[6][4:0];
rampTime_reg[7:0]		<= reg_bank[7][7:0];
end //if

 else if (~reset) begin
  Pwr_mode_reg		= 0; 
  Vup_reg		= 0;
  Vdn_reg		= 0;
  `ifndef VCO_FIXED 
   Vco_fixed_select_reg	= 0;
   `else                       
   Vco_fixed_select_reg	= 1;
   `endif // VCO_FIXED                       
   v_source_select_reg 	= 0;
 
  VCO_SEL_reg[7:0]	= 8'd0;
                          
  /*`ifndef VOLTAGE_RANGE
   Vmax_reg		= 0;
   Vmin_reg		= 0;
   `else                       
   Vmax_reg <=5; Vmin_reg<=3;
  `endif
  */
  load_select_reg	= 0;
  seq_load_select_reg	= 0;
  count_reg		= 5'd0;
  rampTime_reg		= 0;
 end // if
end // always
//`endif // infinite loop
endmodule
