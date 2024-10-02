all:
	iverilog ../testbench.v ../scheduler.v  -o ex.out
	vvp ex.out
	gtkwave dump.vcd
git:
	eval "$$(ssh-agent -s)"
	ssh-add ../.ssh/ph_key
2:
	iverilog ../testbench.v ../new_sched.v  -o ex.out
	vvp ex.out
	gtkwave dump.vcd


compile:
	iverilog ../testbench.v ../scheduler.v  -o ex.out

compile2:
	iverilog ../testbench.v ../new_sched.v  -o ex.out

old:
	iverilog ../test_old.v ../scheduler.v  -o old_ex.out
	vvp old_ex.out
	gtkwave old_dump.vcd
