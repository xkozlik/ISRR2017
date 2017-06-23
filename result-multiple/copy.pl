#!/usr/bin/env perl

my $outdir = "output-trajOnly";

foreach my $td (glob "output/tun-*") {


    print "Processing $td\n";

    foreach my $tf (glob "$td/*") {
    
        my $od = $tf;
        $od =~ s/^output/$outdir/;
        system  "mkdir -p $od";

        foreach my $tf2 (glob "$tf/*.traj.00.txt") {

            if ($tf2 =~ m/sindex-(\d+).trial-(\d+)/) {
                my $sindex = $1 + 0;
                my $trial = $2 + 0;
                if ($sindex < 50 and $trial < 20) {
                    print "cp $tf2 $od/\n";
                    system "cp $tf2 $od/";
                }
            }
        }
    }
}

