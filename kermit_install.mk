install : $(PROGS)
	cp $(PROGS) /var/tftp
	sed -e "s/PROGRAMS/$(PROGS)/g" $(BASE)/install.kermit | kermit -q -y $(BASE)/kermrc -c
