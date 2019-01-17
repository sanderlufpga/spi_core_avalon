
derive_clock_uncertainty
create_clock -period 120MHz -name {clk_120MHz} [get_ports {clk_120MHz}]
derive_pll_clocks
set_clock_groups -exclusive -group {clk_120MHz pll_inst|altpll_component|auto_generated|pll1|clk[0]}
#set_input_delay 

set_multicycle_path -from [get_registers {avalon_slave:avalon_slave_inst|data_write_to_spi[*]}] -to [get_registers {spi_core:spi_core_inst|data_write[*]}] -setup -start 3
set_multicycle_path -from [get_registers {avalon_slave:avalon_slave_inst|data_write_to_spi[*]}] -to [get_registers {spi_core:spi_core_inst|data_write[*]}] -hold -start 2

set_multicycle_path -from [get_registers {spi_core:spi_core_inst|data_read_to_avalon[*]}] -to [get_registers {avalon_slave:avalon_slave_inst|read_data[*]}] -setup -end 2
set_multicycle_path -from [get_registers {spi_core:spi_core_inst|data_read_to_avalon[*]}] -to [get_registers {avalon_slave:avalon_slave_inst|read_data[*]}] -hold -end 1


set_multicycle_path -from [get_registers {avalon_slave:avalon_slave_inst|go_transfer}] -to [get_registers {spi_core:spi_core_inst|set_up_transfer~0}] -setup -start 2
set_multicycle_path -from [get_registers {avalon_slave:avalon_slave_inst|go_transfer}] -to [get_registers {spi_core:spi_core_inst|set_up_transfer~0}] -hold -start 1


#set_false_path -from [get_registers {avalon_slave:avalon_slave_inst|go_transfer}] -to [get_registers {spi_core:spi_core_inst|data_write[1]}]




#set_multicycle_path -from [get_registers {spi_core:spi_core_inst|data_pack_ready}] -to [get_registers {avalon_slave:avalon_slave_inst|read_data[*]}] -setup -end 2
#set_multicycle_path -from [get_registers {spi_core:spi_core_inst|data_pack_ready}] -to [get_registers {avalon_slave:avalon_slave_inst|read_data[*]}] -hold -end 1

#set_multicycle_path -from [get_registers {spi_core:spi_core_inst|data_pack_ready}] -to [get_registers {avalon_slave:avalon_slave_inst|transfer_complete}] -setup -end 2
#set_multicycle_path -from [get_registers {spi_core:spi_core_inst|data_pack_ready}] -to [get_registers {avalon_slave:avalon_slave_inst|transfer_complete}] -hold -end 1


#set_multicycle_path -from [get_registers {spi_core:spi_core_inst|data_read_to_avalon[*]}] -to [get_registers {avalon_slave:avalon_slave_inst|read_data[*]}] -setup -end 2
#set_multicycle_path -from [get_registers {spi_core:spi_core_inst|data_read_to_avalon[*]}] -to [get_registers {avalon_slave:avalon_slave_inst|read_data[*]}] -hold -end 1
#
#set_multicycle_path -from [get_registers {spi_core:spi_core_inst|data_pack_ready}] -to [get_registers {avalon_slave:avalon_slave_inst|transfer_complete}] -setup -end 2
#set_multicycle_path -from [get_registers {spi_core:spi_core_inst|data_pack_ready}] -to [get_registers {avalon_slave:avalon_slave_inst|transfer_complete}] -hold -end 1



