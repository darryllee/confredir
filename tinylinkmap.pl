#!/usr/bin/perl

use MIME::Base64 qw(encode_base64);
use URI::Escape::XS qw/uri_escape/;

my $file = shift(@ARGV) or die 'Usage: tinylinkmap.pl FILENAME';

open my $info, $file or die "Could not open $file: $!";

while( my $line = <$info>)  {
    chomp $line;
    my @page = split("\t",$line);
	my $pageID = @page[0];
	my $spacekey = @page[1];
	my $title = @page[2];
	$pageID =~ s/^\s+|\s+$//g;

	my $tinyString = encode_base64(pack("L", $pageID)); ### the page ID must be encoded after converting it to a byte array
	my $actualTinyString = '';
	my $padding = 0;
	foreach my $c (split //, $tinyString)
	{
		if ($c eq '=')
		{ next; }
		if ($padding == 1 && $c eq 'A')
		{ next; }

		$padding = 0;
		if ($c eq '/')
		{
			$actualTinyString .= '-';
		}
		elsif ($c eq '+')
		{
			$actualTinyString .= '_';
		}
		elsif ($c eq "\n")
		{
			$actualTinyString .= '';
		}
		else
		{
			$actualTinyString .= $c;
		}
	}

    if ($title =~ m|[&/+%]|) {
        print $actualTinyString . "\t/wiki/search?text=" . uri_escape($title) . "\n";

# https://confluence.atlassian.com/confkb/the-differences-between-various-url-formats-for-a-confluence-page-278692715.html

    } else {
        $title =~ s/ /+/g;
        print $actualTinyString . "\t/wiki/display/" . $spacekey . "/" . uri_escape($title) . "\n";
    } 
}

close $info;
