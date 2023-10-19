use strict;
use warnings;

use Test::More;
use DBI;
use lib 't', '.';
require 'lib.pl';

foreach my $compression ( "zlib", "zstd", "0", "1" ) {
  my ($dbh, $sth, $row);
  use vars qw($test_dsn $test_user $test_password);
  
  eval {$dbh = DBI->connect($test_dsn . ";mysql_compression=$compression", $test_user, $test_password,
      { RaiseError => 1, AutoCommit => 1});};
  
  ok ($sth= $dbh->prepare("SHOW SESSION STATUS LIKE 'Compression_algorithm'"));
  
  ok $sth->execute();
  
  ok ($row= $sth->fetchrow_arrayref);

  my $exp = $compression;
  if ($exp eq "1") { $exp = "zlib" };
  if ($exp eq "0") { $exp = "" };
  cmp_ok $row->[1], 'eq', $exp, "\$row->[1] eq $exp";
  
  ok $sth->finish;
}

plan tests => 4*5;
