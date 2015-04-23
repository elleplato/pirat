#!/usr/bin/perl -wT

#==================================================================
# cleanSshKnownHosts.pl, a tool to remove and log changed ssh host keys
# Elle Janet Plato, 2015-04-20 janet.plato@wisc.edu
# Maintained by the NS Application/AANTS Team annts-admin@lists.wisc.edu
#==================================================================

#=== Use/Require
use warnings;
use strict;
use Getopt::Long;
use lib '/usr/local/ns/lib';
#=== 0:Emerg, 1:Alert, 2:Crit, 3:Err, 4:Warn, 5:Notice, 6:Info, 7:Debug
use NS::Syslog 2.0 qw(slog);

#=== Prototypes
sub usage;

#=== untaint
$ENV{PATH} = "/bin:/usr/bin";    # a safe(r) path
delete @ENV{qw(IFS CDPATH ENV BASH_ENV)};   # Make %ENV safer

#=== options
my ($debug);

#=== Define CLI arguments
my $Options = GetOptions(
    "debug:i" => \$debug,
);

#=== config
my $user = getpwuid($<);
my $scannedKey ='';
my $keyScan = '/usr/bin/ssh-keyscan';
my $knownHostKey = '';
my $keyGen = '/usr/bin/ssh-keygen';

if (defined($debug)) {
    slog(7,"cleanSshKnownHosts.pl invoked by [$user]\n");
}

#--- untaint device
my $device = shift or &usage;
if ($device =~ /^([-a-zA-Z0-9.]+)$/) {
    $device = $1;
} else {
    slog(3,"Unable to remove taint from [$device]\n");
    exit;
}

# keyscan likes to use stderr, but this become stdin after pipe, blech
open(STDERR, ">", "/dev/null") or die "$0: open: $!";

my @ksArgs = ($keyScan, '-t', 'rsa', "$device");
my @kgArgs = ($keyGen, '-F', $device);

open(KEYSCAN, '-|', @ksArgs) or
    slog(3,"ssh-keyscan -t rsa $device failed with code: $!") && exit;

while(<KEYSCAN>) {
  next unless (m/(.*) ssh-rsa (.*)$/);
  if (defined($debug)) {
    print "ssh-keyscan returned key for [$1] [$2]\n";
  }
  $scannedKey = $2;
  last;
}

open(KEYFIND, '-|', @kgArgs) or
    slog(3,"ssh-keygen -F $device failed with code: $!") && exit;

while(<KEYFIND>) {
  next unless (m/(.*) ssh-rsa (.*)$/);
  if (defined($debug)) {
    print "ssh-keygen returned key for [$1] [$2]\n";
  }
  $knownHostKey = $2;
  last;
}

if ($scannedKey and $knownHostKey)  {
    if (defined($debug)) {
        slog(7,"Acquired SK [Scanned Key] and KHFileKey [KnownHostFile].\n");
    }
    if (($scannedKey and $knownHostKey) &&
        ($scannedKey) ne ($knownHostKey)) {
        slog(6,"SSH Host Key mismatch in .ssh/known_hosts for [$device]\n");
        if (defined($debug)) {
            slog(7,"SKey:[$scannedKey] KHFileKey:[$knownHostKey]\n");
        }
        my @kgArgs = ($keyGen, '-R', $device);
        system(@kgArgs);
        if ($? == 0) {
          slog(6,"ssh key for $device changed, key removed with ssh-keygen.\n");
          print "ssh key for $device changed, key removed with ssh-keygen.\n";
        } else {
            slog(6,"ssh-keygen -R $device failed returning: [$?]\n");
        }
    } else {
        if (defined($debug)) {
        # slog(7,"Keys for $device match: [$scannedKey] [$knownHostKey]\n");
        }
    }
}

sub usage {
  print "cleanSshKnownHosts.pl logs and removes changed ssh host keys.\n";
  print "Usage: cleanSshKnownHosts.pl device\n";
  exit;
}
