OBJS = ../vhdl/common_decs.o ../vhdl/pwm_mod.o pwm_mod_tb.o #../vhdl/intercon_decs.o wb_fifo.o irq_mngr.o wishbone_wrapper.o intercon.o top_mod.o
SIMS = pwm_mod_tb.vcd
C_VHDL=../../c_vhdl/c-obj/
FLIGHT_VHDL=../vhdl/
UNISIM_VHDL=../../unisim/
WORKNAME=test
UNISIM=$(UNISIM_VHDL)/unisim-obj93.cf
VHDL_FLAGS=--ieee=synopsys -fexplicit --work=$(WORKNAME) -P$(C_VHDL) -P$(FLIGHT_VHDL) -P$(UNISIM_VHDL)
COMP=ghdl
VHDL_C=$(COMP) -i $(VHDL_FLAGS)
VHDL_E=$(COMP) -m -g $(VHDL_FLAGS)
VHDL_R=$(COMP) -r $(VHDL_FLAGS) 
RM=rm -f
RMDIR=rm -rf

all: $(OBJS) $(PROGS) $(SIMS)

$(C_VHDL) :
	$(MAKE) -C $(shell dirname $(C_VHDL)) all

$(UNISIM) :
	$(MAKE) -C $(UNISIM_VHDL) all

../vhdl/%.o : ../vhdl/%.vhdl $(UNISIM)
	$(MAKE) -C $(FLIGHT_VHDL) $(shell basename $@)

%.o : %.vhdl $(UNISIM)
	$(VHDL_C) $< 

%_tb : %_tb.vhdl
	$(VHDL_C) $<
	$(VHDL_E) $@

%_tb.vcd : %_tb
	$(VHDL_R) $< --assert-level=failure --vcd=$@

clean :
	# Clean GHDL products
	$(RM) *.o *.cf *.log *_tb $(SIMS)
	$(RM) *~
