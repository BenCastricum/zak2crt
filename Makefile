
.DEFAULT_GOAL := all

all: cart.crt cart-ex.crt

%.prg : %.asm
	./tools/tmpx -i $< -o $@

aa.prg:
	./extract_interpreter.py

aa-ex.prg : aa.prg
	./tools/exomizer sfx 0x0400 -n -Di_load_addr=0x0400 -o $@ $<

cart.crt : loader.prg aa.prg build_crt.py
	./build_crt.py -o $@ aa.prg

cart-ex.crt : loader.prg aa-ex.prg
	./build_crt.py -o $@ aa-ex.prg

clean:
	rm aa-ex.prg aa.prg loader.prg cart.crt
