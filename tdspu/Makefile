.PHONY: test clean

test:
	mkdir tmp
	cat one.ncml goodday.ncml irregular.ncml | \
			awk -F '"' '/location/{print $$2}'  | \
			python ncml.py --project cmip6 --root /oceano/gmeteo/WORK/zequi/DATASETS/cmip6-esm-subset-day/data/ --dest tmp/test_{model}_{experiment}_{frequency}.ncml
	find /oceano/gmeteo/WORK/zequi/DATASETS/cmip6-esm-subset-day/data/CMIP6/ScenarioMIP/IPSL/IPSL-CM6A-LR/ssp245/r2i1p1f1 -type f  | python ncml.py --project cmip6 --root /oceano/gmeteo/WORK/zequi/DATASETS/cmip6-esm-subset-day/data/ --dest tmp/test_{model}_{experiment}_{frequency}.ncml

clean:
	rm -rf tmp
