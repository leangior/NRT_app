#!/usr/bin/perl
#Módulo Parser para descarga de productos del sitio NRT MODIS Global FLood Mapping. Devuelve vínculo de producto situado en servidor http NASA. 
use warnings;
use strict;
use WWW::Mechanize;
#--
#Parámetros
my $webservice=$ARGV[0];
my $product=$ARGV[1];
my $layers=$ARGV[2];
my $format=$ARGV[3];
my $out=$ARGV[4];
my $web = WWW::Mechanize->new();
#--
#Procedimiento
$web->get($webservice);
my @links=$web->find_all_links(url_regex => qr/$format/i);
if (@links)
{
	open(my $a,">$out");
	for my $link ( @links ) {printf $a ("%s\n",$link->url);}
	close($a);
}
#--
