#!/usr/bin/perl
#
#==============================================================================
#
#  File.........:   install-ssh.pl
#
#  Author.......:   Steven Koechle
#
#  Purpose:
#      Install OpenSSH Server on Ubuntu
#
#  Usage:
#      install-ssh.pl [-d]
#
#      where:
#     -d            Debug mode, provides output for troubleshooting.
#
#  Limitations/Assumptions:
#    You must know what you are doing.
#    Internet Connectivity is available.
#    The script is being run with root privileges.
#
#------------------------------------------------------------------------------
#  Revision History:
#    Programmer      Date         Description
#    Steven Koechle  28-Jan-2013  Original Version
#
#==============================================================================
#
use strict;

# SCRIPT VARIABLES
my $DEBUG = 0;


&main();

sub main()
{
  &gatherArguements();

  &checkUser();

  &installSSH();

  &modifyConfig();

  &restartSSH();

}

sub installSSH()
{
  executeCMD("apt-get install -y -q openssh-server");
}

sub modifyConfig()
{
  modifyFile("/etc/ssh/sshd_config","PermitRootLogin yes","PermitRootLogin no");
}

sub restartSSH()
{
  executeCMD("service ssh restart");
}

sub checkUser()
{
  if($> != 0)
  {
    print "User does not have root privilegs! Aborting...\n";
    exit 1;
  }
}

sub modifyFile($$$)
{
  my($file, $search, $mod) = @_;
  my @lines = readFile($file);

  foreach my $line (@lines)
  {
    $line =~ s/$search/$mod/g;
  } # foreach

  writeFile($file,@lines);

}

sub readFile($)
{
  my($file) = @_;

  print "DEBUG: Reading $file\n" if($DEBUG);

  open (F, "< $file") || die "\n Could not open read file.\n\n";
  my @lines = <F>;
  close (F);

  return @lines;
}


sub writeFile($$)
{
  my($file,@lines) = @_;

  print "DEBUG: Writing to file $file\b" if($DEBUG);

  open (F, "> $file") || die "\n Could not create write file.\n\n";

  print F @lines;

  close (F);
}


sub executeCMD($)
{
  my($cmd) = @_;
  print "$cmd\n" if($DEBUG);
  print `$cmd`;
  return $!;
}


sub gatherArguements()
{
  my ($arg, $ArgErrors);
  while(scalar(@ARGV))
  {
    $arg = shift @ARGV;
    if( $arg =~ /^-d$/) {
      $DEBUG = 1;
    } else {
	  $ArgErrors ++;
	  print STDOUT "ERROR: Invalid argument: $arg\n";
	}
  } # While
  
  if($DEBUG)
  {
    print "\nDEBUG: GatherArguements\n";
    print "    DEBUG     = $DEBUG\n";
  }
}

sub printUsage()
{
  print STDOUT << "  EOUSAGE";
  
USAGE:  $0 [-d]

  where:
     -d            Debug mode, provides output for troubleshooting.

  Limitations/Assumptions:
    You must know what you are doing.
    The script is being run with root privileges.
	
  EOUSAGE
}
