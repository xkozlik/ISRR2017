#!/usr/bin/env perl

my $suff = "jpg";
my @args = qw//;
if (@ARGV >= 1) {
    ($suff,@args) = @ARGV;
}

print "Suffix: $suff\n";
print "arguments: @args\n";

foreach my $in (glob "*.$suff") {
    my $new = $in;
    $new =~ s/$suff$/png/;
    print "convert $in @args $new\n";
    system "convert $in @args $new";
}
