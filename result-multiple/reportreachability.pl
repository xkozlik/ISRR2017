#!/usr/bin/env perl


my $DTG = 1.1;

foreach my $tun (1..4) {
    

    my $caver = "ca-tunnels/tun.$tun.txt";
    open(my $fi, "<$caver") or die "Cannot open caver tunnel: $caver: $!\n";
    my @calines = <$fi>;
    close $fi;
    chomp @calines;

    my @ca;
    for(my $i = 0; $i < @calines; $i++) {
        my ($x, $y, $z) = split(/\s+/, $calines[$i]);
        push @ca, [$x, $y, $z];
    }
    print "Loaded " .  @ca . " tunnel points from $caver\n";


    foreach my $scaledir (glob "output/tun-$tun/*") {
        if ($scaledir =~ m/m003-minScale-(.*)/) {
            my %reached;
            my $scale = $1 + 0;

            my $total = 0;

            foreach my $tfile (glob "$scaledir/*.txt") {

                open(my $fi, "<$tfile");
                my @data = <$fi>;
                close $data;

                my @pts;
                for(my $i=0;$i < @data; $i++) {
                    my ($x, $y, $z, @rest) = split(/\s+/,$data[$i]);
                    push @pts, [$x, $y, $z];
                }
                print "Loading $tfile, " . @pts . " points\n";

                my $res = reportReachability(\@ca, \@pts);

                for(my $i=0; $i <= $res; $i++) {
                    $reached{$i}++;
                }
                $total++;
            }

            open(my $fo,">reached.tun-$tun.scale-$scale.txt");
            print $fo "#reached reached/total\n";
            foreach my $i (sort {$a <=> $b} keys %reached) {
                print $fo "$i " . $reached{$i} . " " . 1.0*$reached{$i} / $total . "\n";
            }
            close $fo;



        } else {
            die "Cannot parse of name dir $scaledir: $!\n";
        }
    }

    }


sub reportReachability {
    my ($caref, $ptsref) = @_;


    my $res = -1;

    for(my $i = 0; $i < @{ $caref }; $i++) {
        
        #find nearest in the trajectory. If less then DTG, this one is reached

        for(my $j=0;$j < @{ $ptsref }; $j++) {
            my ($x, $y, $z) = @{ $ptsref->[$j] };
            my $dx = $x - $caref->[$i][0];
            my $dy = $y - $caref->[$i][1];
            my $dz = $z - $caref->[$i][2];
#print "diff: $dx $dy $dz, $x $y $z\n";
            my $d = $dx*$dx + $dy*$dy + $dz*$dz;

            if ($d <= $DTG*$DTG) {
                $res = $i;
                $j = @{ $ptsref } + 10; #to end the loop
            }
        }
    }
    return $res; #index of last point that was reached

}





