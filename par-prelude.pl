BEGIN {
  if (defined &PAR::read_file) {
    my $src = PAR::read_file('script/latexdiff-so');
    $src =~ s/\A.*?^__(?:END|DATA)__\r?\n//ms
      or die "no data section found in packed script\n";
    open(DATA, '<', \$src) or die "cannot open DATA: $!";
  }
}
