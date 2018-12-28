                                            
// Verilog Test Bench template for design : top_spi_avalon
// 
// Simulation tool : ModelSim-Altera (Verilog)
// 

`timescale 1 ps/ 1 ps
module tb_top;
// constants                                           
// general purpose registers
//reg eachvec;
// test vector input registers
reg av_chip_select;
reg av_read_n;
reg av_write_n;
reg [7:0]	av_address;
//reg clk_50MHz;
reg clk_120MHz;
reg miso;
reg reset_n;
reg [31:0]  av_write_data;
// wires                                               
wire [31:0]  av_read_data;
wire av_wait_request;
wire mosi;
wire sclk_25MHz;
wire ss_n;
wire clk_120MHz_shift;
wire clk_50MHz;
wire clk_50MHz_shift;
wire irq;

//wire test_clk_120MHz_shift;
//wire test_clk_50MHz;
//wire test_clk_50MHz_shift;
//wire test_clk_120MHz;
//wire test_clk_120MHz_shift;

//localparam half_clk = 415;
//parameter half_clk = 415;
//
// assign statements (if any)                          
top_spi_avalon i1 (
// port map - connection between master ports and signals/registers   
	.av_chip_select(av_chip_select),
	.av_read_data(av_read_data),
	.av_read_n(av_read_n),
	.av_wait_request(av_wait_request),
	.av_write_data(av_write_data),
	.av_write_n(av_write_n),
	.av_address(av_address),
//	.clk_50MHz(clk_50MHz),
	.clk_120MHz(clk_120MHz),
	.miso(miso),
	.mosi(mosi),
	.reset_n(reset_n),
	.sclk_25MHz(sclk_25MHz),
	.ss_n(ss_n),
	.clk_120MHz_shift(clk_120MHz_shift),
	.clk_50MHz(clk_50MHz),
	.clk_50MHz_shift(clk_50MHz_shift),
	.irq(irq)
//	.test_clk_50MHz(test_clk_50MHz),
//	.test_clk_50MHz_shift(test_clk_50MHz_shift),
//	.test_clk_120MHz(test_clk_120MHz),
//	.test_clk_120MHz_shift(test_clk_120MHz_shift)
	);



//	initial //clock generator
//		begin
//			clk = 0;
//			forever # 5000 clk = ~clk;
//		end
		
initial
	begin
		clk_120MHz <= 1'b0;
		forever #4150
			clk_120MHz <= ~clk_120MHz;
	end   

//initial                                                
//	begin                                                  
//		$display("Running testbench");
//			clk_120MHz <= 1'b0;
////			clk_50MHz <= 1'b0;
//			av_chip_select <= 1'b0;
//			av_write_n <= 1'b1;
//			av_read_n <= 1'b1;
////			mosi <= 1'b0;
//			reset_n <= 1'b1;
//		$display("Initial complete");                                         
//	end                                                    

//always                                                 
//// optional sensitivity list                           
//// @(event1 or event2 or .... eventn)                  
//begin                                                  
//// code executes for every event on sensitivity list   
//// insert code here --> begin                          
//                                                       
//@eachvec;                                              
//// --> end                                             
//end    
                                                
//always	#415                                                 
//	begin
//		clk_120MHz <= ~clk_120MHz;
//	end 
	
	initial //clock generator
		begin
			reset_n = 1;
			 # 5000 reset_n = 0;
			 # 50000 reset_n = 1;
		end	

//	initial //clock generator
//		begin
//			# 550000 $stop;
//		end
//
	                                                 
//always	#24                                                 
//	begin
//		clk_50MHz <= ~clk_50MHz;
//	end   
	                                                 
initial
  begin
    av_chip_select <= 1'b1;
	 av_read_n <= 1'b1;
	 av_write_n <= 1'b1;
	 av_address <= 8'h0;
//    @(posedge clk_120MHz)
//      reset_n <= 1'b0;
//    @(posedge clk_120MHz)
//      reset_n <= 1'b1;
   @(posedge reset_n) 
		begin
			av_chip_select <= 1'b1;
			av_write_data <= $random;
		end
    @(posedge clk_120MHz)
      av_write_n <= 1'b0;
    @(negedge av_wait_request)
      begin
			@(posedge clk_120MHz)
				begin
					av_write_n <= 1'b1;
				end
		end

	repeat(4000)
      @(negedge clk_120MHz);
	
	av_address <= 8'hff;	
	av_read_n <= 1'b0;
	
    @(negedge av_wait_request)
      begin
			@(posedge clk_120MHz)
				begin
					av_read_n <= 1'b1;
				end
		end
				
		
	repeat(4000)
      @(negedge clk_120MHz);
		
	av_address <= 8'hff;	
	
	@(posedge clk_120MHz)
      av_write_n <= 1'b0;
    @(negedge av_wait_request)
      begin
			@(posedge clk_120MHz)
				begin
					av_write_n <= 1'b1;
				end
		end
	
		
	repeat(130)
      @(negedge clk_120MHz);
	$stop;


  end
  
	always @(negedge sclk_25MHz)
		begin
			miso <= $random;
		end	

		
endmodule
