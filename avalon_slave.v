module avalon_slave (

	clk,reset_n,
//	address,be_n, // poka zacomentim
	chip_select,
	wait_request,
	go_transfer,
	transfer_complete,
	read_n,
	read_data,
	data_read_from_spi,
	write_n,
	write_data,
	data_write_to_spi

//	go_transfer,data_write_from_avalon,
//	data_read_to_avalon
);

// input Avalon 
input		clk;
input		reset_n;
input		chip_select;

// addressoe prostranstvo //// 
// obi4no addressacia bait	///
// postavit` address
//
//input		[]	address;
//input		[3:0]	be_n;

// write Avalon 
input		write_n;
input		[31:0]	write_data;

// read Avalon 
input		read_n;
output	reg	[31:0]	read_data;

// output Avalon
output	reg		wait_request;

//	from SPI
input		transfer_complete;
input	[31:0]	data_read_from_spi;

//	to SPI 
output	reg [31:0]	data_write_to_spi;
output	reg			go_transfer;



//	STATE
//------------------------------------------------------
reg        [2:0] cmd_state;

localparam [2:0] IDLE          	= 0;

localparam [2:0] WAIT_END_WRITE  = 1;
localparam [2:0] WAIT_END_READ   = 2;
localparam [2:0] PAUSE   			= 3;
localparam [2:0] END_STATE      	= 4;


reg	flag_transfer;


always @(negedge clk or negedge reset_n)
	begin
		if(reset_n == 1'b0)
			begin
				//obnuliaem vse
				cmd_state      <=  IDLE;
				wait_request <= 1'b0;
				flag_transfer <= 1'b0;
				read_data <= 32'b0;
				data_write_to_spi <= 32'b0;
			end
		else if (chip_select == 1'b0)
			begin
				// napisano 4to dolgen vse signali ignorirovat`
				cmd_state      <=  IDLE;
				wait_request <= 1'b0;
				flag_transfer <= 1'b0;
				read_data <= 32'b0;
				data_write_to_spi <= 32'b0;
			end
		else
			begin
				case (cmd_state)
					IDLE : 
						begin
							if (write_n == 1'b0)
								begin
									wait_request <= 1'b1;
									flag_transfer <= 1'b1;
									data_write_to_spi <= write_data;
									cmd_state      <=  WAIT_END_WRITE;
								end
							else if(read_n == 1'b0) 
								begin
									wait_request <= 1'b1;
									flag_transfer <= 1'b1;
									cmd_state      <=  WAIT_END_READ;
								end
							else
								begin
									wait_request <= 1'b0;
									cmd_state      <=  IDLE;
								end
						end
						
				  WAIT_END_WRITE : 
						begin
							if (transfer_complete == 1'b1)
								begin
									cmd_state      <=  	PAUSE;
								end
							else 
								begin
									flag_transfer <= 1'b0;
									cmd_state      <=  WAIT_END_WRITE;
								end
						end             
				  WAIT_END_READ : 
						begin
							if (transfer_complete == 1'b1)
								begin
									read_data <= data_read_from_spi;
									cmd_state      <=  PAUSE;
								end
							else 
								begin
									flag_transfer <= 1'b0;
									cmd_state      <=  WAIT_END_READ;
								end
						end 
						
				  PAUSE : 
						begin
							if(transfer_complete <= 1'b0)
								cmd_state      <=  END_STATE;
						end
				  END_STATE : 
						begin
							wait_request <= 1'b0;
							cmd_state      <=  IDLE;
						end
					default :
						begin
							cmd_state      <=  IDLE;
							wait_request <= 1'b0;
							flag_transfer <= 1'b0;
						end

				endcase
			end
	end
	
	
	
///////////////////////////			
/////// go_transfer ///////

	reg [2:0]	cnt_go_transfer;

	always @(posedge clk or negedge reset_n)
		begin
			if (reset_n == 1'b0)
				begin
					go_transfer <= 1'b0;
					cnt_go_transfer <= 3'd0;
				end
			else
				begin
					if (cnt_go_transfer > 3'd0)
						begin
							cnt_go_transfer <= cnt_go_transfer - 1'b1;
							go_transfer <= 1'b1;
						end
					else
						begin
							go_transfer <= 1'b0;
							if(flag_transfer == 1)	// po prihody komandi na c4et4ik ystanavlivaetsia 
								begin					//			v "7" i idet obratnii ots4et
									cnt_go_transfer <= 3'd7; 
								end
						end
				end
		end


endmodule