OBJS = blink.o mask.o
PACKAGES = common_decs.o rom.o
C_LIBRARY = ./c_vhdl/c-obj
UNISIM = unisim/unisim-obj93.cf
PROGS = blink_tb mask_tb
SIMS = blink_tb.vcd mask_tb.vcd
GHDL = ghdl

all: $(UNISIM) $(C_LIBRARY)

unisim: $(UNISIM)

c_vhdl: $(C_LIBRARY)

$(UNISIM):
	$(MAKE) -C unisim all

$(C_LIBRARY):
	$(MAKE) -C c_vhdl all

armadeus:
	git submodule init
	git submodule update
	$(MAKE) -C armadeus

clean:
	$(MAKE) -C unisim clean
	$(MAKE) -C c_vhdl clean
