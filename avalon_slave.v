///////////////////////////////////////////////////////////
////////////////////// REGISTERS //////////////////////////
///////////////////////////////////////////////////////////


//---------------------
// CONTROL_REGISTER 
//--------------------
// ADDRESS --0x00--
//--------------------
//	0- CS (CHIP_SELECT)
// 1- WR (CMD_WRITE_SPI)
// 2- RD (CMD_READ_SPI)
// 3- IRQ_RESET


//---------------------
// STATUS_REGISTER 
//---------------------
// ADDRESS --0x01--
//---------------------
//	0- SVOBODEN
// 1- IDET_ZAPIS
// 2- IDET_4TENIE
// 3- DATA_READ_READY_SPI


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
// CMD_RESET == 32'b_a5_a5_a5_a5;




module avalon_slave (

	clk,reset_n,
	address,
// be_n, 
	chip_select,
	wait_request,
//	wait_request_2,
//	wait_request_3,
	go_transfer,
	data_pack_ready,
	read,
	read_data,
	data_read_from_spi,
	transfer_complete,
	write,
	write_data,
	data_write_to_spi,
	irq
);

// input Avalon 
input		clk;
input		reset_n;
input		chip_select;

input		[7:0]	address;

// obi4no addressacia bait	///
//input		[3:0]	be_n;

// write Avalon 
input		write;
input		[31:0]	write_data;

// read Avalon 
input		read;
output	reg	[31:0]	read_data;

// output Avalon
output	wire		wait_request;
//output	wire		wait_request_2;
//output	wire		wait_request_3;


//	from SPI
input		data_pack_ready;
input	[31:0]	data_read_from_spi;

//	to SPI 
output	reg [31:0]	data_write_to_spi;
output	reg			irq;
output	wire			go_transfer;

assign go_transfer = flag_transfer;

output	transfer_complete;



///////////////////////////////////////////////////////////////////////////////////////
//assign wait_request_2 = !(!(read|write) & (cmd_state == IDLE));
//assign wait_request_3 = ((read|write) & (cmd_state == IDLE));	
///////////////////////////////////////////////////////////////////////////////////////



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




////////////////////////////////////////////////////////
//////////////// STATUS REGISTER ///////////////////////
//----------------------------------------------------//
reg        [1:0] status_reg;

localparam [1:0] svoboden       		= 0;
localparam [1:0] idet_zapis			= 1;
localparam [1:0] idet_4tenie		  	= 2;
localparam [1:0] data_read_ready	  	= 3;

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

// Quartus II Verilog Template
// 4-State Moore state machine

// A Moore machine's outputs are dependent only on the current state.
// The output is written only when the state changes.  (State
// transitions are synchronous.)

//module four_state_moore_state_machine
//(
//	input	clk, in, reset,
//	output reg [1:0] out
//);
///////////////////////////////////////////////////////////
////////////////////// REGISTERS //////////////////////////
///////////////////////////////////////////////////////////


//---------------------
// CONTROL_REGISTER 
//--------------------
// ADDRESS --0x00--
//--------------------
//	0- CS (CHIP_SELECT)
// 1- WR (CMD_WRITE_SPI)
// 2- RD (CMD_READ_SPI)
// 3- IRQ_RESET


//---------------------
// STATUS_REGISTER 
//---------------------
// ADDRESS --0x01--
//---------------------
//	0- SVOBODEN
// 1- IDET_ZAPIS
// 2- IDET_4TENIE
// 3- DATA_READ_READY_SPI


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


// poka ne delaiu

//---------------------
// RESET 
//---------------------
// ADDRESS --0x04--
//---------------------
// CMD_RESET == 32'b_a5_a5_a5_a5;




////////////////////////////////
///////// STATE ///////////////
//////////////////////////////

// Declare state register
reg        [2:0] state;

// Declare states

localparam [2:0] RESET		= 0;
localparam [2:0] IDLE   	= 1;
localparam [2:0] WRITE		= 2;
localparam [2:0] READ   	= 3;

	
reg	[31:0] reg_control;
reg	[31:0] reg_data_write;

	// Output depends only on the state
	always @ (state) 
		begin
			case (state)
				RESET:
					reg_control <= 32'b0;
					reg_data_write <= 32'b0;
					read_data <= 32'b0;
				IDLE:
//					nothing;
				WRITE:
					case (address)
						8'h0:
							reg_control <= write_data;
						8'h2:
							reg_data_write <= write_data;
					endcase
				READ:
					case (address)
						8'h1:
							read_data <= reg_status;
						8'h3:
							read_data <= reg_data_read;
					endcase
			endcase
		end

	// Determine the next state
	always @ (posedge clk or posedge reset_n) begin
		if (reset_n)
			state <= RESET;
		else
			case (state)
				RESET:
					state <= IDLE; // initial or reset
				IDLE:
					if (wr == 1'b1)
						state <= WRITE;
					else if (rd == 1'b1)
						state <= READ;
					else
						state <= IDLE;
				WRITE:
						state <= IDLE;
				READ:
						state <= IDLE;
			endcase
	end



////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
//		if (chip_select == 1'b0)
//			begin
//				//
//			end
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////



////////////////////////////////
//	STATE
//------------------------------------------------------
reg        [2:0] cmd_state;

localparam [2:0] IDLE          		= 0;
localparam [2:0] WRITE  				= 1;
localparam [2:0] WRITE_CMD_READ  	= 2;
localparam [2:0] READ   				= 3;
localparam [2:0] READ_STATUS_REG    = 4;

reg	flag_transfer;

always @(posedge clk or negedge reset_n)
	begin
		if(reset_n == 1'b0)
			begin
				//obnuliaem vse
				cmd_state      <=  IDLE;
				flag_transfer <= 1'b0;
				read_data <= 32'b0;
				data_write_to_spi <= 32'b0;
				status_reg <= svoboden;
				irq <= 1'b0;
			end
		else
			begin
				case (cmd_state)
					IDLE : 
						begin
							if (wr == 1'b1)
								begin
									if (address == 8'hff)
										begin
											cmd_state <=  WRITE_CMD_READ;
											flag_transfer <= 1'b1;
											data_write_to_spi <= 32'b0;
											status_reg <= idet_4tenie;
										end
									else
										begin
											cmd_state <= WRITE;
											flag_transfer <= 1'b1;
											data_write_to_spi <= write_data;
											status_reg <= idet_zapis;
										end
								end
							if (rd == 1'b1)
								begin
									if (address == 8'hff)
										begin
											cmd_state      <=  READ_STATUS_REG;
//											flag_transfer <= 1'b1;
//ili dage tak 						flag_transfer <= 1'b0;
											read_data [31:0] <= {{4{status_reg}},16'b0,{4{status_reg}}};
										end
									else if(status_reg == data_read_ready) //proverka yslovia nado? ili eto reshaet kontroller
										begin
											cmd_state      <=  READ;
//											flag_transfer <= 1'b1;
											irq <= 1'b0; // zaberi dannie
										end
								end
							if (status_reg == idet_4tenie && transfer_complete == 1'b1)
								begin
									// gotovi dannie dlia 4tenia
									read_data <= data_read_from_spi;
									status_reg <= data_read_ready; 
									// zaberi dannie
									irq <= 1'b1; 
								end
							if (status_reg == idet_zapis && transfer_complete == 1'b1)
								begin
									status_reg <= svoboden;
									// nado irq viveshivat` ili net???
									// vrode i ne nado
//									irq <= 1'b1; // dannie zapisani
									// dlitelnost irq????
								end
						end
						
					WRITE : 
						begin
							cmd_state      <=  IDLE;
							flag_transfer <= 1'b0;
							status_reg <= idet_zapis; // nado li ono?
						end             
					WRITE_CMD_READ : 
						begin
							cmd_state      <=  IDLE;
							flag_transfer <= 1'b0;
							status_reg <= idet_4tenie; // pod voprosom
						end             
					READ : 
						begin
							cmd_state      <=  IDLE;
							flag_transfer <= 1'b0;
							status_reg <= svoboden;
						end             
					READ_STATUS_REG : 
						begin
							cmd_state      <=  IDLE;
							flag_transfer <= 1'b0;
//							status_reg <= status_reg; // nado li tak pisat`????
						end 
						
					default :
						begin
							cmd_state      <=  IDLE;
							flag_transfer <= 1'b0;
							status_reg <= svoboden;
						end
				endcase
			end
	end
	


	
/////////////////////////////			
///////// go_transfer ///////
//
//	reg [2:0]	cnt_go_transfer;
//
//	always @(posedge clk or negedge reset_n)
//		begin
//			if (reset_n == 1'b0)
//				begin
//					go_transfer <= 1'b0;
//					cnt_go_transfer <= 3'd0;
//				end
//			else
//				begin
//					if (cnt_go_transfer > 3'd0)
//						begin
//							cnt_go_transfer <= cnt_go_transfer - 1'b1;
//							go_transfer <= 1'b1;
//						end
//					else
//						begin
//							go_transfer <= 1'b0;
//							if(flag_transfer == 1)	// po prihody komandi na c4et4ik ystanavlivaetsia 
//								begin						//			v "7" i idet obratnii ots4et
//									cnt_go_transfer <= 3'd7; 
//								end
//						end
//				end
//		end


endmodule