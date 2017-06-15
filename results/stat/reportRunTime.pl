#!/usr/bin/env perl


$| = 1;

   
foreach my $pref (qw/ fs ts /) {

    foreach my $dir (glob "*-minScale*") {

        my %sgstat;

        my $scale = -1;
        my $ligand = "";
        if ($dir =~ m/m(\d+)-minScale-(.+)/) {
            $ligand = $1;
            $scale = $2 + 0.0;
        } else {
            die "cannot parse name of $dir\n";
        }

        print "Processing $dir, scale=$scale\n";

        my @all;
        foreach my $file (glob "$dir/$pref.*.stat") {
            print "Loading $file\r";
            open(my $fi,"<$file");
            my @lines = <$fi>;
            close $fi;
            chomp @lines;

            my @tmp;
            foreach my $l (@lines) {
                if ($l !~ m/^#/) {
                    push @tmp, $l;
                }
            }
            push @all, @tmp;

            if ($file =~ m/$pref.*\.sindex-(\d+)\.trial-(\d+)\./) {
                my $sgi = $1 + 0;
                my $trial = $2 + 0;
                if (not exists $sgstat{$sgi}) {
                    $sgstat{$sgi} = [];
                }       
                push @{ $sgstat{$sgi} }, @tmp;
            } else {
                print "Cannot parse of file: $file\n";
            }
        }

        $scale = int($scale*10);
        open(my $fo, ">$pref.stat.$ligand.$scale");
        foreach (@all) {
            print $fo "$_\n";
        }
        close $fo;
 
        foreach my $sgi (keys %sgstat) {
            open(my $fo, ">$pref.stat.$ligand.sgi-$sgi.scale-$scale");
            my @a = @{ $sgstat{$sgi} };
            foreach (@a) {
                print $fo "$_\n";
            }
            close $fo;
        }
        


    }

}



