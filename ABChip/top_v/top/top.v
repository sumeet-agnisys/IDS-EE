// *************************************************************************
// Disclaimer: This is just for illustration Purpose
// 05 Oct 2012
// Maxim Integrated
// *************************************************************************

module top (SCL, SDA, CLK);
input SCL;
input SDA;
output CLK;
input SCL_DLY;
input SDA_DLY;
output [7:0] DATA_OUT;
input READ;
input [7:0] DATA_IN;
input [7:0] REG_ADDR;
input [7:0] VCO_SEL;
input [7:0] rampTime;
input Vdn;

reg reset;
wire v_source_select_wire,Vco_fixed_select, SCL_DLY, SDA_DLY, READ, WRITE, SDA_OUT, PD, Pwr_mode ;
reg v_source_select_reg;
wire [4:0] load_select, count;
wire [7:5] seq_load_select, VCVGA;
wire [7:0] DATA_IN, DATA_OUT, REG_ADDR, VCO_SEL, rampTime;
wire Vup, Vdn;
wire Vup_temp, Vdn_temp;
reg Vup_reg, Vdn_reg;

i2c_fsm i2c_fsm_inst3 (SCL_DLY, SDA_DLY, DATA_IN, DATA_OUT, REG_ADDR, READ, WRITE, SDA_OUT);


i2c_fsm i2c_fsm_inst2 (SCL_DLY, SDA_DLY, DATA_IN, DATA_OUT, REG_ADDR, READ, WRITE, SDA_OUT);

input_filter sda_fliter_inst (SDA, SDA_DLY);

input_filter scl_fliter_inst (SCL, SCL_DLY);

register reg_inst (REG_ADDR, DATA_IN, READ, WRITE, SCL_DLY,
        DATA_OUT, VCVGA, PD, VCO_SEL, Pwr_mode, Vup,
        Vdn, Vco_fixed_select, v_source_select_wire, load_select,
        seq_load_select, count, rampTime, reset);

//sda_pad sda_pad_inst (SDA_OUT, SCL_DLY, SDA);


//assign r_in2 = (Vco_fixed_select==1'b1) ? r_in :
		(Vco_fixed_select==1'b0) ? LDO_OUT : LDO_OUT;

assign Vup_temp = Vup_reg;
assign Vdn_temp = Vdn_reg;

//assign CLK = VCO_OUT;


endmodule

