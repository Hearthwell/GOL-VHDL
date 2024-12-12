SRC_FILES := src/uart.vhd src/timer.vhd src/GOLCore.vhd src/GOLProcessor.vhd

processor_sim: $(SRC_FILES)
	ghdl -a $(SRC_FILES)
	ghdl -a test/processor_t.vhd
	ghdl -r Processor_t --wave=out/output.ghw

clean:
	rm -rf out/*
	rm -f *.cf