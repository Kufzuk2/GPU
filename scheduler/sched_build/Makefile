all:
	iverilog ../testbench.v ../scheduler.v  -o ex.out
	vvp ex.out
	gtkwave dump.vcd
git:
	eval "$$(ssh-agent -s)"
	ssh-add ../.ssh/ph_key


