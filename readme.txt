pirat - provider independent router automation tool
------------------------------------------------------
  The point of pirat is to automate the configuration of routers.
It can be as simple as using clogin2 to log into routers, but it
really shines when coupled with other tools.  Pirat has the following
tools in its chest:
 - Clogin2 is a tweaked clogin script.  It stores password and login 
   information in a config file called .cloginrc.  clogin2 must work
   before anything else will work.

 - Make is used to automate running commands in parallel.  The fundamental
   hack here is that make device.log will create a .log file, from a
   .cmd file, using clogin2 as a 'compiler' instead of gcc.  For example
   consideer that you have pirat installed on localhost, and you have a
   file called device.cmd that contains "show calender;show clock".
   If you type the following:

     localhost$> make device.log

   make will invoke clogin2, which will log into device, run the commands
   "show calendar" and "show clock" and save the output to the file
   device.log

 - mkcmdfile is used to produce command files from config files.
   It works with rancid directories at the moment, but it can be
   trivially modified to work with any directory containing a mess of
   files with some standard naming convention.  For example, if all
   your config files are named device.conf.

 - Pirat passwords
   Pirat gets passwords in three places:
   - if passwords are defined as environment variables they are preferred.
   - it uses $HOME/.cloginrc next, if present
   - it uses /etc/cloginrc if none of the above are present
   
Here is an example:

 - We start by using clogin2 purely from the command line.  We untar it
   into a directory, and cd into that directory and test:

 - working clogin strings
   ./clogin2 -v 'mypw' -e enapw -c "show clock" router
   ./clogin2 -v 'mypw' -e enapw -c "show cdp neigh" router2
   ./clogin2 -noenable -v 'mypw' -e enapw -c "show cdp neigh" router2

 - we edit a file called router.cmd with a single command in it, and try this:
   ./clogin2 -v 'mypw' -e enapw -x router.cmd router

Note that the following are not valid syntax, the clogin2 command is picky:

 - fails if enable pw left out:
   ./clogin2 -noenable -v 'mypw' -c "show cdp neigh" router
   ./clogin2 -v 'mypw' -noenable -c "show cdp neigh" router
   ./clogin2 -f ./.cloginrc -v 'vtypw' -e enapw -x router.cmd router

For normal use, we need to either edit $HOME/.cloginrc or push
the passwords into the environment.  Let's push them into the environment.

export CLOGIN_USR="usrname"
export CLOGIN_VPW="vtypw"
export CLOGIN_EPW="enapw"

 - A quick test shows clogin2 is working:
./clogin2 -c "show clock" router.example.com

Now edit, $HOME/.cloginrc and you should be able to use it for automation.

Now let's make some command files, and automate some stuff:

 - mkcmdfile  getopts('c:df:hlm:o:r:t:w:');
   -c "command;command2" | -w with_cmd_from_file
   -t target,target2 | -f file_w_devices | -r routers.up -m model]

 - mkdir test; cd test; ls /var/rancid/switches/routers.up
  ~/rat/mkcmdfile -m cat5 -r /var/rancid/switches/routers.up
  ~/rat/mkcmdfile -m cat5 -r routers.up -c "show clock;show version"
  make -f ~/rat/Makefile push.make
  make -f push.make -j 4 

rancid dirs:
  /var/rancid/{dir}/routers.up
  dir -> backbone, CVS, datacenter, switches
  backbone: 50 cisco, 3 juniper
  datacenter: 12 cisco, 9 foundry
  switches: 
     11 cat5
    718 cisco
     47 extreme
    142 foundry
      2 juniper

router.db
  #name:(cisco|ezt3|foundry|juniper|redback|cat5):up
  routename1:cisco:up
routers.up
  routername1:cisco
routers.all
  routername1:cisco

bash export:
! export CISCO_USER=rancid
export CLOGIN_UPW="user_pw"
export CLOGIN_VPW="vty_pw"
export CLOGIN_EPW="enable_pw"
./clogin2 -c "sh clock; sh calendar" router1
