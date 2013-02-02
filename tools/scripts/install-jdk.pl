#!/usr/bin/perl
#
#==============================================================================
#
#  File.........:   install-jdk.pl
#
#  Author.......:   Steven Koechle
#
#  Purpose:
#      Install Oracle JDK on Ubuntu
#
#  Usage:
#      install-jdk.pl [-d]
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
my $JDK_URL = 'http://download.oracle.com/otn-pub/java/jdk/7u11-b21/jdk-7u11-linux-x64.tar.gz';
my $JDK_TAR = "jdk-7u11-linux-x64.tar.gz";
my $JDK_DIR = "jdk1.7.0_11";
my $WGET = "wget --no-cookies --header \"Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F\" $JDK_URL";

&main();

sub main()
{
  &gatherArguements();

  &checkUser();

  &installJDK();

  &updateAlternatives();
}

sub updateAlternatives()
{
  executeCMD("update-alternatives --install \"/usr/bin/java\" \"java\" \"/usr/local/java/latest/bin/java\" 1");
  executeCMD("update-alternatives --install \"/usr/bin/javac\" \"javac\" \"/usr/local/java/latest/bin/javac\" 1");
  executeCMD("update-alternatives --install \"/usr/bin/javaws\" \"javaws\" \"/usr/local/java/latest/bin/javaws\" 1");
  executeCMD("update-alternatives --config java");
}

sub installJDK()
{
  executeCMD("apt-get purge -y -q openjdk-\*");

  executeCMD("mkdir -p /usr/local/java; cd /usr/local/java; $WGET; chmod a+x $JDK_TAR; tar xvzf $JDK_TAR");

  executeCMD("chown -R root:root /usr/local/java/$JDK_DIR");
  executeCMD("ln -s /usr/local/java/$JDK_DIR /usr/local/java/latest");

}

sub checkUser()
{
  if($> != 0)
  {
    print "User does not have root privilegs! Aborting...\n";
    exit 1;
  }
}

sub executeCMD($)
{
  my($cmd) = @_;
  print "DEBUG: $cmd\n" if($DEBUG);
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
    print "    $DEBUG     = $MODE\n";
    print "    $JDK_TAR   = $JDK_TAR\n";
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