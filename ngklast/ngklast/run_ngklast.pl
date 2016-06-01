#!/usr/bin/perl
use strict;
use warnings;




# Running NGKLAST
my $cmd_line = "";
my $html_path = $ARGV[-2];



foreach my $element (@ARGV){
	if($element ne $ARGV[-1] and $element ne $ARGV[-2]){
		$cmd_line=$cmd_line.$element." ";
	}
}



system("mkdir -p $ARGV[-1]");

system("$cmd_line");

system("cp -r $ARGV[-5] $ARGV[-1]/");

my @PathINArray = split("/", $ARGV[-5]);

# Writting Html OUTPUT
open(my $fhHtml, ">", $html_path);
print $fhHtml "<html>\n";
print $fhHtml "<title> Results </title>\n";

print $fhHtml "<script type=\"text/javascript\">\n
   		function bonjour(){\n
   		alert('bonjour a tous');\n
   		}\n
   		</script>\n";


print $fhHtml "<body>\n";

print $fhHtml "<h1> About nglkast </h1>\n";

print $fhHtml "<button onclick='bonjour()'>click</button>\n";


print $fhHtml "<a href=\"$PathINArray[-1]\">Some special output</a>\n";
print $fhHtml "$ARGV[-1]\n";
print $fhHtml "$PathINArray[-1]\n";

print $fhHtml "$ARGV[3]\n";


print $fhHtml "</body>\n";
print $fhHtml "</html>\n";
close($fhHtml);





