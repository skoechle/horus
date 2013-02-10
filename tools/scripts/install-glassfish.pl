#!/usr/bin/perl
#
#==============================================================================
#
#  File.........:   install-glassfish.pl
#
#  Author.......:   Steven Koechle
#
#  Purpose:
#      Install Oracle Glassfish on Ubuntu
#
#  Usage:
#      install-glassfish.pl [-d]
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
my $GF_USER = "glassfish";
my $GF_GRP = "glassfishadm";
my $GF_ZIP = "glassfish-3.1.2.2.zip";
my $WGET = "wget http://download.java.net/glassfish/3.1.2.2/release/glassfish-3.1.2.2.zip";

&main();

sub main()
{
  &gatherArguements();

  &checkUser();

  &addUser();

  &installGlassfish();

}

sub installGlassfish()
{
  executeCMD("apt-get install -y -q unzip");

  executeCMD("cd /home/$GF_USER; mkdir downloads; cd downloads; $WGET; unzip $GF_ZIP");

  executeCMD("chown -R $GF_USER:$GF_GRP /home/$GF_USER/downloads/glassfish3");
  executeCMD("mv /home/$GF_USER/downloads/glassfish3/* /home/$GF_USER/");
  executeCMD("mv /home/$GF_USER/downloads/glassfish3/.* /home/$GF_USER/");
  executeCMD("chmod -R 770 /home/$GF_USER/bin");
  executeCMD("chmod -R 770 /home/$GF_USER/glassfish/bin");

  # Write autostart file
  my $init = "#! /bin/sh\n\n";
  $init .= "#to prevent some possible problems\nexport AS_JAVA=/usr/local/java/latest\n\n";
  $init .= "GLASSFISHPATH=/home/$GF_USER/bin\n\n";
  $init .= "case \"\$1\" in\n";
  $init .= "start)\necho \"starting glassfish from \$GLASSFISHPATH\"\n";
  $init .= "sudo -u $GF_USER \$GLASSFISHPATH/asadmin start-domain domain1\n;;\n";
  $init .= "restart)\n\$0 stop\n\$0 start\n;;\n";
  $init .= "stop)\necho \"stopping glassfish from \$GLASSFISHPATH\"\n";
  $init .= "sudo -u GF_USER \$GLASSFISHPATH/asadmin stop-domain domain1\n;;\n";
  $init .= "*)\necho \$\"usage: \$0 {start|stop|restart}\"\nexit 3\n;;\nesac\n:";

  writeFile('/etc/init.d/glassfish', $init);

  executeCMD("chmod a+x /etc/init.d/glassfish");
  executeCMD("update-rc.d glassfish defaults");
}

sub addUser()
{
  executeCMD("adduser --home /home/$GF_USER --system --shell /bin/bash $GF_USER");
  executeCMD("groupadd $GF_GRP");
  executeCMD("usermod -a -G $GF_GRP $GF_USER");
}

sub checkUser()
{
  if($> != 0)
  {
    print "User does not have root privilegs! Aborting...\n";
    exit 1;
  }
}

sub writeFile($$)
{
  my($file,$body) = @_;

  print "DEBUG: Writing $file with contents:\n $body" if($DEBUG);


  open (MYFILE, "> $file") || die "\n Could not create write file.\n\n";
  print MYFILE $body;
  close (MYFILE);
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
    print "    DEBUG     = $DEBUG\n";
    print "    GF_ZIP    = $GF_ZIP\n";
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