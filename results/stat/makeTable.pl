#!/usr/bin/env perl


$| = 1;

BEGIN { push @INC, "/home/vojta/work/rrtPlanning/scripts"; }
use CStat;

my %names;

$names{"003"} = "\\LA";
$names{"004"} = "\\LB";


my $dtg = 1;
my $dtg2 = 3;


my %hh;

foreach my $pref (qw/ ts fs /) {

    my %h;

    foreach my $f (glob "$pref.stat.*") {

        my $lig, $scale;
        if ($f =~ m/stat\.(.*)\.(\d+)/) {
            $lig = $1 ;
            $scale = $2 + 0;
        } else {
            print "Cannot parse file name $f\n";
        }

        my ($ddr, $length) = loadStatFileToHash($f);
        print "Loaded $length from $f\n";

        $h{$lig}{$scale}{"len"} = [$length , 0 ];

        my ($min, $max, $mean, $dev, $med, @rest) = getArrayStatByName($ddr,"rrt_path_time");
        print "time: $f: @a, mean=$mean : $dev\n";

        $h{$lig}{$scale}{"time"} = [$mean , $dev ];

        my ($min, $max, $mean, $dev, $med, @rest) = getArrayStatByName($ddr,"trajDistToGoal");
        print "dist: $f: @a, mean=$mean : $dev\n";

        $h{$lig}{$scale}{"dtg"} = [$mean , $dev ];


        if ($pref eq "ts") {
            my ($min, $max, $mean, $dev, $med, @rest) = getArrayStatByName($ddr,"treeSize");
            print "dist: $f: @a, mean=$mean : $dev\n";

            $h{$lig}{$scale}{"ts"} = [$mean , $dev ];
        }


        my @a = getArrayByName($ddr, "trajDistToGoal");

        my $cnt = 0;
        my $cnt2 = 0;
        foreach my $d (@a) {
            if ($d <= $dtg) {
                $cnt++;
            }
            if ($d <= $dtg2) {
                $cnt2++;
            }
        }
        my $sr = 100.0*$cnt/@a;
        my $sr2 = 100.0*$cnt2/@a;
        print "$f: SR=$sr\n";

        $h{$lig}{$scale}{"sra"} = [$sr , 0];
        $h{$lig}{$scale}{"srb"} = [$sr2 , 0];
    }

    $hh{$pref} = \%h;

    if ($pref eq "fs") {
        #load stat for each start/goal
        foreach my $f (glob "$pref.stat.*.sgi*") {
        
            my ($ddr, $length) = loadStatFileToHash($f);

            if ($f =~ m/$pref\.stat\.(.*)\.sgi-(.+)\.scale-(\d+)/) {
                my $ligand = $1;
                my $sgi = $2 + 0;
                my $scale = $3 + 0;
                print "$f: ligand=$ligand, scale=$scale, sgi=$sgi!\n";

                my @a = getArrayByName($ddr, "trajDistToGoal");

                my $cnt = 0;
                foreach my $d (@a) {
                    if ($d <= $dtg) {
                        $cnt++;
                    }
                }
                $SR{$ligand}{$scale}{$sgi} = 100.0*$cnt / @a;
                print "Ligand: $ligand: $sgi: $SR{$ligand}{$scale}{$sgi}\n";


            } else {
                print "Cannot parse name of $f!\n";
            }
            
        }

    }

}

my %h = %{ $hh{"fs"} };
foreach my $lig (keys %h) {

    open(my $fo,">table.$lig.tex");
    print $fo "% geenerated by $0\n";
    print $fo "\\begin{tabular}{lcccc}\n";
    print $fo "\\toprule\n";
    print $fo "{\\bf Scale} & {\\bf Runtime [s] } & {\\bf Success rate} & {\\bf Tree}\\\\ \n";
    print $fo "{\$\\smin\$ }  & avg. (std.)       & min/max/avg & {\\bf size } \\\\ \n";
    print $fo "\\midrule\n";
    print $fo "\\multicolumn{2}{l}{\$ $names{$lig} \$} \\\\ \n ";
    my %hhts = %{ $hh{"ts"} };

    foreach my $s (sort {$a <=> $b} keys %{ $h{$lig} }) {
        my $scale = $s/10.;
        if ($scale < 0.7) {
            
            my ($mean, $dev) = @{ $h{$lig}{$s}{"len"} };
            print $fo "%data length: $mean\n";


            print $fo "$scale & ";

            my ($mean, $dev) = @{ $h{$lig}{$s}{"time"} };
            $mean = sprintf("%.2f", $mean);
            $dev = sprintf("%.2f", $dev);
            print $fo "$mean ($dev) & ";

            { #determine min, mean and max sr
                my $min = -1;
                my $mean= 0;
                my $max = 0;
                my $cnt++;
                foreach my $sgi (keys %{ $SR{$lig}{$s} }) {
                    my $sr = $SR{$lig}{$s}{$sgi};
                    if ($sr < $min or $min == -1) {
                        $min = $sr;
                    }
                    $mean += $sr;
                    if ($sr >= $max or $max == -1) {
                        $max = $sr;
                    }
                    $cnt++;
                }
                $mean /= 1.0*$cnt;
                $mean = sprintf("%.1f", $mean);
                print $fo "$min/$max/$mean & ";
            }

#            my ($mean, $dev) = @{ $h{$lig}{$s}{"sra"} };
#            $mean = sprintf("%2.1f", $mean);
#            print $fo "$mean  & ";

            my ($mean, $dev) = @{ $hhts{$lig}{$s}{"ts"} };
            $mean = sprintf("%2d", $mean/1000);
            print $fo "${mean}k  ";
            
            print $fo "\\\\\n";
        }
    }
    print $fo "\\bottomrule\n";
    print $fo "\\end{tabular}\n";
    close $fo;
}






