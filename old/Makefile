
#   NetCMS (Network Configuration Management System) Makefile.
#   Copyright (C) 1997-2008  Dave Plonka
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 
# $Id: Makefile,v 1.1 2011/01/26 21:19:52 root Exp $
# Dave Plonka <plonka@doit.wisc.edu>

# Some comments about this Makefile:
#
# - It's unusual because lots of the commands in the rules are interactive.
#   This actually is quite useful.  For instance if you make "mailout" and
#   stdin is not a tty it'll just do it's thing.  If stdin *is* a tty, it
#   will allow you to edit the e-mail message before sending it out.
#   As a safety net, those rules that must interact with the user should
#   test if stdin is a tty and error out if not.
#
# - Targets beginning with "..." are temporary and are deleted by "make clean".
#
# - Targets with "mailout" in the name generate or mail output to $(mailto).
#
# - As for cron, the idea is to do use a crontab crontab entry something like
#   this:
#          0 3 * * *	cd /opt/net/cms && make clean mailout

.SUFFIXES: .conf,v .conf .update .check .postupdate .cisconf-a .cisconf-d .hosts .available .copy .parcopy .write .parwrite .parwritelog .getcnf .runflashgetcnf .pargetcnf .clogin .lock .forcelock .pushacl .parpushacl .pushbanner .rcsdiff .checkin .unlock .forceunlock _write.log .cmd .log _showstp$(vlan).cmd _showboot.cmd _showboot.log .bootfile .bridgeaddress _stp$(vlan).log .fig .pdf _showmac.cmd _showproccpu.cmd .forcecheckinlock .logmsgcheckinlock _showiproute.cmd

.PHONY: quit update new mailout show rlog pushacl100 showstp$(vlan) snapshotstp summary audit

# Some of the ksh syntax here will not fly with bash or possibly not even pdksh.
# eg. arithmetic evaluation within "(( ))"
#SHELL = RCSINIT=-zlt /bin/bash
SHELL = RCSINIT=-zlt /bin/ksh
#SHELL = RCSINIT=-zlt /usr/local/pdksh/bin/ksh

# Working directory for this project
DIR = /home/net/cms

# other external commands used by rules
awk = /bin/awk
cp = /bin/cp
cat = /bin/cat
cut = /bin/cut
# diff must handle diff of directories (such as AIX diff(1))
diff = /usr/bin/diff
diff3 = /usr/bin/diff3
egrep = /bin/egrep
find = /usr/bin/find
fping = /usr/local/bin/fping
# grep must have "-c" option
grep = /bin/grep
#ksh = /usr/local/pdksh/bin/ksh
ksh = /usr/bin/ksh
less = /usr/bin/less
ls = /bin/ls
# ln must have "-f" and "-s" options
ln = /bin/ln
locker = /usr/local/ns/bin/locker
# mkdir must have "-p" option
mkdir = /bin/mkdir
mv = /bin/mv
nc = /usr/bin/nc
rm = /bin/rm
sed = /bin/sed
tail = /usr/bin/tail
# Should we use the test external?  I've observed that some make(1)s, as an
# optimization, sometimes decide to exec(2) a simple command without using
# SHELL.  So, some test invocations will get the external and others the
# SHELL built-in.  For now we won't force the external.
# test =
touch = /bin/touch
uniq = /usr/bin/uniq
xargs = /usr/bin/xargs
sort = /bin/sort
join = /usr/bin/join
vi = /bin/vi
wc = /usr/bin/wc
perl = /usr/bin/perl
co = /usr/bin/co
ci = /usr/bin/ci
rcsclean = /usr/bin/rcsclean
rlog = /usr/bin/rlog
rcsdiff = /usr/bin/rcsdiff
mutt = /usr/bin/mutt
getcnf = /home/net/cms/bin/getcnf_frontend
# retry the getcnf this many times before failure:
getcnf_retries = 5
# use these rather than snmpwalk and snmpget whose output varies:
altwalk = /usr/local/bin/altwalk
altget = /usr/local/bin/altget

cop = /home/net/cms/bin/co-p
locks = /usr/local/ns/bin/locks

# a utility to create models.txt quickly (using non-blocking SNMP gets):
nb_cms_snmp = /home/net/cms/bin/nb_cms_snmp.pl

# a utility to create bootfile.txt quickly (using non-blocking SNMP gets):
nb_bootfile_snmp = /home/net/cms/bin/nb_bootfile_snmp.pl

# A utility to get versions from the database instead of via SNMP
get_versions = /home/net/cms/bin/get_versions.pl

# "modtime" just prints the 1st argument's modification time in 
# a format that the RCS rlog(1) likes with "-d".
modtime = /home/net/cms/bin/modtime.pl

# "sortbyip" is a perl invocation that sorts based on the 1st IP address in
# a line.  It can, for instance, be used to sort a hosts file by IP address.
sortbyip = /home/net/cms/bin/sortbyip

# A perl script that returns a hostname given an IP or an IP given a hostname
hostoraddr = /home/net/cms/bin/hostoraddr

# arguments for the getcnf utility
hosts_file = /dev/null

# file from which the modification time is gotten for use with "rlog -d>date"
epoch_file = $(DIR)/.rlog.touch

# FIXME - summarize can take forever if there are a lot of devices only in RCS
#         (or that have diffs).  This is because it looks through all the logs
#         to find who logged in last.
summarize = /home/net/cms/bin/summarize

# mutt arguments for the mailout target
muttrc = $(DIR)/.muttrc
mailto = lan@lists.wisc.edu
summary_mailto = net-cms-summary

find_revisions = /usr/local/ns/bin/find_revisions

# SNMP community
community = itsnotpublic
fwsm_community = iamnotapix

menu:	$(epoch_file)
	@test -t 0 || exit 1
	@case "$$(id -gn)" in \
	net|noc|netters) ;; \
	*) $(perl) -e 'print "*"x80, "\n\n   You naughty creature!  *Please* \"newgrp - netters\" group so that new files that\n", "   you create may be modified by others in your group.\n   See \"http://net.doit.wisc.edu/~plonka/NetCMS/NetCMS.html\" for details.\n\n", "*"x80, "\n"; exit 1' ;; \
	esac
	@case "$$(umask)" in \
	02|002|0002) ;; \
	*) $(perl) -e 'print "*"x80, "\n\n   You naughty creature!  *Please* set your umask to 02 so that new files that\n", "   you create may be modified by others in your group.\n   See \"http://net.doit.wisc.edu/~plonka/NetCMS/NetCMS.html\" for details.\n\n", "*"x80, "\n"; exit 1' ;; \
	esac
	@modtime="$$($(modtime) $(epoch_file))"; \
	select choice in quit 'update an existing device' 'new device' mailout "show changes since last e-mail report ($${modtime?})"; \
	do \
	   test quit = "$${choice?}" && exit ; \
	   $(MAKE) $${choice%% *} ; \
	done

update.make:
	@print "update: " $$($(ls) *.log | sed -e 's/\.log$$/.update/')" \
	\n\ninclude ~net/cms/Makefile" > $@

upgrade.make:
	@print "TMPupgrade: " $$($(ls) *.cmd | sed -e 's/\.cmd$$/.log/')" \
        \n\nupgrade: " $$($(ls) *.cmd | sed -e 's/\.cmd$$/.log/')" \
	\n\ninclude ~net/cms/Makefile" > $@

new:	$(hosts_file)
	@test -t 0 || exit 1
	@while (( 1 )) ; \
	do \
	   read device?'Enter resolvable device sysName: ' ; \
	   device="$$($(hostoraddr) $$($(hostoraddr) $${device?}))"; \
	   device="$${device%%.*}"; \
	   test "$$device" && break ; \
	   print -u2 "DNS problem or forward/reverse mismatch? " ; \
	done && \
	if $(rlog) -h $${device?}.conf >/dev/null 2>&1; \
	then \
		:; \
	else \
		$(getcnf) -o%s%s.conf $${device?} || exit 1 ; \
		for file in $$($(ls) $${device?}.conf $${device?}_*.conf 2>/dev/null) ; \
		do \
	   		if test -d ...configurations/flash && \
	      			test -d ...configurations/running ; \
	   		then \
	      			$(cp) $${file?} ...configurations/flash/$${file?} && \
	      			$(rm) -f ...configurations/running/$${file?} && \
	      			$(ln) -fs $(DIR)/...$${file%.conf?}.running-conf \
	                				...configurations/running/$${file?} || exit 1 ; \
	   		fi; \
	 		$(ci) -u $${file?} || exit 1 ; \
	  		test -d ...configurations/RCS && \
	  		$(rm) -f ...configurations/RCS/$${file?} && \
	  		$(cop) $${file?} ...configurations/RCS/$${file?} ; \
		done; \
	fi; \
	$(MAKE) -s -i $${device?}.cisconf-d >/dev/null 2>&1; \
	$(MAKE) -s -i $${device?}.cisconf-a; \
	$(MAKE) -i $${device?}.postupdate
	/usr/bin/perl -MAANTS::EdgeConf -le 'my $$n = AANTS::EdgeConf->new->load_devices; printf("$$n new device%s loaded into device table.\n", 1 == $$n? "" : "s")' || true
	exit 0

locked.getcnf: $(hosts_file)
	set -A devices $$($(egrep) 'strict;$$' /dev/null !(*_*).conf,v | $(grep) -v 'locks;' |grep $${LOGNAME?} |$(cut) -f1 -d: |$(sed) -e 's/\.conf,v$$//') ; \
	for device in "$${devices[@]}" ; \
	do \
	   $(getcnf) -o%s%s.conf $${device?} || exit 1 ; \
	   case $${device?} in \
	   f-*|fx-*) \
		   sleep 5 ;; \
	   esac; \
	done

.conf.getcnf:
	$(getcnf) -o%s%s.conf $*
	case $* in \
	f-*|fx-*) \
	sleep 2 ;; \
	esac

getcnf: 
	set -x ; \
	device="$*"; \
	$(MAKE) $${device?}.update

update:
	@test -t 0 || exit 1
	@while (( 1 )) ; \
	do \
	   read device?'Enter device sysName: ' ; \
	   device="$$($(hostoraddr) $$($(hostoraddr) $${device?}))"; \
	   device="$${device%%.*}"; \
	   test "$$device" && break ; \
	done && \
	$(MAKE) $${device?}.update

.conf.update:
	set -x ; \
	device="$$($(hostoraddr) $$($(hostoraddr) $*))"; \
	device="$${device%%.*}"; \
	device="$${device%_*}"; \
	for file in $$($(ls) $${device?}.conf $${device?}_*.conf 2>/dev/null) ; \
	do \
	$(co) -l $${file?} || exit 1 ; \
	$(rm) -f $${file?} ; \
	done && \
	touch ...$${device?}.update && \
	$(getcnf) $(proxy_option) -r...%s%s.running-conf -o%s%s.conf $${device?} || exit 1 ; \
	for file in $$($(ls) $${device?}.conf $${device?}_*.conf 2>/dev/null) ; \
	do \
	   if test -d ...configurations/flash && \
	      test -d ...configurations/running ; \
	   then \
	      $(cp) $${file?} ...configurations/flash/$${file?} && \
	      $(rm) -f ...configurations/running/$${file?} && \
	      $(ln) -fs $(DIR)/...$${file%.conf}.running-conf \
	                ...configurations/running/$${file?} || exit 1 ; \
	   fi && \
	   $(rcsdiff) -c $${file?} || true ; \
	   $(diff) -c $${file?} ...$${file%.conf}.running-conf || true ; \
	   (test -t 0 && $(ci) -u $${file?}) || $(co) -f -u $${file?} ; \
	   test -d ...configurations/RCS && $(rm) -f ...configurations/RCS/$${file?} && $(cop) $${file?} ...configurations/RCS/$${file?} ; \
	done; \
	$(MAKE) $${device?}.postupdate; \
	exit 0

.conf.check:
	$(MAKE) $*.update </dev/null

.conf,v.conf:
	$(co) $@

$(muttrc): $(muttrc),v
	$(co) .muttrc

inactive.txt:
	$(ls) /home/net/cms/inactive/*,v \
        |$(sed) -e 's/\/home\/net\/cms\/inactive\///;s/\.conf,v//' > $@

...hosts:
	$(ls) *.conf,v |$(sed) -e 's/\.conf,v$$//' |$(perl) -MSocket -lne '$$ip = unpack("N", gethostbyname($$_)); print(inet_ntoa(pack("N", $$ip)), "\t$$_\t $$_") if $$ip' |$(sortbyip) > $@

# this file is used to communicate the names of devices for which we
# failed to get a configuration between rules:
parfailed_file = ...parconfigurations_failed.txt

# number of parallel jobs used by the ...configurations/ rules:
parjobs = 8

# this is a special rule used by ...configurations.touch:
# the sleep 1 is for the benefit of the radius server, which seems to
# get angry when there are two many logins/logouts in parallel
# FIXME - the file should be locked before appending to $(parfailed_file)
.conf.runflashgetcnf:
	case $* in \
	Xw-*) \
	$(locker) -e w-mutex.lock $(ksh) -c "'($(getcnf) -r...configurations/running/%s%s.conf -o...configurations/flash/%s%s.conf $* && sleep 1) || (echo $* >> .$(parfailed_file))'"; \
	;; \
	f-*|fx-*) \
	$(getcnf) -r...configurations/running/%s%s.conf -o...configurations/flash/%s%s.conf $* || (echo $* >> .$(parfailed_file)); \
	sleep 2 ;; \
	*) \
	$(getcnf) -r...configurations/running/%s%s.conf -o...configurations/flash/%s%s.conf $* || (echo $* >> .$(parfailed_file)); \
	esac

...all.txt: ...hosts
	($(awk) '/^[^#]/ {print $$NF}' $(DIR)/...hosts; \
	 $(awk) '/^[^#]/ {print $$NF}' $(hosts_file)) |$(sort) -u -r > $@

...configurations.body: ...all.txt
	typeset todo=$< ; \
	typeset -i n=0; \
	typeset -i parjobs=$(parjobs); \
	while [[ -s $${todo?} ]] && (( n <  $(getcnf_retries) )) ; \
	do \
		n=n+1 ; \
		> .$(parfailed_file) ; \
		$(sed) -e 's/$$/.runflashgetcnf/' $${todo?} | $(xargs) -t --no-run-if-empty $(MAKE) -i -j ${parjobs} ; \
		$(mv) -f .$(parfailed_file) $(parfailed_file); \
		todo=$(parfailed_file) ; \
		parjobs=1 ; \
	done
	$(touch) ...configurations.touch

...configurations.touch: ...all.txt
	$(rm) -rf ...configurations
	$(mkdir) -p ...configurations/running
	$(mkdir) -p ...configurations/flash
	typeset todo=$< ; \
	typeset -i n=0; \
	typeset -i parjobs=$(parjobs); \
	while [[ -s $${todo?} ]] && (( n <  $(getcnf_retries) )) ; \
	do \
		n=n+1 ; \
		> .$(parfailed_file) ; \
		$(sed) -e 's/$$/.runflashgetcnf/' $${todo?} | $(xargs) -t --no-run-if-empty $(MAKE) -i -j ${parjobs} ; \
		$(mv) -f .$(parfailed_file) $(parfailed_file); \
		todo=$(parfailed_file) ; \
		parjobs=1 ; \
	done
	$(touch) ...configurations.touch

...failover-configurations.touch: ...configurations.touch ...hosts
	$(rm) -rf ...configurations/failover
	$(mkdir) -p ...configurations/failover/primary/flash
	$(mkdir) -p ...configurations/failover/primary/running
	$(mkdir) -p ...configurations/failover/secondary/flash
	$(mkdir) -p ...configurations/failover/secondary/running
	cd ...configurations/failover >/dev/null ; \
	($(awk) '/^[^#]/ {print $$NF}' $(DIR)/...hosts |$(grep) '^f-'; \
	 $(awk) '/^[^#]/ {print $$NF}' $(DIR)/...hosts |$(grep) '^f-' |$(grep) -v -- -stby |$(sed) -e 's/$$/-stby/' -e 's/-pri//') \
	|$(sort) -u | \
	while read device ; \
	do \
	   typeset -i n=0; \
	   while (( 1 )) ; \
	   do \
	      n=n+1 ; \
	      case $${device?} in \
	      *-stby) \
		 subdir=secondary \
	         ;; \
	      *) \
		 subdir=primary \
	         ;; \
	      esac ; \
	      if $(getcnf) -r$${subdir?}/running/%s%s.conf \
	                   -o$${subdir?}/flash/%s%s.conf $${device?} ; \
	      then \
		 break ; \
              else \
		 (( n >= $(getcnf_retries) )) && break ; \
	      fi ; \
	   done ; \
	done; \
	$(find) primary -name '*-pri*.conf' -print |while read file ; \
	do \
	   $(mv) $${file?} $$(print $${file?} |$(sed) -e 's/-pri//') ; \
	done; \
	$(find) secondary -name '*-stby*.conf' -print |while read file ; \
	do \
	   $(mv) $${file?} $$(print $${file?} |$(sed) -e 's/-stby//') ; \
	done
	$(touch) ...failover-configurations.touch

$(epoch_file):
	$(touch) $(epoch_file)

rlog:	$(epoch_file)
	$(rlog) -zLT -d">$$($(modtime) $(epoch_file))" *.conf,v |$(perl) -ne 'if ($$log) { push(@_, $$_); if (!($$log = !m/^=+$$/)) { print $$fline, @_; @_=() } } elsif (m/^RCS file:/) { $$fline = $$_ } else { $$log = m/^-+$$/ }'

show:
	@test -t 0 || exit 1
	$(MAKE) -s rlog |$${PAGER:-$(less)}

flash-diff: ...configurations.touch
	@cd ...configurations >/dev/null && \
	$(rm) -rf RCS && \
	$(mkdir) RCS && \
	$(ls) $(DIR) |grep '.conf,v$$' | while read version_file ; \
	do \
	   file=$${version_file%,v} && \
	   file=$${file##*/} && \
	   $(cop) $(DIR)/$${version_file?} RCS/$${file?} 2>/dev/null ; \
	done && \
	$(diff) -wc RCS flash 2>&1 | $(perl) -ne 'if (m/^((Only in|diff).*)$$/) { print "\n$$1 ", "*"x(80-length($$1)-1), "\n" } else { print }'

# ejp - 6/23/2008:  I had to break the diff up into two parts, one
# excludes fa- devices and behaves otherwise normally, and the other
# does all else.  diff --include-only=pattern dir1 dir2 would be nice
# the original command on one line follows:
# $(diff) -wc flash running 2>&1 | $(perl) -ne 'if (m/^(diff.*)$$/)
#       { print "\n$$1 ", "*"x(80-length($$1)-1), "\n" } else { print }'

running-diff: ...configurations.touch
	@cd ...configurations >/dev/null && \
	$(diff) -wc --exclude='fa*conf' flash running 2>&1 | $(perl) -ne 'if (m/^(diff.*)$$/) { print "\n$$1 ", "*"x(80-length($$1)-1), "\n" } else { print }' && \
	$(diff) -wc --exclude="[!f]*conf" --exclude="f[!a]*conf" -I "http .*side" flash running 2>&1 | $(perl) -ne 'if (m/^(diff.*)$$/) { print "\n$$1 ", "*"x(80-length($$1)-1), "\n" } else { print }'

failover-diff: ...failover-configurations.touch ...configurations.touch
	@cd ...configurations >/dev/null && \
	$(diff) -wc failover/primary/flash failover/secondary/flash 2>&1 | $(perl) -ne 'if (m/^(diff.*)$$/) { print "\n$$1 ", "*"x(80-length($$1)-1), "\n" } else { print }'; \
	$(diff) -wc failover/primary/running failover/secondary/running 2>&1 | $(perl) -ne 'if (m/^(diff.*)$$/) { print "\n$$1 ", "*"x(80-length($$1)-1), "\n" } else { print }'

secondary-running-diff: ...failover-configurations.touch ...configurations.touch
	@cd ...configurations >/dev/null && \
	$(diff) -wc failover/secondary/flash failover/secondary/running 2>&1 | $(perl) -ne 'if (m/^(diff.*)$$/) { print "\n$$1 ", "*"x(80-length($$1)-1), "\n" } else { print }'

check-locks:
	$(locks)

...check-locks.mailout:
	$(MAKE) -s check-locks > ...check-locks.mailout

...running-diff.mailout:
	$(MAKE) -s running-diff > ...running-diff.mailout

...flash-diff.mailout:
	$(MAKE) -s flash-diff > ...flash-diff.mailout

failover-diff.txt:
	$(MAKE) -s failover-diff > failover-diff.txt

...rlog.mailout:
	$(touch) $(epoch_file).next
	$(MAKE) -s rlog > ...rlog.mailout || ($(rm) -f $(epoch_file).next && exit 1)
	$(mv) $(epoch_file) $(epoch_file).prev
	$(mv) $(epoch_file).next $(epoch_file)

check-locks.txt:
	$(ln) -s ...check-locks.mailout check-locks.txt

running-diff.txt:
	$(ln) -s ...running-diff.mailout running-diff.txt

flash-diff.txt:
	$(ln) -s ...flash-diff.mailout flash-diff.txt

rlog.txt:
	$(ln) -s ...rlog.mailout rlog.txt

summary: models.txt boot_versions.txt
	(print "\ncount model                 version       sysBootVariable/sysConfigName\n----- --------------------- ------------- --------------------------------------"; $(join) -1 1 -2 1 -o '1.3 2.3 2.4' models.txt boot_versions.txt |$(sort) |$(uniq) -c |$(awk) '{ printf "%5u %s %.*s %s %.*s %-37.37s%.*s\n", $$1, $$2, 20-length($$2), "....................", $$3, 12-length($$3), "..............................", $$4, (length($$4) > 37), ">" }')

mailout: ...check-locks.mailout ...running-diff.mailout ...flash-diff.mailout ...rlog.mailout $(muttrc) check-locks.txt running-diff.txt flash-diff.txt rlog.txt models.txt boot_versions.txt cliaudit.txt failover-diff.txt inactive.txt
	(print "check-locks.txt:" ; \
	print "   A list of RCS files in $(DIR) that are checked out with a lock.\n" ; \
	print "running-diff.txt:" ; \
	print "   The differences between the devices' flash and running configurations.\n" ; \
	print "flash-diff.txt:" ; \
	print "   The differences between the devices' flash and RCS head revision.\n" ; \
	print "failover-diff.txt:" ; \
	print "   The differences between the primary and secondary device configurations.\n" ; \
	print "rlog.txt:" ; \
	print "   The RCS log messages since the last time it was mailed.\n" ; \
	print "models.txt:" ; \
	print "   A list of devices by IP address, name, and model.\n" ; \
	print "boot_versions.txt:" ; \
	print "   A list of devices by IP address, name, versions, and boot file.\n"; \
	print "cliaudit.txt:" ; \
	print "   A list of CLI (ssh/telnet) connectivity problems.\n" ; \
        print "inactive.txt:" ; \
        print "   A list of temporarily inactive devices.\n" \
	) > ...legend.mailout
	test -h legend.txt || $(ln) -s ...legend.mailout legend.txt
	(print "\n[automatically generated]\n"; $(summarize); print "\ncount model                 version       sysBootVariable/sysConfigName\n----- --------------------- ------------- --------------------------------------"; $(join) -1 1 -2 1 -o '1.3 2.3 2.4' models.txt boot_versions.txt |$(sort) |$(uniq) -c |$(awk) '{ printf "%5u %s %.*s %s %.*s %-37.37s%.*s\n", $$1, $$2, 20-length($$2), "....................", $$3, 12-length($$3), "..............................", $$4, (length($$4) > 37), ">" }'; print "\nSummary of attached files (see the \"legend.txt\" attachment for details):\n" ; \
	test -f ...check-locks.mailout && print "check-locks.txt:\t\t$$($(grep) -c \.conf,v ...check-locks.mailout) \".conf\" file(s) locked\n\t\t\t\tas of $$($(modtime) ...check-locks.mailout)\n" ; \
	test -f ...running-diff.mailout && print "running-diff.txt:\t\t$$($(grep) -c '^Only in flash' ...running-diff.mailout) only in flash, $$($(grep) -c '^Only in running' ...running-diff.mailout) only running, $$($(grep) -c ^diff ...running-diff.mailout) other diffs\n\t\t\t\tas of $$($(modtime) ...running-diff.mailout)\n" ; \
	test -f ...flash-diff.mailout && print "flash-diff.txt:\t\t\t$$($(grep) -c '^Only in RCS' ...flash-diff.mailout) only in RCS, $$($(grep) -c '^Only in flash' ...flash-diff.mailout) only in flash, $$($(grep) -c ^diff ...flash-diff.mailout) other diffs\n\t\t\t\tas of $$($(modtime) ...flash-diff.mailout)\n" ; \
	test -f failover-diff.txt && print "failover-diff.txt:\t\t$$($(grep) -c '^Only in failover/primary' failover-diff.txt) only in pri, $$($(grep) -c '^Only in failover/secondary' failover-diff.txt) only in stby, $$($(grep) -c ^diff failover-diff.txt) other diffs\n\t\t\t\tas of $$($(modtime) failover-diff.txt)\n" ; \
	test -f inactive.txt && print "inactive.txt:\t\t$$($(wc) -l inactive.txt) devices in ~net/cms/inactive\n\t\t\t\tas of  $$($(modtime) inactive.txt)\n" ; \
	test -f ...rlog.mailout && print "rlog.txt:\t\t\t$$($(grep) -c '^revision [0-9]*' ...rlog.mailout) revision(s) to $$($(grep) -c '^==*$$' ...rlog.mailout) file(s) -\n\t\t\t\tfrom $$($(modtime) $(epoch_file).prev) to $$($(modtime) ...rlog.mailout)" ; \
	print \
	) > ...body.mailout
	$(mutt) -F'$(muttrc)' -s$$(hostname -s)' $(DIR) update' $$(print -- $$($(ls) check-locks.txt flash-diff.txt failover-diff.txt legend.txt rlog.txt running-diff.txt boot_versions.txt models.txt cliaudit.txt inactive.txt |sed -e 's/^/-a/')) -i ...body.mailout $(mailto)

...summary.txt:
	$(MAKE) -s summary > $@

summary_mailout: ...summary.txt
	netname="$(netname)"; \
	test -s ...summary.txt && $(mutt) -F$(DIR)/.muttrc -s"$${netname}$${netname:+ }device summary" -i ...summary.txt $(summary_mailto)

clean:
	$(rm) -rf ...* models.txt versions boot_versions.txt bootfile.txt failover-diff.txt inactive.txt

audit:
	@$(find) .*_show_int*.txt \( -size 0 -o \! -group netters -o \! -perm 0664 \) -print |$(xargs) --no-run-if-empty $(ls) -l ; \
	$(ls) *.conf,v |$(sed) -e 's/,v$$//' |$(xargs) --no-run-if-empty $(ls) >/dev/null ; \
	$(find) *.conf -type f -size 0 -perm 0444 -print |$(xargs) --no-run-if-empty $(ls) -ld ; \
	$(ls) -l *[0-9].conf,v 2>/dev/null ; \
	$(awk) '{print $$1}' ...hosts |$(sort) |$(uniq) -d

cliaudit:
	$(ls) !(*_*).conf,v |$(sed) -e 's/\.conf,v$$//' |$(fping) -a \
		|while read host; \
		do \
			case $${host?} in \
			f-*|fc-*|ff-*|fx-*|l-*|lc-*|ma-*|va-*|u-*) \
				;; \
			*) \
				$(nc) -vz $${host?} telnet; \
			esac; \
			case $${host?} in \
			t-*|d-*) \
				;; \
			*) \
				$(nc) -vz $${host?} ssh; \
			esac; \
		done 2>&1 |$(grep) -v 'open$$'

cliaudit.txt:
	$(MAKE) -s cliaudit > $@

rev.dat:
	$(perl) -MRcs -MPOSIX -e ' \
	foreach my $${file} (<*.conf,v>) { \
	   next if ($${file} =~ m/-lab\.conf/); \
	   $$count{strftime("%Y-%m-%d", \
	                    localtime(Rcs->new($${file})->revdate("1.1")))}++; \
	}; \
	my $$total = 0; \
	foreach (sort keys(%count)) { \
	   $$total += $$count{$$_}; \
	   print "$${_}-00:00:00 $${total}\n"; \
	} \
	' > $@

revs.dat:
	$(perl) -MRcs -MPOSIX -e ' \
	foreach my $${file} (<*.conf,v>) { \
	   next if ($${file} =~ m/-lab\.conf/); \
	   my %DatesHash = Rcs->new($${file})->dates; \
	   foreach my $$time_t (values(%DatesHash)) { \
	      $$count{strftime("%Y-%m-%d", localtime($$time_t))}++; \
	   } \
	} \
	foreach (sort keys(%count)) { \
	   print "$${_}-00:00:00 $$count{$$_}\n"; \
	} \
	' > $@

# { Postupdate - no longer needed for most devices as of 3/10

.conf.postupdate:
	true

# }{ UW-MADISON CUSTOM POST-UPDATES FOR LAYER-4 SWITCHES #######################

l4mailto = net-cms-l4-update@lists.wisc.edu

l-csscplat-b380-2-access.postupdate:
	test -t 0 || exit 0
	$(find_revisions) -n ...$*.update $*.conf,v > ...$*.find_revisions
	trap "rm -rf /tmp/.l4mailto.$$$$" INT EXIT; \
	$(mkdir) -p /tmp/.l4mailto.$$$$ && \
	$(perl) -pe 's/((rcomm|wcomm|t1comm|secret)\s+)".*?"/$$1"[SECRET]"/' $*.conf > /tmp/.l4mailto.$$$$/$*.conf; \
	(test -s ...$*.find_revisions && $(mutt) -F'$(muttrc)' -s'[automatically generated] $(DIR) $* update' -a /tmp/.l4mailto.$$$$/$*.conf -i ...$*.find_revisions $(l4mailto)) </dev/null || exit 0

l-csscplat-b380-3-access.postupdate:
	test -t 0 || exit 0
	$(find_revisions) -n ...$*.update $*.conf,v > ...$*.find_revisions
	trap "rm -rf /tmp/.l4mailto.$$$$" INT EXIT; \
	$(mkdir) -p /tmp/.l4mailto.$$$$ && \
	$(perl) -pe 's/((rcomm|wcomm|t1comm|secret)\s+)".*?"/$$1"[SECRET]"/' $*.conf > /tmp/.l4mailto.$$$$/$*.conf; \
	(test -s ...$*.find_revisions && $(mutt) -F'$(muttrc)' -s'[automatically generated] $(DIR) $* update' -a /tmp/.l4mailto.$$$$/$*.conf -i ...$*.find_revisions $(l4mailto)) </dev/null || exit 0

# }{ ###########################################################################

versions:
	$(get_versions)

models.txt: ...hosts sysObjectID.txt
	$(nb_cms_snmp)

# this xmodels rule is for testing (so you don't clobber models.txt):
xmodels.txt: ...hosts sysObjectID.txt
	time $(nb_cms_snmp) -o - |$(sortbyip) > $@

CISCO-PRODUCTS-MIB.oid:
	ncftpget ftp://ftp.cisco.com/pub/mibs/oid/$@

CISCO-STACK-MIB.oid:
	ncftpget ftp://ftp.cisco.com/pub/mibs/oid/$@

sysObjectID.txt: CISCO-PRODUCTS-MIB.oid CISCO-STACK-MIB.oid JUNIPER-CHASSIS-DEFINES-MIB.oid APC-PRODUCTS-MIB.oid  MARCONI-PRODUCTS-MIB.oid  NETSCREEN-PRODUCTS-MIB.oid ALTROOT-MIB.oid FORTINET-PRODUCTS-MIB.oid CITRIX-PRODUCTS-MIB.oid
	$(sed) -e '/^#/d' -e 's/\"//g' CISCO-PRODUCTS-MIB.oid CISCO-STACK-MIB.oid JUNIPER-CHASSIS-DEFINES-MIB.oid APC-PRODUCTS-MIB.oid  MARCONI-PRODUCTS-MIB.oid  NETSCREEN-PRODUCTS-MIB.oid ALTROOT-MIB.oid FORTINET-PRODUCTS-MIB.oid CITRIX-PRODUCTS-MIB.oid |awk '{print $$1, $$2}' |$(sort) -k 2 |$(uniq) > $@
	$(perl) -pi -e 's/sysID(\W+)/$$1/' $@
	$(perl) -pi -e 's/ciscoWSC(\d+)/cat$$1/' $@

versions.txt: versions
	$(ln) -fs versions versions.txt

models: ...hosts
	trap "rm -f /tmp/.*.$$$$" INT EXIT; \
	$(sort) ...hosts >/tmp/.hosts.$$$$; \
	$(grep) '^[^#]' /tmp/.hosts.$$$$ |$(awk) '{print $$1}' |while read host; \
	do \
	print -n "$$host: "; \
	$(altwalk) -no /usr/local/lib/oids/RFC1213-MIB.oid $${host?} $(community) sysDescr 2>/dev/null || print; \
	done |$(perl) -ne 'm/\d+\.\d+\.\d+\.\d+/ && print "$$&\t"; if (m/\s+([A-Z0-9][A-Z0-9-]*[0-9]+)/) { print "$$1\n" } else { print "unknown\n" }' > /tmp/.models.$$$$; \
	$(join) -j 1 /tmp/.hosts.$$$$ /tmp/.models.$$$$ |$(sortbyip) > $@

fping.available: ...hosts
	awk '{print $$1}' ...hosts |fping -a 2>/dev/null |ip2hostname -p '%s %s'

fping.unavailable: ...hosts
	awk '{print $$1}' ...hosts |fping -u 2>/dev/null |ip2hostname -p '%s %s'

# }{ CISCONF ###################################################################

cisconf_config_file = /home/net/cms/etc/cisconf_configuration
cisconf = /usr/bin/cisconf

# clogin = /usr/local/rancid/bin/clogin
clogin = /usr/local/ns/bin/clogin2 -f ~net/.cloginrc
# use clogin's builtin default (45 seconds?) if unset:
clogin_timeout =

rcslocked = /home/net/cms/bin/rcslocked

legacy_pass_devices = 

.conf.cisconf-a:
	$(perl) -MCisco::Conf -e '@legacy = qw($(legacy_pass_devices)); @_ = getgrnam("net"); @users = split(" ", $$_[3]); die unless @users; Cisco::Conf->Add("$(cisconf_config_file)", { name => "$*", description => "$*", users => [@users], host => "$*", username => "net", password => "passwd", enable_password => ((grep { "$*" eq $$_ } @legacy)? "cisco" : "epasswd"), file => "$<" })'

.conf.cisconf-d:
	$(perl) -MCisco::Conf -e 'Cisco::Conf->Remove("$(cisconf_config_file)", "$*")'

refresh_cisconf:
	$(MAKE) -s -i `$(ls) !(pc-*).conf,v |$(sed) -e 's/conf,v$$/cisconf-d/'`
	$(MAKE) -s -i `$(ls) !(pc-*).conf,v |$(sed) -e 's/conf,v$$/cisconf-a/'`

# { implicit rules for IOS devices #############################################

.conf.copy:
	$(cisconf) -s $* -f

.conf.write:
	$(cisconf) -s $* -w -f

.conf_write.log:
	@echo BEGIN _write.log $@
	$(cisconf) -s $* -w -f > $@
	@echo END _write.log $@

# } ############################################################################

locked.copy:
	$(rcslocked) !(*_*).conf,v |$(sed) -e 's/\.conf.*$$//' |while read device ; \
	do \
	   $(MAKE) -i $${device?}.copy; \
	done

locked.write:
	$(rcslocked) !(*_*).conf,v |$(sed) -e 's/\.conf.*$$//' |while read device ; \
	do \
	   $(MAKE) -i $${device?}.write; \
	done

locked.clogin:
	clogin_timeout=$(clogin_timeout); \
	set -x; \
	$(rcslocked) !(*_*).conf,v |$(sed) -e 's/\.conf.*$$//' |xargs strace -e alarm,select $(clogin) $${clogin_timeout:+-t$${clogin_timeout}} -c "$(command)"

# rcsgrep '^access-list 100' *.conf,v 2>/dev/null |cut -f1 -d: |sort -u
locked.pushacl:
	@read ACL?'Enter IOS ACL number: ' ; \
        export ACL; \
	bin/conf2acl $$($(rcslocked) !(*_*).conf,v)
	$(MAKE) -i locked.copy
	$(MAKE) locked.clogin command="write memory"
	$(MAKE) locked.getcnf

.hosts.available:
	xargs $(fping) -a 2>/dev/null < $<

.hosts.lock:
	$(co) -l $$(sed -e 's/$$/.conf/' $<)

.hosts.forcelock:
	$(co) -f -l $$(sed -e 's/$$/.conf/' $<)

.hosts.rcsdiff:
	rcsdiff $$(sed -e 's/$$/.conf/' $<) 2>&1

.hosts.checkin:
	ci -u $$(sed -e 's/$$/.conf/' $<)

# forcecheckinlock is deprecated, use logmsgcheckinlock instead:
.hosts.forcecheckinlock:
	$(ci) -m"$(logmsg)" -l $$(sed -e 's/$$/.conf/' $<) </dev/null

.hosts.logmsgcheckinlock:
	$(ci) -m"$(logmsg)" -l $$(sed -e 's/$$/.conf/' $<) </dev/null

.hosts.unlock:
	co -u $$(sed -e 's/$$/.conf/' $<)

.hosts.forceunlock:
	co -f -u $$(sed -e 's/$$/.conf/' $<)

.hosts.clogin:
	xargs $(clogin) -c "$(command)" $${clogin_timeout:+-t$${clogin_timeout}} < $<

.hosts.getcnf:
	xargs -n1 --no-run-if-empty $(getcnf) -o%s%s.conf < $<

jobs = 50 # this was the fastest for pargetcnf on 2004-08-16 with 248 hosts

.hosts.pargetcnf:
	$(MAKE) -i -j $(jobs) $$($(sed) -e 's/$$/.getcnf/' $<)

.hosts.copy:
	while read device ; \
	do \
	   $(MAKE) -i $${device?}.copy; \
	done < $<

.hosts.parcopy:
	$(MAKE) -i -j $(jobs) $$($(sed) -e 's/$$/.copy/' $<)

.hosts.write:
	while read device ; \
	do \
	   $(MAKE) -i $${device?}.write; \
	done < $<

.hosts.parwrite:
	$(MAKE) -i -j $(jobs) $$($(sed) -e 's/$$/.write/' $<)

# usage: (from other dir) make -f ../path/Makefile makefile=../path/Makefile foo.parwritelog
.hosts.parwritelog:
	makefile=$(makefile); \
	$(MAKE) $${makefile+-f }$${makefile} -i -j $(jobs) $$($(sed) -e 's/$$/_write.log/' $<)

# { implict rules for *hosts.txt ###############################################

# note that these are all phony targets:

%hosts.fping: %hosts.txt
	$(fping) 2>/dev/null < $<

%hosts.available: %hosts.txt
	$(fping) -a 2>/dev/null < $<

%hosts.unavailable: %hosts.txt
	$(fping) -u 2>/dev/null < $<

%hosts.lock: %hosts.txt
	$(co -l $$($(sed) -e 's/$$/.conf/' $<)

%hosts.forcelock: %hosts.txt
	$(co) -f -l $$($(sed) -e 's/$$/.conf/' $<)

%hosts.rcsdiff: %hosts.txt
	$(rcsdiff) 2>&1 $$($(sed) -e 's/$$/.conf/' $<)

%hosts.checkin: %hosts.txt
	$(ci) -u $$(sed -e 's/$$/.conf/' $<)

# forcecheckinlock is deprecated, use logmsgcheckinlock instead:
%hosts.forcecheckinlock: %hosts.txt
	$(ci) -m"$(logmsg)" -l $$(sed -e 's/$$/.conf/' $<) </dev/null

%hosts.logmsgcheckinlock: %hosts.txt
	$(ci) -m"$(logmsg)" -f -l $$(sed -e 's/$$/.conf/' $<) </dev/null

%hosts.unlock: %hosts.txt
	$(co) -u $$(sed -e 's/$$/.conf/' $<)

%hosts.forceunlock: %hosts.txt
	$(co) -f -u $$(sed -e 's/$$/.conf/' $<)

%hosts.getcnf: %hosts.txt
	$(xargs) -n1 --no-run-if-empty $(getcnf) -o%s%s.conf < $<

%hosts.copy: %hosts.txt
	$(xargs) --no-run-if-empty --replace $(MAKE) -i {}.copy < $<

%hosts.write: %hosts.txt
	$(xargs) --no-run-if-empty --replace $(MAKE) -i {}.write < $<

# }{ implict rules for *conf.txt ###############################################

# note that these are all phony targets:

%conf.fping: %conf.txt
	$(sed) -e 's/\.conf[ 	]*$$//' $< |$(fping) 2>/dev/null

%conf.available: %conf.txt
	$(sed) -e 's/\.conf[ 	]*$$//' $< |$(fping) -a 2>/dev/null

%conf.unavailable: %conf.txt
	$(sed) -e 's/\.conf[ 	]*$$//' $< |$(fping) -u 2>/dev/null < $<

%conf.lock: %conf.txt
	$(co) -l $$(<$<)

%conf.forcelock: %conf.txt
	$(co) -f -l $$(<$<)

%conf.rcsdiff: %conf.txt
	$(rcsdiff) $$(<$<) 2>&1

%conf.checkin: %conf.txt
	$(ci) -u $$(<$<)

%conf.unlock: %conf.txt
	$(co) -u $$(<$<)

%conf.forceunlock: %conf.txt
	$(co) -f -u $$(<$<)

%conf.getcnf: %conf.txt
	$(sed) -e 's/\.conf[ 	]*$$//' $< |$(xargs) -n1 --no-run-if-empty $(getcnf) -o%s%s.conf

%conf.copy: %conf.txt
	$(sed) -e 's/\.conf[ 	]*$$//' $< | $(xargs) --no-run-if-empty --replace $(MAKE) -i {}.copy

%conf.write: %conf.txt
	$(sed) -e 's/\.conf[ 	]*$$//' $< | $(xargs) --no-run-if-empty --replace $(MAKE) -i {}.write

# } "convenience" rules for common mass changes  ###############################

.hosts.pushacl:
	@read ACL?'Enter IOS ACL number: ' ; \
        export ACL; \
	bin/conf2acl $$(sed -e 's/$$/.conf/' $<)
	$(MAKE) -i $*.write
	$(MAKE) $*.getcnf

.hosts.parpushacl:
	@if test -z "$(ACL)"; \
	then \
		read ACL?'Enter IOS ACL number: ' ; \
        	export ACL; \
	else \
		export ACL="$(ACL)"; \
	fi; \
	echo ACL $(ACL) selected...; \
	bin/conf2acl $$(sed -e 's/$$/.conf/' $<)
	$(MAKE) -i $*.parwrite
	$(MAKE) $*.pargetcnf

.hosts.pushbanner:
	bin/conf2banner $$(sed -e 's/$$/.conf/' $<)
	$(MAKE) -i $*.copy
	@read confirm?'Proceed with "write memory"? '; \
	case "$confirm" in \
	[Yy]*) ;; \
	*) exit 0 ;; \
	esac
	$(MAKE) $*.clogin command="write memory"
	$(MAKE) $*.getcnf

.hosts.pushenable:
	false # FIXME

.hosts.pushradius:
	false # FIXME

acl100.hosts: ...hosts
	rcsgrep 'access-list 100 ' *.conf,v |cut -f1 -d: |sort -u |sed -e 's/.conf$$//' > $@

pushacl100: acl100.hosts
	$(MAKE) acl100.lock
	$(MAKE) acl100.pushacl ACL=100
	$(MAKE) acl100.checkin
	$(MAKE) acl100.unlock

acl$(ACL).hosts: ...hosts
	@test -n "$(ACL)" || (print -u2 "usage: $(MAKE) {target} ACL={number}"; exit 1)
	rcsgrep 'access-list $(ACL) ' *.conf,v |cut -f1 -d: |sort -u |sed -e 's/.conf$$//' > $@

pushacl$(ACL): acl$(ACL).hosts
	@test -n "$(ACL)" || (print -u2 "usage: $(MAKE) {target} ACL={number}"; exit 1)
	$(MAKE) acl$(ACL).lock
	$(MAKE) acl$(ACL).pushacl ACL=$(ACL)
	$(MAKE) acl$(ACL).checkin
	$(MAKE) acl$(ACL).unlock

debugstp.hosts: models
	$(ls) s-*.conf,v |sed -e 's/\.conf,v$$//' > $@

debugstp: debugstp.hosts
	$(MAKE) debugstp.clogin command="debug spanning-tree events"

.cmd.log:
	@echo BEGIN .cmd.log $@
	base='$*'; \
	$(clogin) $${clogin_timeout:+-t$${clogin_timeout}} -x $< $${base%%_*} > $@ || (rm -f $@; exit 1)
	@echo END .cmd.log $@

# } ############################################################################

natkit.txt:
	$(ls) *.conf,v | perl -MSocket -lne 'm/^(.*?)\.conf,v$$/ && printf("%s itsnotpublic\n", inet_ntoa(inet_aton($$1)))' |$(sortbyip) |sed -e 's/ /,/' > $@

# { showstp$(vlan) #############################################################
#
# usage: [time] make snapshotstp vlan=999
#
# eg.
#    $ make snapshotstp vlan=999
#    $ # ... wait ...
#    $ make snapshotstp vlan=999
#    $ cd stp999
#    $ diff YYYYMMDD_HH:MI:SS YYYYMMDD_HH:MI:SS

.conf_showstp$(vlan).cmd: models.txt
	exec > $@; \
	vlan=$(vlan); \
	[ -z "${vlan}" ] && unset vlan; \
	case "$$(grep ' $* ' models.txt |awk '{print $$NF}')" in \
		wsc*) print "show spantree$${vlan+ }$${vlan}"; \
                      print "show spantree bpdu-skewing $${vlan}"; \
                      print "show spantree summary novlan" ;; \
		*) print "show spanning-tree $${vlan+vlan }$${vlan}"; \
                   print "show spanning-tree summary totals" ;; \
	esac; \
	print "show cdp neighbors"

showstp$(vlan).make: models
	print "include Makefile\
		\nTMPshowstp$(vlan):" \
		$$($(ls) !(t-*).conf,v |sed -e 's/\.conf,v$$/_showstp$(vlan).log/') > $@

# a parallelized "show spanning-tree vlan $(vlan)":
showstp$(vlan): showstp$(vlan).make
	$(MAKE) -j 20 -f $< vlan=$(vlan) TMPshowstp$(vlan)

snapshotstp:
	rm -f *_showstp$(vlan).log
	time make showstp$(vlan) vlan=$(vlan)
	dir=$$(perl -MPOSIX -e 'print strftime("stp$(vlan)/%Y%m%d_%H:%M:%S\n", localtime)'); \
	mkdir -p $${dir?} && mv *_showstp$(vlan).log $${dir?}

snmpsnapshotstp:
	rm -f *_stp$(vlan).obj snmpsnapshotstp$(vlan).log
	$(stpgraph) -b $(bridgeids) -Cc itsnotpublic@$(vlan) -P -s %s_stp$(vlan).obj $$($(ls) -d *.conf,v |sed -e 's/\.conf,v//') > snmpsnapshotstp$(vlan).log 2>&1
	dir=$$(perl -MPOSIX -e 'print strftime("snmpstp$(vlan)/%Y%m%d_%H:%M:%S\n", localtime)'); \
	mkdir -p $${dir?} && $(mv) *_stp$(vlan).obj $${dir?}; \
	$(mv) snmpsnapshotstp$(vlan).log $${dir?}_snmpsnapshotstp$(vlan).log

stpreport.txt:
	$(perl) -lne 'if ($$count or (m/STP Active/ && ($$count = 3))) { print "$$ARGV $$_" if 1 == $$count; $$count-- }' $$($(ls) $$($(ls) -d stp999/* |$(tail) -1)/*.log) |sed -e 's/Total//' -e 's/[0-9][0-9]* vlans//' |$(perl) -MFile::Basename -le 'while (<>) { @F = split(m/\s+/, $$_); push (@_, [@F]) } print "Name                           Blocking Listening Learning Forwarding STP Active"; foreach (sort { $$b->[5] <=> $$a->[5] } @_) { $$_->[0] = basename($$_->[0], "_showstp999.log"); printf("%-29.29s %9u %9u %9u %9u %10u\n", @{$$_}) }' > $@

vlanreport.txt:
	$(ls) *.conf,v |sed -e 's/,v$$//' |xargs -n1 perl -ne 'm/vlan\s*(\d+)/i && ($$vlan{$$1} = 1); END { printf("%4u %s\n", scalar(keys(%vlan)), $$ARGV) }' |sort -nr > $@

# }{ show route stuff ##########################################################

.conf_showiproute.cmd:
	exec > $@; \
	print "show ip route"

showiprouteclean:
	rm -f *_showiproute.cmd *_showiproute.log 2>/dev/null

showiproute:
	$(MAKE) -f ./Makefile -j 20 $$($(ls) *.conf,v 2>/dev/null |sed -e 's/\.conf,v$$/_showiproute.log/')

# }{ show mac stuff ############################################################

# usage: [time] make snapshotmac

.conf_showmac.cmd: models.txt
	exec > $@; \
	case "$$(grep ' $* ' models.txt |awk '{print $$NF}')" in \
		wsc*) print "show cam dynamic" ;; \
		*) print "show mac-address-table dynamic" ;; \
	esac

showmac.make: models
	print "include Makefile\
		\nTMPshowmac:" \
		$$($(ls) [rs]-*.conf,v so-*.conf,v 2>/dev/null |sed -e 's/\.conf,v$$/_showmac.log/') > $@

showmac: showmac.make
	$(MAKE) -j 20 -f $< TMPshowmac

snapshotmac:
	rm -f *_showmac.log
	time make showmac
	dir=$$(perl -MPOSIX -e 'print strftime("mac/%Y%m%d_%H:%M:%S\n", localtime)'); \
	mkdir -p $${dir?} && mv *_showmac.log $${dir?}

macreport.txt: models.txt
	(printf "dyn MAC addrs  device                          model\n-------------  ------------------------------  ------------------------------\n"; \
	(grep Total $$($(ls) $$($(ls) -d mac/* |$(tail) -1)/*.log) |perl -e 'open(MODELS, "<$<") or die; while (<MODELS>) { @F = split; $$model{$$F[1]} = $$F[2] }; while (<STDIN>) { m|([^/]*)?_showmac.*?(\d+)\r?$$| && printf("%13u  %-30.30s  %-30.30s\n", $$2, $$1, $$model{$$1}) }' |sort -nr)) > $@

# }{ show proc cpu stuff #######################################################

# usage: [time] make snapshotmac

.conf_showproccpu.cmd: models.txt
	exec > $@; \
	case "$$(grep ' $* ' models.txt |awk '{print $$NF}')" in \
		*) print "show proc cpu" ;; \
	esac

showproccpu.make: models
	print "include Makefile\
		\nTMPshowproccpu:" \
		$$($(ls) !(t-*).conf,v |sed -e 's/\.conf,v$$/_showproccpu.log/') > $@

showproccpu: showproccpu.make
	$(MAKE) -j 20 -f $< TMPshowproccpu

snapshotcpu:
	rm -f *_showproccpu.log
	time make showproccpu
	dir=$$(perl -MPOSIX -e 'print strftime("cpu/%Y%m%d_%H:%M:%S\n", localtime)'); \
	mkdir -p $${dir?} && mv *_showproccpu.log $${dir?}; \
	perl -pi -e 's/\r+$$//' $${dir?}/*.log

cpureport.txt:
	dir=$$($(ls) -d cpu/* |$(tail) -1); \
	set -A files $$($(ls) $${dir?}/*.log); \
	(print "                             $${dir?}"; \
	(perl -00 -lne 'm/^CPU/ && s/\n/ /g && s/(\s)\s*/$$1/g && ($$host = $$ARGV, $$host =~ s|^.*/([^_]+)_.*$$|$$1|, 1) && print("$$host $$_")' "$${files[@]}"; \
	perl -lne 'm/^CPU[^0-9]+?(\d+)[^0-9]+?(\d+)[^0-9]+?(\d+)[^0-9]+?(\d+)/ && ($$host = $$ARGV, $$host =~ s|^.*/([^_]+)_.*$$|$$1|, 1) && print "$$host $$_"' "$${files[@]}") |awk '{ print $$7, $$0 }' |sed -e 's/CPU utilization for //' -e 's/second/sec/g' -e 's/minute/min/g' |sort -nr |perl -lane 'shift(@F); $$host = shift(@F); printf("%-28.28s %s", $$host, "@F\n")') |grep -v '^[ 	][ 	]*$$' > $@

# }{ bootfile stuff ############################################################

.conf_showboot.cmd:
	exec > $@; \
	print "show bootvar"; \
	print "show boot"; \
	print "show ver"

_showboot.log.bootfile:
	perl -lne 'if (m|^BOOT| && m|([^:/]+)$$|i) { $$file = $$1; $$file =~ s/[;,]\d*\r?$$//; print("$* ", $$file); exit(0) } END { exit(1) }' $< || perl -lne "m/[\"'](boot)?flash:(.*?)[\"']/i && print '$* ', \$$2" $<

# from CISCO-STACK-MIB:
#   sysBootVariable .1.3.6.1.4.1.9.5.1.1.37
#        DESCRIPTION   "A list of the system boot images in the BOOT 
#                      environment variable on supervisor modules with 
#                      ROMMON. The format of sysBootVariable should be:
#                   <device>:[<fileName>],1;{<device>:[<fileName>],1;...}
#                      If the [fileName] is not specified, the first file
#                      on the <device> will be used.
#
#   sysBootedImage .1.3.6.1.4.1.9.5.1.1.38
#        DESCRIPTION   "The name of the system boot image which the 
#                      system booted from.
#                      This MIB object is only supported in the system 
#                      with Supervisor module 3 present."
#
# from OLD-CISCO-SYSTEM-MIB:
#   sysConfigName .1.3.6.1.4.1.9.2.1.73.0
#                   DESCRIPTION
#                           "Holds the name of the system boot image."

.conf.bootfile:
	case "$*" in \
	s[ho]-*) \
		$(altget) -n $* $(community) 1.3.6.1.4.1.9.5.1.1.37.0 2>/dev/null ;; \
	u-*) \
		$(altget) -n $* $(community) 1.3.6.1.4.1.318.1.4.2.4.1.3.1 2>/dev/null ;; \
	fx-*) \
		$(altget) -n $* $(fwsm_community) 1.3.6.1.2.1.1.1.0 2>/dev/null ;; \
	lc-*) \
		$(altget) -n $* $(community) 1.3.6.1.2.1.1.1.0 2>/dev/null ;; \
	*) \
		$(altget) -n $* $(community) 1.3.6.1.4.1.9.2.1.73.0 2>/dev/null ;; \
	esac | \
		$(perl) -lne 'if (m!("?((sup-boot|boot)?flash|disk\d):)?([^\s;,"]+)(\S+)?$$!i) { $$file = $$4; $$file =~ s|^.*/||; $$file =~ s|,1;$$||; $$file =~ s|^BTSYNC_||;; print "$* $$file"; last } elsif (m!.* NetScaler (.*), Date(.*)!) { $$file = $$1; print "$* $$file"; last } END { print("$* unknown") if "" eq $$file }'

bootfile.txt: 
	$(nb_bootfile_snmp)

xbootfile.txt: 
	$(nb_bootfile_snmp) -o - |$(sortbyip) > $@

boot_versions.txt: bootfile.txt versions.txt
	$(join) -1 1 -2 1 -o '1.1 1.2 2.3 1.3' bootfile.txt versions.txt > $@ || ($(rm) -f $@; exit 1)

# }{ SNMP stp stuff ############################################################

# from BRIDGE-MIB:
#  "dot1dBaseBridgeAddress"        "1.3.6.1.2.1.17.1.1"
#
#  "dot1dStpPortTable"             "1.3.6.1.2.1.17.2.15"
#  "dot1dStpPortEntry"             "1.3.6.1.2.1.17.2.15.1"
#  "dot1dStpPort"          "1.3.6.1.2.1.17.2.15.1.1"
#  "dot1dStpPortPriority"          "1.3.6.1.2.1.17.2.15.1.2"
#  "dot1dStpPortState"             "1.3.6.1.2.1.17.2.15.1.3"
#  "dot1dStpPortEnable"            "1.3.6.1.2.1.17.2.15.1.4"
#  "dot1dStpPortPathCost"          "1.3.6.1.2.1.17.2.15.1.5"
#  "dot1dStpPortDesignatedRoot"            "1.3.6.1.2.1.17.2.15.1.6"
#  "dot1dStpPortDesignatedCost"            "1.3.6.1.2.1.17.2.15.1.7"
#  "dot1dStpPortDesignatedBridge"          "1.3.6.1.2.1.17.2.15.1.8"
#  "dot1dStpPortDesignatedPort"            "1.3.6.1.2.1.17.2.15.1.9"
#  "dot1dStpPortForwardTransitions"                "1.3.6.1.2.1.17.2.15.1.10"

.conf.bridgeaddress:
	$(altget) $* $(community)@$(vlan) 1.3.6.1.2.1.17.1.1.0 |\
		$(perl) -lne 'BEGIN { $$hex = "[0-9a-f][0-9a-f]"} if (m|($$hex) ?($$hex) ?($$hex) ?($$hex) ?($$hex) ?($$hex)|i) { $$addr="\U$$1:$$2:$$3:$$4:$$5:$$6"; print "$* $$addr"; last } END { print("$* unknown") if "" eq $$addr }'

bridgeaddress$(vlan).txt:
	$(MAKE) -s -j $$($(ls) *.conf,v |sed -e 's/\.conf,v/.bridgeaddress/') > .$@ || ($(rm) -f ..$@; exit 1)
	mv .$@ $@

.conf_stp$(vlan).log:
	$(altwalk) $* $(community)@$(vlan) 1.3.6.1.2.1.17.2.15 |\
	$(perl) -pe '\
	s/^(1\.3\.6\.1\.2\.1\.)?17\.2\.15\.1\.1\./dot1dStpPort./; \
	s/^(1\.3\.6\.1\.2\.1\.)?17\.2\.15\.1\.2\./dot1dStpPortPriority./; \
	s/^(1\.3\.6\.1\.2\.1\.)?17\.2\.15\.1\.3\./dot1dStpPortState./; \
	s/^(1\.3\.6\.1\.2\.1\.)?17\.2\.15\.1\.4\./dot1dStpPortEnable./; \
	s/^(1\.3\.6\.1\.2\.1\.)?17\.2\.15\.1\.5\./dot1dStpPortPathCost./; \
	s/^(1\.3\.6\.1\.2\.1\.)?17\.2\.15\.1\.6\./dot1dStpPortDesignatedRoot./; \
	s/^(1\.3\.6\.1\.2\.1\.)?17\.2\.15\.1\.7\./dot1dStpPortDesignatedCost./; \
	s/^(1\.3\.6\.1\.2\.1\.)?17\.2\.15\.1\.8\./dot1dStpPortDesignatedBridge./; \
	s/^(1\.3\.6\.1\.2\.1\.)?17\.2\.15\.1\.9\./dot1dStpPortDesignatedPort./; \
	s/^(1\.3\.6\.1\.2\.1\.)?17\.2\.15\.1\.10\./dot1dStpPortForwardTransitions./;'

bridgeids = $(DIR)/bridgeaddress.txt
filetype = fig
stpgraph = /usr/local/bin/stpgraph
width = 2
height = 2

.fig.pdf:
	 fig2dev -L pdf $< $@

stp$(vlan).$(filetype):
	rm -f *_stp$(vlan).obj
	$(stpgraph) -b $(bridgeids) -Cc itsnotpublic@$(vlan) -P -s %s_stp$(vlan).obj $$($(ls) -d $(DIR)/!(rh-*).conf,v |sed -e 's/^.*\///' -e 's/\.conf,v//')
	$(stpgraph) -W$(width) -H$(height) -u -X access -g $(filetype) -r *_stp$(vlan).obj > $@ || (rm -f $@; exit 1)

stpITE.$(filetype):
	for vlan in 610 611 612 613 614 705 706; \
	do \
	   rm -f *_stp$${vlan?}.obj; \
	   $(stpgraph) -b $(bridgeids) -Cc itsnotpublic@$${vlan?} -P -s %s_stp$${vlan}.obj $$($(ls) -d *.conf,v |sed -e 's/\.conf,v//'); \
	done
	$(stpgraph) -b $(bridgeids) -c itsnotpublic -s %s_stp.obj l-csscplat-b380-3-access
	$(stpgraph) -b $(bridgeids) -W2 -H2 -u -X access -g $(filetype) -r *_stp610.obj *_stp611.obj *_stp612.obj *_stp613.obj *_stp614.obj *_stp705.obj *_stp706.obj l-csscplat-b380-3-access_stp.obj > $@ || (rm -f $@; exit 1)

stpL4-2.$(filetype):
	for vlan in 615 616 617 618 619 620 621 626 627 ; \
	do \
	   rm -f *_stp$${vlan?}.obj; \
	   $(stpgraph) -b $(bridgeids) -Cc itsnotpublic@$${vlan?} -P -s %s_stp$${vlan}.obj $$($(ls) -d *.conf,v |sed -e 's/\.conf,v//'); \
	done
	$(stpgraph) -b $(bridgeids) -c itsnotpublic -s %s_stp.obj l-csscplat-b380-2-access
	$(stpgraph) -b $(bridgeids) -W2 -H2 -u -X access -g $(filetype) -r l-csscplat-b380-2-access_stp.obj *_stp615.obj *_stp616.obj *_stp617.obj *_stp618.obj *_stp619.obj *_stp620.obj *_stp621.obj *_stp626.obj *_stp627.obj > $@ || (rm -f $@; exit 1)

# } ############################################################################
