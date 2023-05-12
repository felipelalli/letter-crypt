#!/usr/bin/perl

use strict;
use warnings;
use Math::BigInt;

# Função para converter de hexadecimal para base36
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

# Função para converter de base36 para hexadecimal
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
    $hex =~ s/^0x//i; # Remove o "0x" do início do número hexadecimal
    return lc($hex);
}

# Obtém o parâmetro passado via linha de comando
my $input = $ARGV[0];

# Verifica se o parâmetro foi fornecido
if (defined $input) {
    # Verifica se o parâmetro é um número hexadecimal
    if ($input =~ /^[0-9A-Fa-f]+$/) {
        my $base36 = hex_to_base36($input);
        print "$base36\n";
    }
    # Verifica se o parâmetro é um número em base36
    elsif ($input =~ /^[0-9A-Za-z]+$/) {
        my $hex = base36_to_hex($input);
        print "$hex\n";
    }
    else {
        print "Formato inválido. Forneça um número hexadecimal ou base36.\n";
    }
}
else {
    print "Nenhum parâmetro fornecido. Forneça um número hexadecimal ou base36.\n";
}
