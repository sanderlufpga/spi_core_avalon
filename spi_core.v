// by Sander_Lu
module spi_core (

	clk,reset_n,miso,
	go_transfer,data_from_avalon,

	sclk,ss_n,mosi,
	data_read
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
input	[31:0]	data_from_avalon;

//avalon output
output	[31:0]	data_read;



//CPOL = 0 вЂ” СЃРёРіРЅР°Р» СЃРёРЅС…СЂРѕРЅРёР·Р°С†РёРё РЅР°С‡РёРЅР°РµС‚СЃСЏ СЃ РЅРёР·РєРѕРіРѕ СѓСЂРѕРІРЅСЏ;
//CPOL = 1 вЂ” СЃРёРіРЅР°Р» СЃРёРЅС…СЂРѕРЅРёР·Р°С†РёРё РЅР°С‡РёРЅР°РµС‚СЃСЏ СЃ РІС‹СЃРѕРєРѕРіРѕ СѓСЂРѕРІРЅСЏ;
//CPHA = 0 вЂ” РІС‹Р±РѕСЂРєР° РґР°РЅРЅС‹С… РїСЂРѕРёР·РІРѕРґРёС‚СЃСЏ РїРѕ РїРµСЂРµРґРЅРµРјСѓ С„СЂРѕРЅС‚Сѓ СЃРёРіРЅР°Р»Р° СЃРёРЅС…СЂРѕРЅРёР·Р°С†РёРё;
//CPHA = 1 вЂ” РІС‹Р±РѕСЂРєР° РґР°РЅРЅС‹С… РїСЂРѕРёР·РІРѕРґРёС‚СЃСЏ РїРѕ Р·Р°РґРЅРµРјСѓ С„СЂРѕРЅС‚Сѓ СЃРёРіРЅР°Р»Р° СЃРёРЅС…СЂРѕРЅРёР·Р°С†РёРё.
//
//Р”Р»СЏ РѕР±РѕР·РЅР°С‡РµРЅРёСЏ СЂРµР¶РёРјРѕРІ СЂР°Р±РѕС‚С‹ РёРЅС‚РµСЂС„РµР№СЃР° SPI РїСЂРёРЅСЏС‚Рѕ СЃР»РµРґСѓСЋС‰РµРµ СЃРѕРіР»Р°С€РµРЅРёРµ: 
//СЂРµР¶РёРј 0 (CPOL = 0, CPHA = 0);
//СЂРµР¶РёРј 1 (CPOL = 0, CPHA = 1);
//СЂРµР¶РёРј 2 (CPOL = 1, CPHA = 0);
//СЂРµР¶РёРј 3 (CPOL = 1, CPHA = 1).


// СЂР°Р±РѕС‚Р°РµРј РІ СЂРµР¶РёРјРµ "0"
//CPOL = 0 вЂ” СЃРёРіРЅР°Р» СЃРёРЅС…СЂРѕРЅРёР·Р°С†РёРё РЅР°С‡РёРЅР°РµС‚СЃСЏ СЃ РЅРёР·РєРѕРіРѕ СѓСЂРѕРІРЅСЏ;
//CPHA = 0 вЂ” РІС‹Р±РѕСЂРєР° РґР°РЅРЅС‹С… РїСЂРѕРёР·РІРѕРґРёС‚СЃСЏ РїРѕ РїРµСЂРµРґРЅРµРјСѓ С„СЂРѕРЅС‚Сѓ СЃРёРіРЅР°Р»Р° СЃРёРЅС…СЂРѕРЅРёР·Р°С†РёРё;

/////////////////////////////////////////////
//  only for modelsim, because we had errors
reg	transfer_complete;
/////////////////////////////////////


reg	[31:0]	data_write;
reg	[2:0]		cnt_transfer;
reg	flag_transfer;

always @(negedge clk or negedge reset_n)
		begin
			if(reset_n == 0)
				begin
					flag_transfer <= 1'b0;
					data_write <= 8'b0;
					cnt_transfer <= 3'b0;
				end
			else
				begin
					if (cnt_transfer > 3'b0)
						begin
							if(transfer_complete == 1'b1)
								begin
									flag_transfer <= 1'b0;
									cnt_transfer <= cnt_transfer - 1'b1;
								end
							else
								begin
									flag_transfer <= 1'b1;
								end
						end
					else if (go_transfer == 1'b1)
						begin
//							flag_transfer <= 1'b1; mogno i tak diagramma sdvinetsia na takt v levo. nado li tak??
							data_write <= data_from_avalon;
							cnt_transfer <= 3'd4;
						end
					else
						begin
							flag_transfer <= 1'b0;
						end
						
				end
		end

			
		
		
//reg	sclk;
//reg 	sclk_delay;

always @ (posedge clk or negedge reset_n)
	begin
		if(reset_n == 1'b0)
			begin
				sclk <= 1'b0;
//				sclk_delay <= 1'b0;
			end
		else
			begin
			  if (ss_n == 1'b0)
				  sclk <= ~sclk;
				 else
				   sclk <= 1'b0;
//				sclk_delay <= sclk;
			end
	end
	
//assign sclk_out = sclk;



reg	[7:0]	data_spi_write;
reg	[7:0]	data_spi_read;
reg	[7:0]	data_read;
reg	[3:0]	cnt_bit;

//reg	transfer_complete;
reg	takt_transfer;
reg	go_write;
reg	go_read;


always @(posedge clk or negedge reset_n)
	begin
		if(reset_n == 0)
			begin
				//obnuliaem
				ss_n	<= 1'b1;
				mosi <= 1'b0;
				data_spi_write <= 8'b0;
				data_spi_read <= 8'b0;
				cnt_bit <= 4'b0;
				takt_transfer <= 1'b0;
				transfer_complete <= 1'b0;
				data_read <= 8'b0;
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
								data_read <= data_spi_read; //podumat` kak opisat`
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