IVERILOG ?= iverilog
VVP ?= vvp
.PHONY: test wave clean

test:
	@mkdir -p build
	@set -e; for ticks in 2 3 10 16; do \
	  $(IVERILOG) -g2012 -Wall -s uart_tx_tb -Puart_tx_tb.TICKS=$$ticks -o build/uart_$$ticks rtl/uart_tx.v tb/uart_tx_tb.sv; \
	  $(VVP) build/uart_$$ticks; \
	done

wave: test
	$(VVP) build/uart_10 +vcd

clean:
	rm -rf build
