onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_spi_avalon_vlg_tst/clk_120MHz
add wave -noupdate /top_spi_avalon_vlg_tst/i1/clk_120MHz_shift
add wave -noupdate /top_spi_avalon_vlg_tst/i1/clk_50MHz
add wave -noupdate /top_spi_avalon_vlg_tst/i1/clk_50MHz_shift
add wave -noupdate /top_spi_avalon_vlg_tst/reset_n
add wave -noupdate /top_spi_avalon_vlg_tst/av_chip_select
add wave -noupdate -divider {New Divider}
add wave -noupdate -color Salmon /top_spi_avalon_vlg_tst/av_write_n
add wave -noupdate -radix binary /top_spi_avalon_vlg_tst/av_wait_request
add wave -noupdate /top_spi_avalon_vlg_tst/av_write_data
add wave -noupdate /top_spi_avalon_vlg_tst/i1/avalon_slave_inst/data_write_to_spi
add wave -noupdate /top_spi_avalon_vlg_tst/i1/spi_core_inst/data_spi_write
add wave -noupdate /top_spi_avalon_vlg_tst/i1/spi_core_inst/data_pack_ready
add wave -noupdate -color {Cornflower Blue} /top_spi_avalon_vlg_tst/i1/spi_core_inst/transfer_complete
add wave -noupdate -divider {New Divider}
add wave -noupdate -color Cyan /top_spi_avalon_vlg_tst/av_read_n
add wave -noupdate -radix binary /top_spi_avalon_vlg_tst/av_wait_request
add wave -noupdate /top_spi_avalon_vlg_tst/i1/spi_core_inst/data_spi_read
add wave -noupdate /top_spi_avalon_vlg_tst/i1/spi_core_inst/data_pack_ready
add wave -noupdate -color {Cornflower Blue} /top_spi_avalon_vlg_tst/i1/spi_core_inst/transfer_complete
add wave -noupdate /top_spi_avalon_vlg_tst/av_read_data
add wave -noupdate -divider {New Divider}
add wave -noupdate /top_spi_avalon_vlg_tst/i1/clk_50MHz
add wave -noupdate /top_spi_avalon_vlg_tst/i1/clk_50MHz_shift
add wave -noupdate -color Red -radix binary /top_spi_avalon_vlg_tst/sclk_25MHz
add wave -noupdate -color Gold /top_spi_avalon_vlg_tst/miso
add wave -noupdate -color Violet -radix binary /top_spi_avalon_vlg_tst/mosi
add wave -noupdate -color Magenta -radix binary /top_spi_avalon_vlg_tst/ss_n
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -radix binary /top_spi_avalon_vlg_tst/i1/avalon_slave_inst/cmd_state
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {771900 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 418
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {2170368 ps}
