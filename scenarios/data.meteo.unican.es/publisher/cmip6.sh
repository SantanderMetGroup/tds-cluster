#!/bin/bash

publisher="../../../publisher"

# ncmls
rm -rf ../ncmls/cmip6/*

dest="../ncmls/cmip6/{model}/{experiment}/{frequency}/{project}_{product}_{institution}_{model}_{experiment}_{ensemble}_{grid}_{frequency}.ncml"
root="/oceano/gmeteo/WORK/zequi/DATASETS/cmip6-esm-subset-day/data"
drs="project/product/institution/model/experiment/ensemble/frequency/variable/grid/version"
group="project,product,institution,model,experiment,ensemble,frequency,grid"

find ${root} -type f | python ${publisher}/ncml.py --project cmip6 --root ${root} --drs ${drs}  --group-spec ${group} --dest ${dest} 2> ncml.cmip6.err > ncml.cmip6.out

# catalogs
find ../ncmls/cmip6/ -type f | grep Amon | python ${publisher}/catalog.py --name 'IPCC AR6 Atlas, CMIP6 monthly data' --location 'content/cmip6' --path 'ipcc-ar6' --root ../ncmls/cmip6/ --template cmip6.xml.j2 > ../catalogs/ipcc-ar6/cmip6/cmip6Amon.xml
find ../ncmls/cmip6/ -type f | grep day |  python ${publisher}/catalog.py --name 'IPCC AR6 Atlas, CMIP6 daily data' --location 'content/cmip6' --path 'ipcc-ar6' --root ../ncmls/cmip6/ --template cmip6.xml.j2 > ../catalogs/ipcc-ar6/cmip6/cmip6day.xml
