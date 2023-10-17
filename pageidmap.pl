#!/usr/bin/perl

use URI::Escape::XS qw/uri_escape/;

my $file = shift(@ARGV) or die "Usage: pageidmap.pl FILENAME";

open my $info, $file or die "Could not open $file: $!";

while( my $line = <$info>)  {   
	chomp $line;
    my @page = split("\t",$line);
	my $pageID = @page[0];
	my $spacekey = @page[1];
	my $title = @page[2];
	$pageID =~ s/^\s+|\s+$//g;

# Handle special characters that the Cloud "magic redirector" does not like:

	if ($title =~ m|[&/+%]|) {
		print $pageID . "\t/wiki/search?text=" . uri_escape($title) . "\n";

# Reduce size of mapping table by only including pages whose titles include characters that prevent pretty format  
# https://confluence.atlassian.com/confkb/the-differences-between-various-url-formats-for-a-confluence-page-278692715.html

	} elsif ($title =~ m|[?\\;#§:]| || $title =~ m/[^a-zA-Z0-9]$/ || $title =~ m/[^\x00-\x7f]/ ) {
		$title =~ s/ /+/g;
		print $pageID . "\t/wiki/display/" . $spacekey . "/" . uri_escape($title) . "\n";
	} 
}

close $info;
