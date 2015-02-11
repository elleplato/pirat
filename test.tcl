#!/usr/bin/expect --

if {[ info exists env(CLOGIN_USR) ] } {
    set username $env(CLOGIN_USR)
    set do_username 0
    puts "Setting username from env to $username"
}
if {[ info exists env(CLOGIN_UPW) ] } {
    set userpasswd $env(CLOGIN_UPW)
    set do_passwd 0
    puts "Setting user password from env to $userpasswd";
}
if {[ info exists env(CLOGIN_VPW) ] } {
    set passwd $env(CLOGIN_VPW)
    set do_passwd 0
    puts "Setting passwd from env to $passwd"
}
if {[ info exists env(CLOGIN_EPW) ] } {
    set enapasswd $env(CLOGIN_EPW)
    set do_enapasswd 0
    puts "Setting ena passwd from env to $enapasswd\n"
}

exit 0
