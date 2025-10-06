onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /regstim/clk
add wave -noupdate /regstim/RegWrite
add wave -noupdate -radix unsigned /regstim/WriteRegister
add wave -noupdate -radix decimal /regstim/WriteData
add wave -noupdate -radix unsigned /regstim/ReadRegister1
add wave -noupdate -radix decimal /regstim/ReadData1
add wave -noupdate -radix unsigned /regstim/ReadRegister2
add wave -noupdate -radix decimal /regstim/ReadData2
add wave -noupdate {/regstim/dut/registers[31]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {472500000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 178
configure wave -valuecolwidth 206
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
configure wave -timelineunits ps
update
WaveRestoreZoom {420604390 ps} {484395620 ps}
