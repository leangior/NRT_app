#!/usr/bin/env bash
set -e
#---
#Algoritmo para la implementación de modelos de datos INA en producción de series agregadas espacialmente, distribuidas temporalmente. La implementación particular aquí presentada corresponde a la dependencia funcional de la rutina automática de generación de saturogramas sobre la base de NRT GLOBAL FLODD MAPPING.  
#Desarrollo: Área de Sensores Remotos y SIG, DSIyAH-INA, 2018. 
#--
#Estructura de modelo de datos INA [producción sobre la base de procesamiento de rasters] (esquemas y relaciones)
dbname=${1-"areal_data_model"} #nombre de base de datos (opcional). Abajo se listan tablas, campos y relaciones.
declare -A tablas=( [fuentes]=fuentes [series_areal]=series_areal [observaciones_areal]=obs_areal [valores_areal]=valores_num_areal [variables]=var [unidades]=unidades [procedimientos]=procedimientos [nodos]=nodos [tipos]=tipos [entidades]=entidades [nrt]=nrt_global_floodmap)
declare -A campos=( [fuentes]="(id serial primary key, tipo varchar, nombre varchar)" [series_areal]="(id serial primary key,unid int references ${tablas[nodos]}(unid),var_id int references ${tablas[variables]}(id),unit_id int references ${tablas[unidades]}(id), proc_id int references ${tablas[procedimientos]}(id), fuentes_id int references ${tablas[fuentes]}(id), UNIQUE (unid,var_id,unit_id,proc_id,fuentes_id))" [observaciones_areal]="(id serial primary key, series_id int references ${tablas[series_areal]}(id), timestart timestamp not null, timeend timestamp not null, UNIQUE (series_id,timestart,timeend))" [valores_areal]="(obs_id int references ${tablas[observaciones_areal]}(id), valor real not null)" [variables]="(id serial primary key,nombre varchar)" [unidades]="(id serial primary key,nombre varchar)" [procedimientos]="(id serial primary key,nombre varchar)" [nodos]="(unid serial primary key, tipo int references ${tablas[tipos]}(id), entidad int references ${tablas[entidades]}(id), geom geometry)" [tipos]="(id serial primary key,nombre varchar)" [entidades]="(id serial primary key,nombre varchar)" [nrt]="(time date,rast raster)")
#--
#Funciones
function create_postgis_db
{
	#a. Declara nueva base de datos
	createdb $dbname
	#b. Invoca y actualiza POSTGIS (revisar updates en https://postgis.net/install/)
	echo "CREATE EXTENSION postgis" | psql $dbname 
	echo "CREATE EXTENSION postgis_topology" | psql $dbname
	echo "CREATE EXTENSION fuzzystrmatch" | psql $dbname
	echo "CREATE EXTENSION address_standardizer" | psql $dbname
	echo "ALTER EXTENSION postgis UPDATE" | psql $dbname
	echo "ALTER EXTENSION postgis_topology UPDATE" | psql $dbname
}
function create_table
{
	echo "creando tabla ${tablas[$1]} en $db"
	echo "BEGIN; create table ${tablas[$1]} ${campos[$1]}; COMMIT" | psql $dbname
}
#--
#Procedimiento
#a. Declara Base de Datos PSQL e invoca POSTGIS
create_postgis_db
#b. Crea tablas e impone relaciones (claves, restricciones)
create_table fuentes
create_table variables
create_table unidades
create_table procedimientos
create_table entidades
create_table tipos
create_table nodos
create_table series_areal
create_table observaciones_areal
create_table valores_areal
create_table nrt
#---
#ÚLTIMA REVISIÓN LMG 8/2018

