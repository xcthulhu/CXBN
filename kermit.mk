TFTPDIR=/var/tftp

install : $(PROGS)
	cp $(PROGS) $(TFTPDIR)
	for i in "$(PROGS)" ; do chmod 777 $(TFTPDIR)/$$i ; done
	sed -e "s/PROGRAMS/$(PROGS)/g" $(BASE)/install.kermit | kermit -q -y $(BASE)/kermrc -c

uninstall : 
	for i in "$(PROGS)" ; do rm -f $(TFTPDIR)/$$i ; done
	sed -e "s/PROGRAMS/$(PROGS)/g" $(BASE)/uninstall.kermit | kermit -q -y $(BASE)/kermrc -c
