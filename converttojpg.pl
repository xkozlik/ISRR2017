#!/usr/bin/env perl

foreach my $f (glob "*.png") {
    print "Converting $f .. ";
    my $nf = $f;
    $nf =~ s/png$/jpg/g;
    print "convert $f $nf\n";
    system "convert $f -background white -flatten -alpha off $nf\n";
}
