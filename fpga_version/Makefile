all: 
	iverilog gpu.v vga.v vga_sync.v gen_addr.v bank.v bank_arbiter.v pseudo_asm.v button.v gpu_core_1.v round_robin.v sched_def.v load_asm.v scheduler.v new_test.v -D SIMUL_MODE
	vvp a.out
	gtkwave dump.vcd &

pic:
	iverilog gpu.v vga.v  vga_sync.v gen_addr.v bank.v bank_arbiter.v pseudo_asm.v button.v gpu_core_1.v round_robin.v sched_def.v load_asm.v scheduler.v new_test.v -D SIMUL_MODE
	vvp a.out
	python3 result/make_pic.py
	gthumb result/output.png
picr:
	python3 result/make_pic.py
	gthumb result/output.png
compile: 
	iverilog gpu.v vga.v vga_sync.v gen_addr.v bank.v bank_arbiter.v pseudo_asm.v button.v gpu_core_1.v round_robin.v sched_def.v load_asm.v scheduler.v new_test.v -D SIMUL_MODE
clean_res:
	rm result/bank_*
