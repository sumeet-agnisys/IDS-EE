/*---------------------------------------------
module 	: i2c_fsm.v 
designer : Greg Glennon
descr		: handles the I2C communications 
---------------------------------------------*/
module i2c_fsm (SCL_DLY, SDA_DLY, DATA_IN, DATA_OUT, REG_ADDR, READ, WRITE, SDA_OUT);
	input SCL_DLY;				// Filtered input clock
	input SDA_DLY;				// Filtered data input
	input [7:0] DATA_OUT; 		// Data being read from device
	output [7:0] REG_ADDR;		// Address pointer for registers
	output [7:0] DATA_IN; 		// Data being writen to device
	output READ;				// Triggers read data to load input DATA_OUT
	output WRITE;				// Triggers DATA_IN to write to registers 
	output SDA_OUT;				// Serial Data Output value

	reg [5:0] cnt;
	reg [1:0] state;
	reg [1:0] next_state; 
	reg START, WR_ACK;
	reg [7:0] SDA_OUT_REG; 
	reg [7:0] REG_ADDR;
	reg [7:0] DATA_IN;
	reg RWZ;
	reg ad_byte_flag;
	reg READ, WRITE;
	reg SDA_ACK;
	reg ACK_SLOT;
	
	parameter [6:0] slave_address = 7'h18;
	
	parameter [1:0]
	WAIT_FOR_START = 2'b00,
	CHECK_SLAVE_AD = 2'b01,
	WRITE_BYTE = 2'b10,
	READ_BYTE = 2'b11;

	initial 
	begin
		state = CHECK_SLAVE_AD;
		next_state = CHECK_SLAVE_AD;
		START = 0;
		cnt = 0;
		REG_ADDR = 8'h0;
		ad_byte_flag = 0;
		WRITE=0;
		READ =0;
		SDA_OUT_REG = 8'h0;
		RWZ = 1;
		WR_ACK = 1;
		ACK_SLOT = 0;
		SDA_ACK = 1;
	end

// Update / reset state machine
	always @(posedge SCL_DLY or START)
	begin
		if(START)
		begin
			state <= CHECK_SLAVE_AD;
			next_state <= CHECK_SLAVE_AD;
		end
		else
			state <= next_state;
	end
	
	always @(START or cnt)
		case(state)
			WAIT_FOR_START : 
			begin
				ad_byte_flag <= 0;
				WR_ACK <= 1;
				READ <= 0 ;
				WRITE <= 0;
				if(START) next_state <= CHECK_SLAVE_AD;
				else next_state <= WAIT_FOR_START;
			end
			CHECK_SLAVE_AD : 
			begin
				ad_byte_flag <= 0;
				WR_ACK <= 1;
				READ <= 0 ;
				WRITE <= 0;
				if(cnt==8)
				begin
					if(DATA_IN[7:1]==slave_address) // Check 7bit slave address
						WR_ACK <= 0; // Valid so ACK
					else
						WR_ACK <= 1; // Invalid so NACK
					RWZ <= DATA_IN[0];
					if(DATA_IN[0]) // Check RWZ bit
						begin
							next_state <= READ_BYTE;
							READ <= 1;
						end
					else
						next_state <= WRITE_BYTE;
				end
			end
			WRITE_BYTE : 
			begin
				if(cnt==8)
				begin
					if(ad_byte_flag==0)
					begin
						REG_ADDR <= DATA_IN;
						WR_ACK <= 0;
						ad_byte_flag <= 1;
					end
					else
					begin
						WRITE <= 1;
						WR_ACK <= 0;
					end
				end
				else if(WRITE)
					begin
						REG_ADDR <= REG_ADDR+1;
						WRITE <= 0;
					end
				else
				begin
					WRITE <= 0;
					WR_ACK <= 0;
				end
			end
			READ_BYTE : 
			begin
				if(cnt==7)
				begin
					WR_ACK <= 1;
					REG_ADDR <= REG_ADDR + 1;
				end
				else if(cnt==8)
					READ<=1;
				else 
					READ<=0;
			end
		endcase



	assign CLR_START = !SCL_DLY && START;

// Check for start of sequence 
	always @(negedge SDA_DLY or CLR_START)
		if(CLR_START)
			START <= 0;
		else if(SCL_DLY)
			START <= 1;
		else
			START <= 0;

// Create input data shift register
	always @(posedge SCL_DLY or START)
		if(START)
			DATA_IN<=8'h00;
		else if(cnt<8)
		begin
			DATA_IN[7]<=DATA_IN[6];
			DATA_IN[6]<=DATA_IN[5];
			DATA_IN[5]<=DATA_IN[4];
			DATA_IN[4]<=DATA_IN[3];
			DATA_IN[3]<=DATA_IN[2];
			DATA_IN[2]<=DATA_IN[1];
			DATA_IN[1]<=DATA_IN[0];
			DATA_IN[0]<=SDA_DLY;
		end

// Create bit counter
	always @(posedge SCL_DLY or START)
		if(START)
			cnt <= 0;
		else if(SCL_DLY && (cnt < 8))
			cnt <= cnt+1;
		else 
			cnt <= 0;

// Create output shift register
	always @(negedge SCL_DLY or START)
		if(START)
			SDA_OUT_REG <= 8'hFF;
		else if((cnt==8) && RWZ)
			SDA_OUT_REG <= DATA_OUT;
		else if(RWZ & (cnt>0))
		begin
			SDA_OUT_REG[7]<=SDA_OUT_REG[6];
			SDA_OUT_REG[6]<=SDA_OUT_REG[5];
			SDA_OUT_REG[5]<=SDA_OUT_REG[4];
			SDA_OUT_REG[4]<=SDA_OUT_REG[3];
			SDA_OUT_REG[3]<=SDA_OUT_REG[2];
			SDA_OUT_REG[2]<=SDA_OUT_REG[1];
			SDA_OUT_REG[1]<=SDA_OUT_REG[0];
			SDA_OUT_REG[0]<=SDA_DLY;
		end

	always @(negedge SCL_DLY or START)
		if(START)
			SDA_ACK = 1;
		else 
			SDA_ACK = WR_ACK;
		
	always @(negedge SCL_DLY or START)
		if(START)
			ACK_SLOT <= 0;
		else if(cnt==8)
			ACK_SLOT <= 1;
		else 
			ACK_SLOT <= 0;
		
		
	assign SDA_OUT = 	ACK_SLOT ? SDA_ACK :
	RWZ ? SDA_OUT_REG[7] : 1'b1; 

endmodule
