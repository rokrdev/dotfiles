bin/gpu_load: gpu_load.c gpu.h ../sketchybar.h | bin
	clang -std=c99 -O3 -framework IOKit -framework CoreFoundation $< -o $@

bin:
	mkdir bin
