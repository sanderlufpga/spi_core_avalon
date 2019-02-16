

///////////////////////////////////////////////////////////
////////////////////// REGISTERS //////////////////////////
///////////////////////////////////////////////////////////



//---------------------
// CONTROL_REGISTER 
//--------------------
// ADDRESS --0x00--
//--------------------
// 0- WR (CMD_WRITE_SPI)
// 1- RD (CMD_READ_SPI)
// 2- IRQ_RESET
// 3- IRQ_WR_ENABLE
// 4- IRQ_RD_ENABLE


//---------------------
// STATUS_REGISTER 
//---------------------
// ADDRESS --0x01--
//---------------------
// 0- IDET_ZAPIS				//	00- SVOBODEN	//	01- IDET_ZAPIS
// 1- IDET_4TENIE				//	00- SVOBODEN	//	10- IDET_4TENIE
// 2- empty
// 3- IRQ_WR_READY
// 4- IRQ_RD_READY


//---------------------
// DATA_WRITE_REGISTER 
//---------------------
// ADDRESS --0x02--
//---------------------
// ALL 32 BIT


//---------------------
// DATA_READ_REGISTER 
//---------------------
// ADDRESS --0x03--
//---------------------
// ALL 32 BIT


//---------------------
// RESET 
//---------------------
// ADDRESS --0x04--
//---------------------
// CMD_RESET == 32'h_a5_a5_a5_a5;




///////////////////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------------------//
///////////////////////////////////////////////////////////////////////////////////////



module avalon_slave (

	clk,hard_reset,
	reset_n,
	address,
	chip_select,
	wait_request,
	go_transfer,
	data_pack_ready,
	read,
	read_data,
	data_read_from_spi,
	transfer_complete,
	write,
	write_data,
	data_write_to_spi,
	irq,
	go_tr,
	flag_st_a
);

// input Avalon 
input		clk;
input		hard_reset;
input		chip_select;

input		[7:0]	address;

// write Avalon 
input		write;
input		[31:0]	write_data;

// read Avalon 
input		read;
output	reg	[31:0]	read_data;

// output Avalon
output	wire		wait_request;
output	wire		reset_n;


//	from SPI
input		data_pack_ready;
input	[31:0]	data_read_from_spi;

//	to SPI 
output	wire [31:0]	data_write_to_spi;
output	reg			irq;
output	wire			go_transfer;

output	transfer_complete;
output	[2:0]	flag_st_a;
output	go_tr;


//assign go_transfer = go_write || go_read;
assign go_transfer = go_tr;

assign data_write_to_spi = reg_data_write;



///////////////////////////////////////////////////////////////////////////////////////
/////////// "wait_request" srazy otve4aem 2 taktom videliaia ego front ////////////////
//-----------------------------------------------------------------------------------//
///////////////////////////////////////////////////////////////////////////////////////
wire wr_rd;
assign wr_rd = write | read;

reg delay_wr_rd_1;
reg delay_wr_rd_2;

always @(posedge clk or negedge reset_n)
	begin
		if(reset_n == 1'b0)
			begin
				delay_wr_rd_1 <= 1'b0; 
				delay_wr_rd_2 <= 1'b0; 
			end
		else
			begin
				delay_wr_rd_1 <= wr_rd; 
				delay_wr_rd_2 <= delay_wr_rd_1; 
			end
	end

assign wait_request = ~delay_wr_rd_2 & wr_rd;


////////////////
///// WR ///////
////////////////

reg delay_wr_1;
reg delay_wr_2;

always @(posedge clk or negedge reset_n)
	begin
		if(reset_n == 1'b0)
			begin
				delay_wr_1 <= 1'b0; 
				delay_wr_2 <= 1'b0; 
			end
		else
			begin
				delay_wr_1 <= write; 
				delay_wr_2 <= delay_wr_1; 
			end
	end

wire	wr;
assign wr = (reset_n == 0) ? (1'b0) : (~delay_wr_2 & delay_wr_1);


////////////////
///// RD	///////
////////////////

reg delay_rd_1;
reg delay_rd_2;

always @(posedge clk or negedge reset_n)
	begin
		if(reset_n == 1'b0)
			begin
				delay_rd_1 <= 1'b0; 
				delay_rd_2 <= 1'b0; 
			end
		else
			begin
				delay_rd_1 <= read; 
				delay_rd_2 <= delay_rd_1; 
			end
	end

wire	rd;
assign rd = (reset_n == 0) ? (1'b0) : (~delay_rd_2 & delay_rd_1);



////////////////////////////////
///////// STATE ///////////////
//////////////////////////////

// Declare state register
reg	[1:0] state_a;

// Declare states
localparam [1:0] av_RESET		= 0;
localparam [1:0] av_IDLE   	= 1;
localparam [1:0] av_WRITE		= 2;
localparam [1:0] av_READ   	= 3;

// Determine the next state
	always @ (posedge clk or negedge reset_n) 
		begin
			if (reset_n == 1'b0)
				state_a <= av_RESET;
			else
				case (state_a)
					av_RESET:
						state_a <= av_IDLE; // initial or reset
					av_IDLE:
						if (chip_select == 1'b1)
							begin
								if (wr == 1'b1)
									state_a <= av_WRITE;
								else if (rd == 1'b1)
									state_a <= av_READ;
								else
									state_a <= av_IDLE;
							end
						else
							state_a <= av_IDLE;
					av_WRITE:
							state_a <= av_IDLE;
					av_READ:
							state_a <= av_IDLE;
				endcase
		end


reg	[2:0]	flag_st_a;	

// Output depends only on the state
//	always @ (state_a) 
	always @ (posedge clk) 
		begin
			case (state_a)
				av_RESET:
					begin
						flag_st_a <= 3'b000;
					end
				av_IDLE:
					begin
						flag_st_a <= 3'b001;
					end
				av_WRITE:
					begin
						if(address == 8'h0)
							begin
								flag_st_a <= 3'b010;
							end
						if(address == 8'h2)
							begin
								flag_st_a <= 3'b011;
							end
						if(address == 8'h4)
							begin
								flag_st_a <= 3'b111;
							end
					end
				av_READ:
					begin
						if(address == 8'h1)
							begin
								flag_st_a <= 3'b100;
							end
						if(address == 8'h3)
							begin
								flag_st_a <= 3'b101;
							end
					end
				default:
					begin
						flag_st_a <= 3'b000;
					end
			endcase
		end

		
		
reg	[31:0] reg_control;
reg	[31:0] reg_data_write;
reg	[31:0] reg_cmd_reset;
		
always @(posedge clk or negedge reset_n)
	begin
		if(reset_n == 1'b0)
			begin
				reg_control <= 32'b0;
				reg_data_write <= 32'b0;
				read_data <= 32'b0;
				reg_cmd_reset <= 32'b0;
			end
//		else	if(delay_go_write == 1'b1)
		else	if(go_write == 1'b1)
			begin
				reg_control[0] <= 1'b0;	// sbros 'cmd_wr' po "go_write"
			end
//		else	if(delay_go_read == 1'b1)
		else	if(go_read == 1'b1)
			begin
				reg_control[1] <= 1'b0;	// sbros 'cmd_rd' po "go_read"
			end
		else	if(irq_reset == 1'b1)
			begin
				reg_control[2] <= 1'b0;	// sbros 'cmd_irq_reset' po "irq_reset"
			end
		else
			begin
				case(flag_st_a)
					3'b010: 
						begin
							reg_control <= write_data;
						end
					3'b011: 
						begin
							reg_data_write <= write_data;
						end
					3'b100: 
						begin
							read_data <= reg_status;
						end
					3'b101: 
						begin
							read_data <= reg_data_read;
						end
					3'b111: 
						begin
							reg_cmd_reset <= write_data; // cmd_RESET == 32'h_a5_a5_a5_a5;
						end
				endcase
			end
	end



//////////////////////
///// go_write	///////
//////////////////////

reg delay_flag_wr_1;
reg delay_flag_wr_2;

always @(posedge clk or negedge reset_n)
	begin
		if(reset_n == 1'b0)
			begin
				delay_flag_wr_1 <= 1'b0; 
				delay_flag_wr_2 <= 1'b0; 
			end
		else
			begin
				delay_flag_wr_1 <= reg_control[0];
				delay_flag_wr_2 <= delay_flag_wr_1;
			end
	end
	
wire	go_write;
assign go_write = (reset_n == 0) ? (1'b0) : (~delay_flag_wr_2 & delay_flag_wr_1);



//////////////////////
///// go_read	///////
//////////////////////

reg delay_flag_rd_1;
reg delay_flag_rd_2;

always @(posedge clk or negedge reset_n)
	begin
		if(reset_n == 1'b0)
			begin
				delay_flag_rd_1 <= 1'b0; 
				delay_flag_rd_2 <= 1'b0; 
			end
		else
			begin
				delay_flag_rd_1 <= reg_control[1];
				delay_flag_rd_2 <= delay_flag_rd_1;
			end
	end
	
wire	go_read;
assign go_read = (reset_n == 0) ? (1'b0) : (~delay_flag_rd_2 & delay_flag_rd_1);


////////////////////////
///// irq_enable ///////
////////////////////////
// reg_control [..]
// 2- IRQ_RESET
// 3- IRQ_WR_ENABLE
// 4- IRQ_RD_ENABLE
reg irq_reset;
reg irq_wr_enable;
reg irq_rd_enable;

always @(posedge clk or negedge reset_n)
	begin
		if(reset_n == 1'b0)
			begin
				irq_reset <= 1'b0; 
				irq_wr_enable <= 1'b0; 
				irq_rd_enable <= 1'b0; 
			end
		else
			begin
				irq_reset <= reg_control[2];
				irq_wr_enable <= reg_control[3];
				irq_rd_enable <= reg_control[4];
			end
	end

	
	
/////////////////////////////////////////////////
///// 'delay_go_read' or 'delay_go_write' ///////
/////////////////////////////////////////////////
//
//reg delay_go_write;
//reg delay_go_read;
//
//always @(posedge clk or negedge reset_n)
//	begin
//		if(reset_n == 1'b0)
//			begin
//				delay_go_write <= 1'b0; 
//				delay_go_read <= 1'b0; 
//			end
//		else
//			begin
//				delay_go_write <= go_write;
//				delay_go_read <= go_read;
//			end
//	end


//////////////////////////
/////// reg_status ///////
//////////////////////////


// Quartus II Verilog Template
// 4-State Moore state machine

// A Moore machine's outputs are dependent only on the current state.
// The output is written only when the state changes.  (State
// transitions are synchronous.)

// Declare state register
reg	[2:0] state_s;
reg	[1:0] status;
	
// Declare states
localparam [2:0] RESET_S		= 0;
localparam [2:0] IDLE_S   		= 1;
localparam [2:0] WRITE_S		= 2;
localparam [2:0] READ_S   		= 3;
localparam [2:0] WRITE_END_S	= 4;
localparam [2:0] READ_END_S   = 5;

// Determine the next state
	always @ (posedge clk or negedge reset_n) 
		begin
			if (reset_n == 0)
				state_s <= IDLE_S;
			else
				case (state_s)
					RESET_S:
						state_s <= IDLE_S;
					IDLE_S:
						if (go_write)
							state_s <= WRITE_S;
						else if (go_read)
							state_s <= READ_S;
						else
							state_s <= IDLE_S;
					WRITE_S:
							state_s <= WRITE_END_S;
					READ_S:
							state_s <= READ_END_S;
					WRITE_END_S:
						if (transfer_complete)
							state_s <= IDLE_S;
						else
							state_s <= WRITE_END_S;
					READ_END_S:
						if (transfer_complete)
							state_s <= IDLE_S;
						else
							state_s <= READ_END_S;
				endcase
		end

reg	go_tr;
reg	[31:0] reg_data_read;

// Output depends only on the state
	always @ (posedge clk) 
//	always @ (state_s) 
		begin
			case (state_s)
				RESET_S:
					begin
						status <= 2'b00;
						go_tr <= 1'b0;
					end
				IDLE_S:
					begin
						status <= 2'b00;
						go_tr <= 1'b0;
					end
				WRITE_S:
					begin
						status <= 2'b01;
						go_tr <= 1'b1;
					end
				READ_S:
					begin
						status <= 2'b10;
						go_tr <= 1'b1;
					end
				WRITE_END_S:
					begin
						go_tr <= 1'b0;
						if(transfer_complete == 1'b1)
							begin
								status <= 2'b11;
							end
						else
							begin
								status <= 2'b01;
							end
					end
				READ_END_S:
					begin
						go_tr <= 1'b0;
						if(transfer_complete == 1'b1)
							begin
								status <= 2'b11;
								reg_data_read <= data_read_from_spi;
							end
						else
							begin
								status <= 2'b10;
							end
					end
				default:
					begin
						status = 2'b00;
						go_tr <= 1'b0;
					end
			endcase
		end

		
//---------------------
// STATUS_REGISTER 
//---------------------
// ADDRESS --0x01--
//---------------------
// 0- IDET_ZAPIS				//	00- SVOBODEN	//	01- IDET_ZAPIS
// 1- IDET_4TENIE				//	00- SVOBODEN	//	10- IDET_4TENIE
// 2- empty
// 3- IRQ_WR_READY
// 4- IRQ_RD_READY

reg	[31:0] reg_status;

always @(posedge clk or negedge reset_n)
	begin
		if(reset_n == 1'b0)
			begin
				reg_status <= 32'b0;
			end
		else
			begin
				reg_status <= {27'b0,irq_rd,irq_wr,1'b0,status};
			end
	end
	


reg	irq_wr;
reg	irq_rd;

always @(posedge clk or negedge reset_n)
	begin
		if(reset_n == 1'b0)
			begin
				irq_wr <= 1'b0;
				irq_rd <= 1'b0;
			end
		else if(irq_reset == 1'b1)
			begin
				irq_wr <= 1'b0;
				irq_rd <= 1'b0;
			end
		else
			begin
				if((irq_wr_enable == 1'b1) && (status == 2'b11))
					begin
						irq_wr <= 1'b1;
					end
				if((irq_rd_enable == 1'b1) && (status == 2'b11))
					begin
						irq_rd <= 1'b1;
					end
			end
	end
	
	
	
	
//reg	[31:0] irq;

always @(posedge clk or negedge reset_n)
	begin
		if(reset_n == 1'b0)
			begin
				irq <= 1'b0;
			end
		else if(irq_reset == 1'b1)
			begin
				irq <= 1'b0;
			end
		else
			begin
				irq <= irq_wr || irq_rd;
			end
	end
		

		
/////////////////////////////////////////////////////////////////////////////////////////
////// videliaem front dlitelnost`u 1 takt iz  "data_pack_ready" ///////////////////////
//-------------------------------------------------------------------------------------//
/////////////////////////////////////////////////////////////////////////////////////////
		
reg	spi_trans_compl;
reg	delay_spi_trans_compl;

always @(posedge clk or negedge reset_n)
	begin
		if(reset_n == 1'b0)
			begin
				spi_trans_compl <= 1'b0;
				delay_spi_trans_compl <= 1'b0;
			end
		else
			begin
				spi_trans_compl <= ~data_pack_ready;
				delay_spi_trans_compl <= spi_trans_compl;
			end
	end

wire	transfer_complete;
assign transfer_complete = (reset_n == 0) ? (1'b0) : (~delay_spi_trans_compl & spi_trans_compl);
		

	
//////////////////////////////////////////////////////////
///////////////////// CMD_RESET //////////////////////////
////----------------------------------------------------//
//////////////////////////////////////////////////////////


// reg_cmd_reset // 
// CMD_RESET == 32'h_a5_a5_a5_a5;

assign 	reset_n = hard_reset & !cmd_RESET;

reg [5:0]	cnt_rst;
reg			cmd_RESET;

always @(posedge clk or negedge hard_reset)
	begin
		if (hard_reset == 1'b0)
			begin
				cmd_RESET <= 1'b0;
				cnt_rst <= 6'd0;
			end
		else
			begin
				if (cnt_rst > 6'd0)
					begin
						cnt_rst <= cnt_rst - 1'b1;
						cmd_RESET <= 1'b1;
					end
				else
					begin
						cmd_RESET <= 1'b0;
						if(reg_cmd_reset == 32'h_a5_a5_a5_a5)	// po prihody komandi na "reset" c4et4ik ystanavlivaetsia 
							begin											//			v "63" i idet obratnii ots4et
								cnt_rst <= 6'd63; 
							end
					end
			end
	end

	



//////////////////////////////////////////////////////////
////////////////// __ ///////////////////////
////----------------------------------------------------//

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////



	
	
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
//		if ()
//			begin
//				//
//			end
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

	


endmodule