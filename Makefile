
# Modified NetCMS Makefile

# Non standard SUFFIXES make needs to recognize

.SUFFIXES: .cmd .log .cat

# cmd paths
cat = /bin/cat
clogin = /home/plato/Git/pirat/clogin2 -f ~plato/.cloginrc
ls = /bin/ls
sed = /bin/sed

# SHELL = RCSINIT=-zlt /bin/ksh
SHELL = /bin/bash

# use clogin's builtin default (45 seconds?) if unset:
clogin_timeout = 120

.cmd.log:
	@echo BEGIN .cmd.log $@
	base='$*'; \
	$(clogin) $${clogin_timeout:+-t$${clogin_timeout}} -x $< $${base%%_*} > $@ || (rm -f $@; exit 1)
	@echo END .cmd.log $@

push.make:
	@echo BEGIN $@
	@echo -e "push: " $$($(ls) *.cmd | sed -e 's/\.cmd$$/.log/')" \
	\n\ninclude ~plato/Git/pirat/Makefile" > $@

# End
