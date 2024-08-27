all:
	iverilog gpu.v gpu_test.v -D ALL
	vvp a.out
	gtkwave dump.vcd

compile:
	iverilog gpu.v gpu_test.v -D ALL
wave:
	gtkwave dump.vcd
