#!/bin/bash

rm -rf ../ncmls/cmip6/*

dest="../ncmls/cmip6/{model}/{experiment}/{frequency}/{project}_{product}_{institution}_{model}_{experiment}_{ensemble}_{grid}_{frequency}.ncml"
root="/oceano/gmeteo/WORK/zequi/DATASETS/cmip6-esm-subset-day/data"
drs="project/product/institution/model/experiment/ensemble/frequency/variable/grid/version"
group="project,product,institution,model,experiment,ensemble,frequency,grid,version"

python ../../../tdspu/ncml.py --project cmip6 --root ${root} --drs ${drs}  --group-spec ${group} --dest ${dest} 2> ncml.cmip6.err | tee ncml.cmip6.out
