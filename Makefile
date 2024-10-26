all:
	python3 src_data/trans_bin.py
	iverilog gpu.v gpu_test.v -D ALL
	python3 result/make_pic.py
	gthumb result/output.png

compile:
	iverilog gpu.v gpu_test.v -D ALL
wave:
	python3 src_data/trans_bin.py
	iverilog gpu.v gpu_test.v -D ALL
	python3 result/make_pic.py
	vvp a.out
	gtkwave dump.vcd
	
reg_data:
	iverilog gpu.v gpu_test.v -D ALL -D REG_D
	vvp a.out
	gtkwave dump.vcd

cur_fr:
	iverilog gpu.v gpu_test.v -D ALL -D CUR_FR_D
	vvp a.out
	gtkwave dump.vcd

data_in:
	iverilog gpu.v gpu_test.v -D ALL -D DATA_IN
	vvp a.out
	gtkwave dump.vcd

exec:
	iverilog gpu.v gpu_test.v -D ALL
	./a.out

trace:
	iverilog gpu.v gpu_test.v -D ALL -D CUR_FR_D -D REG_D -D DATA_IN
	vvp a.out
	gtkwave dump.vcd
