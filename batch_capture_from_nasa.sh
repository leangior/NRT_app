#BATCH PARA CAPTURA DE DATOS NRT GLOBAL FLOOD MAPPING 
#dependencia (nasa_floodmap.pl)
#--
set -e
export PERL_LWP_SSL_VERIFY_HOSTNAME=0
#--
#PARAMETROS EN SITIO WEB CAPTURA (lista primero opt por defecto)
site=floodmap.modaps.eosdis.nasa.gov
app=getTile.php
declare -A prods=( ["flood_detection"]="3D3OT" ["flood_permanence"]="P14x3D3OT" )
declare -A codprods=( ["3D3OT"]="3" ["P14x3D3OT"]="14" )
declare -A layers=( ["3D3OT"]="MWP" ["P14x3D3OT"]="MSW,MFW")
product="flood_detection"
west="060W"
south="030S"
date="2018-03-01"
year=2018
output="temp/avaiable_flood_maps"
format=tif
codprod=${codprods[${prods[$product]}]}
while getopts "x:d:p:f:o:y:" option; do
  case $option in
    x ) west=$OPTARG
    ;;
    y ) south=$OPTARG  
    ;;
    d ) date=$OPTARG
    ;;
    p ) product=$OPTARG
    ;;
    f ) format=$OPTARG
    ;;
    o ) output=$OPTARG
    ;;
  esac
done
#--
#FUNCIONES
doy=$(echo "scale=0;1*$(date -d "$date" +%j)"|bc)
year=$(date -d "$date" +%Y)
function group
{
	for l in "$1"
	do 
		url="https://""$site""$l"
		echo "Capturando producto capa $2 layer $layer de día $date desde $url"
		if [ ! -d "temp/$layer" ]; then mkdir "temp/$layer"; fi 
		wget $url -P temp/$layer
	done
}
function get_layers
{
	layers=$(echo $1 | tr "," "\n")
	for layer in $layers
	do
		link=$(cat $output | grep ${prods[$product]} | grep $layer)
		group $link ${prods[$product]}
	done
	
}
#--
#Procedimiento (scrap)
parsapp="location="$west""$south"&day=$doy&year=$year&product=$codprod"
webservice="https://$site/$app?$parsapp"
if ! perl nasa_floodmap.pl $webservice ${prods[$product]} ${layers[${prods[$product]}]} $format $output; then echo "problema al intentar captura"; fi
get_layers ${layers[${prods[$product]}]} 
rm $output
#--
