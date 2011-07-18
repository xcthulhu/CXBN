WORK = work
GENVHDL = br8gen.vhdl br8gen_arc.vhdl \
          pwmc.vhdl pwmc_arc.vhdl \
          pwm_mod.vhdl pwm_mod_arc.vhdl \
          cfifoc.vhdl cfifoc_arc.vhdl \
          uart_rx_mod.vhdl uart_rx_mod_arc.vhdl \
          uart_transceiver_mod.vhdl uart_transceiver_mod_arc.vhdl
PDFS = uart_rx_mod.pdf cfifoc.pdf uart_transceiver_mod.pdf br8gen.pdf pwmc.pdf pwm_mod.pdf\
       pwm_mod_arc_symbol.pdf uart_transceiver_mod_arc_symbol.pdf 
PNGS = uart_transceiver_mod.png pwm_mod.png pwm_mod_arc_symbol.png \
       uart_transceiver_mod_arc_symbol.png 
OBJS = common_decs.o intercon_decs.o charc_decs.o write_chanc_decs.o \
       charco.o charci.o write_chano.o write_chani.o uart_rx.o uart_tx.o \
       flag.o fifo.o cfifo.o br8gen_prim.o pwm.o \
       wb_uart_transceiver.o wb_uart_rx.o wb_pwm.o \
       cfifoc.o cfifoc_arc.o \
       pwmc.o pwmc_arc.o \
       pwm_mod.o pwm_mod_arc.o \
       br8gen.o br8gen_arc.o \
       uart_rx_mod.o uart_rx_mod_arc.o \
       uart_transceiver_mod.o uart_transceiver_mod_arc.o
SYMBOLS = ./Symbols
#BITMAP = cxbn.bit
DEVEL_BASE=../..

ARCHITECTURE_SCM_BOILERPLATE=\
"(define generate-mode '1)"

ENTITY_SCM_BOILERPLATE=\
"(define generate-mode '2)"

S2PS=gschem -p -o $@ -s print.scm $<
S2PS_SYMBOL=gschem -p -o ../$@ -s ../print.scm $<
PS2PDF=ps2pdf $< $@
PDFCROP=pdfcrop $< $@
PDF2PNG=convert $< $@

# Read the following document for details about using the Xilinx unisim library and ghdl
# http://www.dossmatik.de/ghdl/ghdl_unisim_eng.pdf
UNISIM_VHDL=$(DEVEL_BASE)/unisim
UNISIM=$(UNISIM_VHDL)/unisim-obj93.cf

COMP=ghdl
VHDL_C=$(COMP) -a -g --work=$(WORK) -P$(UNISIM_VHDL) --ieee=synopsys -fexplicit --warn-reserved --warn-default-binding --warn-binding --warn-library --warn-vital-generic --warn-delayed-checks --warn-body --warn-specs --warn-unused
RM=rm -f
VHDL_TO_SYM=$(DEVEL_BASE)/lambda-geda/vhdl-to-sym

all: $(OBJS) $(BITMAP) $(SYMBOLS) $(GENVHDL) $(PDFS) $(PNGS)

%_arc.vhdl : %.sch $(SYMBOLS)
	gnetlist -c $(ARCHITECTURE_SCM_BOILERPLATE) -o $@ -g vams $<

%.vhdl : %.sch %_arc.vhdl $(SYMBOLS)
	gnetlist -c $(ENTITY_SCM_BOILERPLATE) -o $@ -g vams $<
	$(VHDL_TO_SYM) Symbols $@ $(shell echo $@ | sed 's/.vhdl/_arc.vhdl/')

%_symbol.ps : $(SYMBOLS)/%.sym $(SYMBOLS)
	$(S2PS_SYMBOL)

%.ps : %.sch $(SYMBOLS)
	$(S2PS)

%-UNCROPPED.pdf : %.ps
	$(PS2PDF)
	
%.pdf : %-UNCROPPED.pdf
	$(PDFCROP)

%.png : %.pdf
	$(PDF2PNG)

$(UNISIM) : 
	$(MAKE) -C $(DEVEL_BASE) unisim

$(SYMBOLS) :
	mkdir $@ 
	$(VHDL_TO_SYM) $@ *.vhdl 

%_arc.o: %.o

%.o : %.vhdl $(UNISIM)
	$(VHDL_C) $< 

# Make instructions creating a bitmap from xilinx synthesis tools
# adapted from http://www.excamera.com/sphinx/fpga-makefile.html
project=cxbn
top_module=top_mod
vendor=xilinx
family=spartan3s
part=xc3s200a-4ft256
files=common_decs.vhdl intercon_decs.vhdl canopus.vhdl
include $(DEVEL_BASE)/xilinx.mk

# Install the bitmap on the armadeus, by loading into the FPGA
include $(DEVEL_BASE)/install.mk
install : install_bitmap

clean :
	# Clean GHDL products
	$(RM) $(OBJS) *.cf
	# Clean backups
	$(RM) *~
	# Clean Symbols
	rm -rf Symbols
	# Clean gnetlist products
	$(RM) $(GENVHDL)
	# Clean documentation products
	$(RM) *.pdf *.ps *.png
