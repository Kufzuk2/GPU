all: 
	iverilog gpu.v vga.v freq_div2.v rgb_gen.v bank.v bank_arbiter.v pseudo_asm.v button.v gpu_core_1.v round_robin.v sched_def.v scheduler.v new_test.v
	vvp a.out
	gtkwave dump.vcd

pic:
	iverilog gpu.v vga.v  freq_div2.v rgb_gen.v bank.v bank_arbiter.v pseudo_asm.v button.v gpu_core_1.v round_robin.v sched_def.v scheduler.v new_test.v
	vvp a.out
	python3 result/make_pic.py
	gthumb result/output.png
picr:
	python3 result/make_pic.py
	gthumb result/output.png
compile: 
	iverilog gpu.v vga.v freq_div2.v rgb_gen.v bank.v bank_arbiter.v pseudo_asm.v button.v gpu_core_1.v round_robin.v sched_def.v new_ts.v new_test.v
clean_res:
	rm result/bank_*
