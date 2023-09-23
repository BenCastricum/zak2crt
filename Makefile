
.DEFAULT_GOAL := all

all: cart.crt

%.prg : %.asm
	./tools/tmpx -i $< -o $@

aa.prg:
	./extract_interpreter.py

cart.crt : loader.prg disk.prg aa.prg build_crt.py
	./build_crt.py -o $@ aa.prg

clean:
	rm aa-ex.prg aa.prg loader.prg cart.crt
