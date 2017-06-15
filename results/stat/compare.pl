#!/usr/bin/env perl


$| = 1;

foreach my $prefix (qw/ fs fsexp2 /) {
    foreach my $dir (glob "*-minScale*") {
        print "Processing $dir\n";

        my @all;
        foreach my $file (glob "$dir/$prefix.*.stat") {
            open(my $fi,"<$file");
            my @lines = <$fi>;
            close $fi;
            chomp @lines;

            foreach my $l (@lines) {
                if ($l !~ m/^#/) {
                    print "Orig: '$l'\n";
                    $l =~ s/;/ /g;
                    $l =~ s/=/ /g;
                    print "New: '$l'\n";
                    my @a = split(/\s+/,$l);
                    push @all, "$a[1], $a[3]";
                }
            }

        }
        open(my $fo,">$dir/aa.$prefix");
        foreach (@all) {
            print $fo "$_\n";
        }
        close $fo;
    }
}
