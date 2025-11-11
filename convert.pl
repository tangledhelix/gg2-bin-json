#!/usr/bin/env perl
#
# Import a Guiguts 1 .bin file and output a Guiguts 2 .json

use JSON;

unless (scalar @ARGV >= 1) {
    print "Missing argument: input_filename\n";
    exit(1);
}

my $fname = $ARGV[0];
unless (-f $fname) {
    print "Not a file: $fname\n";
    exit(1);
}

unless ($fname =~ m/\.bin$/) {
    print "Input file must be a .bin file\n";
    exit(1);
}

# To use require we can't pass a bare filename; if that's all we have, then
# prefix the current directory to it.
unless ($fname =~ m|/| or $fname =~ m|\\|) {
    if ($^O eq 'MSWin32') {
        $fname = ".\\$fname";
    } else {
        $fname = "./$fname";
    }
}
require $fname;

my $jname = $fname;
$jname =~ s/\.bin$/.json/;

my $jdata = {
  'languages' => $::booklang,
  'pagedetails' => {}
};

for (keys %::pagenumbers) {
    $jdata->{pagedetails}->{$_} = {
        index  => $::pagenumbers{$_}{offset},
        style  => $::pagenumbers{$_}{style},
        number => $::pagenumbers{$_}{action},
        label  => $::pagenumbers{$_}{label}
    };
}

open(FH, '>', $jname) or die $!;
print FH JSON->new->canonical->pretty->encode($jdata);
close(FH);

print "converted file: $jname\n";
