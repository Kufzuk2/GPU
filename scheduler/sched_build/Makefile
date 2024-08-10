all:
	iverilog ../testbench.v ../new_sched.v ../gpu_def.v ../sched_func.v -o ex.out
	vvp ex.out
	gtkwave dump.vcd
git:
	eval "$$(ssh-agent -s)"
	ssh-add ../.ssh/ph_key


