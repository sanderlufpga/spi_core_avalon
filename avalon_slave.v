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
/////////// wait_request srazy otve4aem 1 taktom videliaia ego front

wire wr_rd;
assign wr_rd = write | read;

reg delay_wr_rd;
always @(posedge clk or negedge reset_n)
	begin
		if(reset_n == 1'b0)
			begin
				delay_wr_rd <= 1'b0; 
			end
		else
			begin
				delay_wr_rd <= wr_rd; 
			end
	end

assign wait_request = ~delay_wr_rd & wr_rd;

////////////////////////////////////////////////////////////////////////////////////////////////
/////////// videliaem front dlitelnost`u 2 takta iz  data_pack_ready ot drygoi 4astoti


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


////////////////////////////////
//	STATE
//------------------------------------------------------
reg        [2:0] cmd_state;

localparam [2:0] IDLE          		= 0;
localparam [2:0] WRITE  				= 1;
localparam [2:0] WRITE_CMD_READ  	= 2;
localparam [2:0] READ   				= 3;
localparam [2:0] READ_STATUS_REG    = 4;


////////////////////////////////
//	STATUS REGISTER
//------------------------------------------------------
reg        [1:0] status_reg;

localparam [1:0] svoboden       		= 0;
localparam [1:0] idet_zapis			= 1;
localparam [1:0] idet_4tenie		  	= 2;
localparam [1:0] data_read_ready	  	= 3;


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
		else if (chip_select == 1'b0)
			begin
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
							if (write == 1'b1)
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
							if (read == 1'b1)
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