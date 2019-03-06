
derive_clock_uncertainty
create_clock -period 120MHz -name {clk_120MHz} [get_ports {clk_120MHz}]
derive_pll_clocks
set_clock_groups -exclusive -group {clk_120MHz pll_inst|altpll_component|auto_generated|pll1|clk[0]}
#set_false_path -from {avalon_slave:avalon_slave_inst|cmd_RESET}


set_multicycle_path -from {avalon_slave:avalon_slave_inst|cmd_RESET} -setup -end 2
set_multicycle_path -from {avalon_slave:avalon_slave_inst|cmd_RESET} -hold -end 1