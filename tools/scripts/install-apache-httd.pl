#!/usr/bin/perl
#
#==============================================================================
#
#  File.........:   install-apache-httd.pl
#
#  Author.......:   Steven Koechle
#
#  Purpose:
#      Install Apache HTTPD Server on Ubuntu
#
#  Usage:
#      install-apache-httd [-d]
#
#      where:
#     -d            Debug mode, provides output for troubleshooting.
#
#  Limitations/Assumptions:
#    You must know what you are doing.
#    You are running on Ubuntu.
#    Internet Connectivity is available.
#    The script is being run with root privileges.
#
#------------------------------------------------------------------------------
#  Revision History:
#    Programmer      Date         Description
#    Steven Koechle  09-Feb-2013  Original Version
#
#==============================================================================
#
use strict;

# SCRIPT VARIABLES
my $DEBUG = 0;
my $PORT = 80;
my $SERVER_ROOT = "/srv/www/htdocs";


&main();

sub main()
{
  &gatherArguements();

  &checkUser();

  &installApache();
  
  &configureApache();
  
  &checkApacheListening();
  
  &installPHP();

  &restartApache();

}

sub installApache()
{
  print "DEBUG: Installing Apache\n" if($DEBUG);
  executeCMD("apt-get install -y -q apache2");
}

sub configureApache()
{
  print "DEBUG: Configuring Apache\n" if($DEBUG);
  executeCMD("mkdir -p $SERVER_ROOT; mv /var/www/index.html $SERVER_ROOT/");
  modifyFile("/etc/apache2/sites-available/default","/var/www",$SERVER_ROOT);
  &restartApache();
}

sub checkApacheListening()
{
  print "DEBUG: Checking Apache Server....." if($DEBUG);
  my $rc = executeCMD("netstat -tuplen | grep 0.0.0.0:$PORT > /dev/null 2>&1");
  if($rc != 0) {
    print "FAILED!\n" if($DEBUG);
    print "\nApache does not appear to be listening on port $PORT\n";
	exit 1;
  }
  print "OK\n" if($DEBUG);
}

sub installPHP()
{
  print "DEBUG: Installing PHP\n" if($DEBUG);
  executeCMD("apt-get install -y -q php5 libapache2-mod-php5");
  executeCMD("echo '<?php phpinfo(); ?>' > $SERVER_ROOT/test.php");
}

sub restartApache()
{
  print "DEBUG: Restartinging Apache\n" if($DEBUG);
  executeCMD("service ssh restart");
}

sub checkUser()
{
  if($> != 0)
  {
    print "User does not have root privilegs! Aborting...\n";
    exit 1;
  }
  print "DEBUG: User has root privilges\n" if($DEBUG);
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
