#!/usr/bin/perl

use strict;
use warnings;
use Math::BigInt;

# Function to convert from hexadecimal to base36
sub hex_to_base36 {
    my ($hex) = @_;
    my $bigint = Math::BigInt->from_hex($hex);
    my @digits = ('0'..'9', 'a'..'z');
    my $base36 = '';

    if ($hex eq '0') {
        return '0';
    }

    while ($bigint > 0) {
        my $remainder = $bigint % 36;
        $base36 = $digits[$remainder] . $base36;
        $bigint = $bigint / 36;
    }

    return lc($base36);
}

# Function to convert from base36 to hexadecimal
sub base36_to_hex {
    my ($base36) = @_;
    my $bigint = Math::BigInt->new(0);
    my @digits = ('0'..'9', 'a'..'z');

    if ($base36 eq '0') {
        return '0';
    }

    for (my $i = 0; $i < length($base36); $i++) {
        my $digit = substr($base36, $i, 1);
        my $value = index(join('', @digits), lc($digit));
        $bigint = $bigint * 36 + $value;
    }

    my $hex = $bigint->as_hex();
    $hex =~ s/^0x//i; # Remove the "0x" from the start of the hexadecimal number
    return lc($hex);
}

# Get the parameter passed via command line
my $input = $ARGV[0];

# Check if the parameter was supplied
if (defined $input) {
    # Check if the parameter is a hexadecimal number
    if ($input =~ /^[0-9A-Fa-f]+$/) {
        my $base36 = hex_to_base36($input);
        print "$base36\n";
    }
    # Check if the parameter is a base36 number
    elsif ($input =~ /^[0-9A-Za-z]+$/) {
        my $hex = base36_to_hex($input);
        print "$hex\n";
    }
    else {
        print "Invalid format. Please provide a hexadecimal or base36 number.\n";
    }
}
else {
    print "No parameter supplied. Please provide a hexadecimal or base36 number.\n";
}
