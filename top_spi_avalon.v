module top_spi_avalon (

	clk_120MHz,
	reset_n,
	// Avalon_MM
	av_address,
//	av_be_n,
	av_chip_select,
	av_wait_request,
//	av_wait_request_2,
//	av_wait_request_3,
	av_read,
	av_read_data,
	av_write,
	av_write_data,
	// SPI
	miso,
	sclk_25MHz,
	ss_n,
	mosi,
	clk_50MHz,
	irq
);

input		clk_120MHz;
input		reset_n;

// input Avalon 
input		av_chip_select;
input		av_write;
input		av_read;
input		[7:0]		av_address;
input		[31:0]	av_write_data;
//input		[3:0]		av_be_n;

// output Avalon
output	av_wait_request;
//output	av_wait_request_2;
//output	av_wait_request_3;

output	irq;
output	[31:0]	av_read_data;

//	input SPI
input		miso;

//	output SPI 
output	sclk_25MHz;
output	ss_n;
output	mosi;

output	clk_50MHz;

// Wire
wire	spi_go_transfer;
wire	data_pack_ready;
wire	irq;
wire	[31:0]	data_read_from_spi;
wire	[31:0]	data_write_to_spi;

wire	clk_120MHz;
wire	clk_50MHz;

avalon_slave avalon_slave_inst
(
	.clk(clk_120MHz) ,	// input  clk_sig
	.reset_n(reset_n) ,	// input  reset_n_sig
	.address(av_address),	
//	.be_n(av_be_n), 			
	.chip_select(av_chip_select) ,	// input  chip_select_sig
	.wait_request(av_wait_request) ,	// output  wait_request_sig
//	.wait_request_2(av_wait_request_2) ,	// output  wait_request_sig
//	.wait_request_3(av_wait_request_3) ,	// output  wait_request_sig
	.go_transfer(spi_go_transfer) ,	// output  go_transfer_sig
	.data_pack_ready(data_pack_ready) ,	// input  data_pack_ready_sig
	.read(av_read) ,	// input  read_n_sig
	.read_data(av_read_data) ,	// output [31:0] read_data_sig
	.data_read_from_spi(data_read_from_spi) ,	// input [31:0] data_read_from_spi_sig
	.write(av_write) ,	// input  write_n_sig
	.write_data(av_write_data) ,	// input [31:0] write_data_sig
	.data_write_to_spi(data_write_to_spi), 	// output [31:0] data_write_to_spi_sig
	.irq(irq) 	
);

spi_core spi_core_inst
(
	.clk(clk_50MHz) ,	// input  clk_sig
	.reset_n(reset_n) ,	// input  reset_n_sig
	.miso(miso) ,	// input  miso_sig
	.go_transfer(spi_go_transfer) ,	// input  go_transfer_sig
	.data_write_from_avalon(data_write_to_spi) ,	// input [31:0] data_write_from_avalon_sig
	.sclk(sclk_25MHz) ,	// output  sclk_sig
	.ss_n(ss_n) ,	// output  ss_n_sig
	.mosi(mosi) ,	// output  mosi_sig
	.data_read_to_avalon(data_read_from_spi) ,	// output [31:0] data_read_to_avalon_sig
	.data_pack_ready(data_pack_ready) 	// output  data_pack_ready_sig
);

pll	pll_inst 
(
	.inclk0 ( clk_120MHz ),
	.c0 ( clk_50MHz )
);

endmodule