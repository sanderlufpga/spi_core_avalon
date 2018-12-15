module spi_core (

	clk,reset_n,miso,
	go_transfer,data_write_from_avalon,

	sclk,ss_n,mosi,
	data_read_to_avalon,
	data_pack_ready
);

// input SPI 
input		clk;
input		reset_n;
input		miso;

// output SPI
output	reg	sclk;
output	reg	ss_n;
output	reg	mosi;

//avalon input
input		go_transfer;
input	[31:0]	data_write_from_avalon;

//avalon output
output	reg [31:0]	data_read_to_avalon;
output	reg			data_pack_ready;



//CPOL = 0 — сигнал синхронизации начинается с низкого уровня;
//CPOL = 1 — сигнал синхронизации начинается с высокого уровня;
//CPHA = 0 — выборка данных производится по переднему фронту сигнала синхронизации;
//CPHA = 1 — выборка данных производится по заднему фронту сигнала синхронизации.
//
//Для обозначения режимов работы интерфейса SPI принято следующее соглашение: 
//режим 0 (CPOL = 0, CPHA = 0);
//режим 1 (CPOL = 0, CPHA = 1);
//режим 2 (CPOL = 1, CPHA = 0);
//режим 3 (CPOL = 1, CPHA = 1).



//режим 0 (CPOL = 0, CPHA = 0);
//CPOL = 0 — сигнал синхронизации начинается с низкого уровня;
//CPHA = 0 — выборка данных производится по переднему фронту сигнала синхронизации;

/////////////////////////////////////////////
//  only for modelsim, because we had errors
reg	transfer_complete;
/////////////////////////////////////


reg	[31:0]	data_write;
reg	[2:0]		cnt_transfer;
reg	[7:0]		data_spi_write;
reg	flag_transfer;

always @(negedge clk or negedge reset_n)
		begin
			if(reset_n == 0)
				begin
					flag_transfer <= 1'b0;
					data_write <= 32'b0;
					cnt_transfer <= 3'b0;
					data_spi_write <= 8'b0;
					data_pack_ready <= 1'b0;
				end
			else
				begin
					if (cnt_transfer > 3'b0)
						begin
							if(transfer_complete == 1'b1)
								begin
									flag_transfer <= 1'b0;
									cnt_transfer <= cnt_transfer - 1'b1;
									if(cnt_transfer == 3'b1)
										begin
											data_pack_ready <= 1'b1;// pa4ka dannih gotova
										end
								end
							else
								begin
									flag_transfer <= 1'b1;
								end
							case(cnt_transfer)
									3'd4:
										data_spi_write[7:0] <= data_write[7:0];
									3'd3:
										data_spi_write[7:0] <= data_write[15:8];
									3'd2:
										data_spi_write[7:0] <= data_write[23:16];
									3'd1:
										data_spi_write[7:0] <= data_write[31:24];
								endcase
						end
					else if (go_transfer == 1'b1)
						begin
//							flag_transfer <= 1'b1; mogno i tak diagramma sdvinetsia na takt v levo. nado li tak??
							data_write <= data_write_from_avalon;
							cnt_transfer <= 3'd4;
						end
					else
						begin
							flag_transfer <= 1'b0;
							data_pack_ready <= 1'b0;
						end
						
				end
		end

			
		
		
always @ (posedge clk or negedge reset_n)
	begin
		if(reset_n == 1'b0)
			begin
				sclk <= 1'b0;
			end
		else
			begin
			  if (ss_n == 1'b0)
				  sclk <= ~sclk;
				 else
				   sclk <= 1'b0;
			end
	end
	



reg	[7:0]	data_spi_read;
reg	[3:0]	cnt_bit;

reg	takt_transfer;
reg	go_write;
reg	go_read;
//

always @(posedge clk or negedge reset_n)
	begin
		if(reset_n == 0)
			begin
				//obnuliaem
				ss_n	<= 1'b1;
				mosi <= 1'b0;
				data_spi_read <= 8'b0;
				cnt_bit <= 4'b0;
				takt_transfer <= 1'b0;
				transfer_complete <= 1'b0;
				data_read_to_avalon <= 32'b0;
			end
		else
			begin
			//write or read
				if(flag_transfer == 1'b1)
					begin
						if (cnt_bit < 4'd8)
							begin
								case(takt_transfer)
								1'b0:	// 1 takt 
									begin
										ss_n	<= 1'b0;
										mosi <= data_spi_write[cnt_bit];
										takt_transfer <= 1'b1;
									end
								1'b1:	// 2 takt
									begin
										data_spi_read[cnt_bit] <= miso;
										cnt_bit <= cnt_bit + 1'b1;
										takt_transfer <= 1'b0;
									end
								endcase
							end
						else
							begin
								ss_n <= 1'b1;
								takt_transfer <= 1'b0;
								transfer_complete <= 1'b1;
								case(cnt_transfer)
									3'd4:
										data_read_to_avalon[7:0] <= data_spi_read[7:0];
									3'd3:
										data_read_to_avalon[15:8] <= data_spi_read[7:0];
									3'd2:
										data_read_to_avalon[23:16] <= data_spi_read[7:0];
									3'd1:
										data_read_to_avalon[31:24] <= data_spi_read[7:0];
								endcase
							end
					end
			//edle
				else
					begin
						ss_n <= 1'b1;
						cnt_bit 	<= 4'b0;
						takt_transfer <= 1'b0;
						transfer_complete <= 1'b0;
					end
			end
		//
	end
	

	
	
////////////////////////			
///////// reset ///////
//
//	assign 	reset = hard_reset & !reset_from_pc;
//
//	reg [5:0]	cnt_reset_pc;
//	reg			reset_from_pc;
//
//	always @(posedge clk_from_fpga or negedge hard_reset)
//		begin
//			if (hard_reset == 1'b0)
//				begin
//					reset_from_pc <= 1'b0;
//					cnt_reset_pc <= 6'd0;
//				end
//			else
//				begin
//					if (cnt_reset_pc > 6'd0)
//						begin
//							cnt_reset_pc <= cnt_reset_pc - 1'b1;
//							reset_from_pc <= 1'b1;
//						end
//					else
//						begin
//							reset_from_pc <= 1'b0;
//							if(cmd_reset == 1)	// po prihody komandi na "reset" c4et4ik ystanavlivaetsia 
//								begin					//			v "63" i idet obratnii ots4et
//									cnt_reset_pc <= 6'd63; 
//								end
//						end
//				end
//		end
//
//	

endmodule