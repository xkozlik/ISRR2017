#!/usr/bin/env perl


$| = 1;

BEGIN { push @INC, "/home/vojta/work/rrtPlanning/scripts"; }
use CStat;
use Storable;

my %names;

$names{"003"} = "\\LA";
$names{"004"} = "\\LB";


my $DTG = 1.5;


my %h;

my @cols = qw/ rrt_path_function_time rrt_path_time trajDistToGoal treeSize warmUpTime /;

my $hashfile = "h.hash";


my $processData = 0;


if ($processData == 1) {


    foreach my $tunnel (glob "output/tun*") {

        foreach my $scaledir (glob "$tunnel/m003-*") {
            print "Processing $scaledir\n";

            my $scale = 0;
            if ($scaledir =~ m/m003-minScale-(.*)/) {
                $scale = $1 + 0;
            } else {
                die "Cannot parse name of scaledir $scaledir\n";
            }

            foreach my $f (glob "$scaledir/ts.*.stat") {

                my $sindex;
                my $trial;
                if ($f =~ m/ts\.m003\.sindex-(\d+)\.trial-(\d+)\.stat/) {
                    $sindex = $1 + 0;
                    $trial = $2 + 0; 
                } else {
                    die "Cannot interpret file name $f\n";
                }

#print "Processing $f\r";

                my ($ddr, $length) = loadStatFileToHash($f);
                print "Loaded $length from $f\r";

                foreach my $col (@cols) {
                    my @a = @{ $ddr->{$col} };
                    if (not exists $h{$tunnel}{$scale}{$sindex}{$col}{$trial}) {
                        $h{$tunnel}{$scale}{$sindex}{$col}{$trial} = [];
                    }

                    push @{ $h{$tunnel}{$scale}{$sindex}{$col}{$trial} }, @a;
                }
            }
        }
    }

    store \%h, $hashfile;

} else  {
    my $href = retrieve $hashfile; 
    %h = %{ $href };
}



my %stat;

#normalize runtimes
foreach my $tunnel (keys %h) {
    foreach my $scale (keys %{ $h{$tunnel} }) {

        foreach my $sindex (keys %{ $h{$tunnel}{$scale} }) {
            
            my @wt;
            my @rt;
            foreach my $trial (keys %{ $h{$tunnel}{$scale}{$sindex}{"rrt_path_function_time"} } ) {
                my @aa = @{ $h{$tunnel}{$scale}{$sindex}{"warmUpTime"}{$trial} };
                die "empty array1 " if @aa == 0;
                push @wt, $aa[0];

                my @aa = @{ $h{$tunnel}{$scale}{$sindex}{"rrt_path_function_time"}{$trial} };
                die "empty array2 " if @aa == 0;
                push @rt, $aa[0];
            }

            my $min = -1;
            for(my $i=0;$i < @wt; $i++) {
                if ($wt[$i] < $min or $min == -1) {
                    $min = $wt[$i];
                }
            }
            die "Not same lengths! " if (@wt != @rt);

            my @normalized;
            for(my $i=0;$i < @wt; $i++) {
                my $factor = $wt[$i] / $min;
                my $newtime = $rt[$i] / $factor;
                push @normalized, $newtime;
            }
            
            my ($min, $max, $mean, $dev, $med, $p5, $p95) = getArrayStat(\@rt);
            print "$tunnel:$scale:$sindex: loaded: $mean ($dev)\n";
            my ($min, $max, $mean, $dev, $med, $p5, $p95) = getArrayStat(\@normalized);
            print "$tunnel:$scale:$sindex: normalized: $mean ($dev)\n";

            foreach my $col (keys %{ $h{$tunnel}{$scale}{$sindex} } ) {
                my @values;

                foreach my $trial (keys %{ $h{$tunnel}{$scale}{$sindex}{$col} } ) {
#                    print "tr: $trial ";
                    my @aa = @{ $h{$tunnel}{$scale}{$sindex}{$col}{$trial} };
                    die "Empty array3 " if @aa == 0;
                    push @values, $aa[0]; #we assume that only one measurement per line
                }
                print "Values for $col is " . @values . " long\n";

                if ($col ne "rrt_path_function_time") {

                    print "1";
                    my ($min, $max, $mean, $dev, $med, $p5, $p95) = getArrayStat(\@values);
                    $stat{$tunnel}{$scale}{$col}{$sindex} = [ $mean , $dev ];
                } else {
                    print "2";
                    my ($min, $max, $mean, $dev, $med, $p5, $p95) = getArrayStat(\@normalized);
                    $stat{$tunnel}{$scale}{$col}{$sindex} = [ $mean , $dev ];
                }
                if ($col eq "trajDistToGoal") {
                    my $sr = 0;
                    foreach (@values) {
                        if ($_ <= $DTG) {
                            $sr++;
                        }
                    };
                    $sr = 100.0*$sr / @values;
                    $stat{$tunnel}{$scale}{"sr"}{$sindex} = [ $sr, 0 ];
                }
            }
            foreach my $col (keys %{ $stat{$tunnel}{$scale} } ) {
                    
                my @aa = @{ $stat{$tunnel}{$scale}{$col}{$sindex} };
                print "$tunnel $scale $sindex $col: @aa\n";
            }
        }
    }
}



my $out = "resm";    
open(my $fo,">$out.tex");

foreach my $tunnel (keys %h) {
    foreach my $scale (sort {$a <=> $b} keys %{ $h{$tunnel} }) {
        print $fo "tunnel $tunnel, scale $scale\n";

        foreach my $col (keys %{ $stat{$tunnel}{$scale} }) {

            my @means;
            foreach my $sindex (keys %{ $stat{$tunnel}{$scale}{$col} }) {
                my ($mean, $dev) = @{ $stat{$tunnel}{$scale}{$col}{$sindex} };
                push @means, $mean;
            }


                    
            my ($min, $max, $mean, $dev, $med, $p5, $p95) = getArrayStat(\@means);

            print $fo "$col: $mean, $dev\n";
        }
        print $fo "\n";
    }
}
close $fo;




