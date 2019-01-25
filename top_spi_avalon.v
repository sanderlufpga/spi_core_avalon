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
	
//	test_go_transfer,
//	test_wr_fifo_empty,
//	test_transfer_complete,
//	test_rd_fifo_empty
);

//output	test_go_transfer;
//wire	test_go_transfer;
//assign	test_go_transfer = go_transfer;
//
//
//output	test_wr_fifo_empty;
//wire	test_wr_fifo_empty;
//assign	test_wr_fifo_empty = wr_fifo_empty;
//
//
//output	test_transfer_complete;
//wire	test_transfer_complete;
//assign	test_transfer_complete = transfer_complete;
//
//output	test_rd_fifo_empty;
//wire	test_rd_fifo_empty;
//assign	test_rd_fifo_empty = rd_fifo_empty;



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
wire	go_transfer;
wire	data_pack_ready;
wire	irq;
wire	[31:0]	data_write_to_spi;
wire	[31:0]	data_read_from_spi;

wire	[31:0]	data_read_to_avalon;
wire	[31:0]	data_write_from_avalon;

wire	clk_120MHz;
wire	clk_50MHz;

pll	pll_inst 
(
	.inclk0 	(clk_120MHz),
	.c0 		(clk_50MHz)
);


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
	.go_transfer(wr_fifo_wrreq) ,	// output  go_transfer_sig
	.data_pack_ready(rd_fifo_empty) ,	// input  data_pack_ready_sig
	.read(av_read) ,	// input  read_n_sig
	.read_data(av_read_data) ,	// output [31:0] read_data_sig
	.data_read_from_spi(data_read_from_spi) ,	// input [31:0] data_read_from_spi_sig
	.transfer_complete(rd_fifo_rdreq),
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
	.go_transfer(wr_fifo_empty) ,	// input  go_transfer_sig
	.data_write_from_avalon(data_write_from_avalon) ,	// input [31:0] data_write_from_avalon_sig
	.sclk(sclk_25MHz) ,	// output  sclk_sig
	.ss_n(ss_n) ,	// output  ss_n_sig
	.mosi(mosi) ,	// output  mosi_sig
	.data_read_to_avalon(data_read_to_avalon) ,	// output [31:0] data_read_to_avalon_sig
	.data_pack_ready(rd_fifo_wrreq), 	// output  data_pack_ready_sig
	.wr_fifo_rdreq(wr_fifo_rdreq)
);
	
/////////////////////////////////////////////////////////////////////////////////////////
////////////// FIFO for WRITE data to SPI	//////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////

wire	reset;
assign	reset = ~reset_n;

////// WRITE FIFO
wire	wr_fifo_wrreq;
wire	wr_fifo_full;
wire	wr_fifo_empty;
wire	wr_fifo_rdreq;

 fifo fifo_write_spi(
	.aclr(reset),
	
	.wrclk(clk_120MHz),
	.wrreq(wr_fifo_wrreq),
	.data(data_write_to_spi),
	.wrfull(wr_fifo_full), // ne ispolzuetsia
	
	.rdclk(clk_50MHz),
	.rdreq(wr_fifo_rdreq),
	.q(data_write_from_avalon),
	.rdempty(wr_fifo_empty)
	);
	
	
////// WRITE FIFO
wire	rd_fifo_wrreq;
wire	rd_fifo_full;
wire	rd_fifo_empty;
wire	rd_fifo_rdreq;
	
 fifo fifo_read_spi(
	.aclr(reset),
	
	.wrclk(clk_50MHz),
	.wrreq(rd_fifo_wrreq),
	.data(data_read_to_avalon),
	.wrfull(rd_fifo_full), // ne ispolzuetsia
	
	.rdclk(clk_120MHz),
	.rdreq(rd_fifo_rdreq),
	.q(data_read_from_spi),
	.rdempty(rd_fifo_empty)
	);



endmodule