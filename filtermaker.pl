#!/usr/bin/perl -w

### Name:	 filtermaker.pl
### Author:	 Richard J. Hicks (richard.hicks@gmail.com)
### Date:	 2010-06-25 (Modified: 2013-06-10)
### Description: This program downloads raw data from SPAMHAUS, CYMRU, OKEAN, 
###              and builds Cisco friendly null routes.


use strict;
use Switch;
### use feature qw/switch/;
use LWP;
use LWP::Simple;
use Getopt::Std;
use POSIX qw(strftime);
use Data::Dumper;

my $currentDate = strftime "%Y-%m-%d", localtime;
my $opt = 'abc';
my %opt;
getopts( $opt, \%opt );
my $ua = LWP::UserAgent->new;
my $agent = "my-lwp agent";
$ua->agent($agent);

### VARIABLES ###
my $spamhausURL  = "http://www.spamhaus.org/drop/drop.txt";
my $spamhausDesc = "SPAMHAUS-DROP-LIST_$currentDate";
my $cymruURL     = "http://www.team-cymru.org/Services/Bogons/bogon-bn-nonagg.txt";
my $cymruDesc    = "CYMRU-BOGON-LIST_$currentDate";
my $okeanURL     = "http://www.okean.com/chinacidr.txt";
my $okeanDesc    = "OKEAN-CHINA-LIST_$currentDate";
#################

# &printHelp unless ($opt{a} or $opt{b} or $opt{c});
if ($opt{a})
        {
                my $req = HTTP::Request->new(GET => $spamhausURL);
                $req->content_type('text/html');
                $req->protocol('HTTP/1.0');
                my $response = $ua->request($req);
                printRoutes(Dumper($response), $spamhausDesc);
        }
if ($opt{b}) { printRoutes(get($cymruURL), $cymruDesc); }
if ($opt{c}) { printRoutes(get($okeanURL), $okeanDesc); }







sub printHelp
{
        print "\n!!! USE THIS SCRIPT AT YOUR OWN RISK !!!\n";

	print "\nThis Perl script creates null routes that can be installed on Cisco routers.\n";
	print "When used in conjuction with uRPF, these filters provide an additional layer of SPAM, BOGON, and China filtering.\n";
	print "Cisco uRPF Info: http://www.cisco.com/web/about/security/intelligence/unicast-rpf.html\n";

        print "\nusage: $0 -a -b -c\n";
	print "Options:\n";
	print " -a  : Spamhaus DROP list data\n";
	print " -b  : CYMRU Bogons list data\n";
	print " -c  : OKEAN China Networks list\n";
	exit 1;
}




sub printRoutes
{
        if (!$_[0])
        {
                print "\nUnable to retrieve date from URL!\n";
                print "Please check the ### VARIABLES ### section of this script.\n";
        }
        else
        {
        	my @values = split(/\s/, $_[0]);
        	foreach my $val (@values)
        	{
        		if ($val =~ /^([\d]+)\.([\d]+)\.([\d]+)\.([\d]+)/)
        		{
        			my @newvalues = split(/\//, $val);
        			print "ip route " . $newvalues[0] . " " . computeMask($newvalues[1]) . " null0 name ". $_[1] . "\n";
        		}
        	}
        }
}



sub computeMask
{
	switch ($_[0])
	{
		case 0  {return "0.0.0.0"}
                case 1  {return "128.0.0.0"}
                case 2  {return "192.0.0.0"}
                case 3  {return "224.0.0.0"}
                case 4  {return "240.0.0.0"}
                case 5  {return "248.0.0.0"}
                case 6  {return "252.0.0.0"}
                case 7  {return "254.0.0.0"}
                case 8  {return "255.0.0.0"}
                case 9  {return "255.128.0.0"}
                case 10 {return "255.192.0.0"}
                case 11 {return "255.224.0.0"}
                case 12 {return "255.240.0.0"}
                case 13 {return "255.248.0.0"}
                case 14 {return "255.252.0.0"}
                case 15 {return "255.254.0.0"}
                case 16 {return "255.255.0.0"}
                case 17 {return "255.255.128.0"}
                case 18 {return "255.255.192.0"}
                case 19 {return "255.255.224.0"}
                case 20 {return "255.255.240.0"}
                case 21 {return "255.255.248.0"}
                case 22 {return "255.255.252.0"}
                case 23 {return "255.255.254.0"}
                case 24 {return "255.255.255.0"}
                case 25 {return "255.255.255.128"}
                case 26 {return "255.255.255.192"}
                case 27 {return "255.255.255.224"}
                case 28 {return "255.255.255.240"}
                case 29 {return "255.255.255.248"}
                case 30 {return "255.255.255.252"}
                case 31 {return "255.255.255.254"}
                case 32 {return "255.255.255.255"}
		else    {return ()}
	}
}
