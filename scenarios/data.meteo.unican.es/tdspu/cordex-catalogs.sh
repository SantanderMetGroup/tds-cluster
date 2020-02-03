#!/bin/bash

tdspu="publisher"
catalogs="./catalogs/ipcc/cordex"
ncmls="../ncmls/cordex"

domains=$(find ${ncmls}/* -not -path '*/\.*' -type d | awk -F"/" '{print $4}' | sort -u)
frequencies=$(find ${ncmls}/* -not -path '*/\.*' -type d | awk -F"/" '{print $5}' | sort -u)

for d in $domains
do
	for f in $frequencies
	do
		if [ -d "${ncmls}/${d}/${f}" ]
		then
			mkdir -p "${catalogs}/${d}/${f}"
			ncmls_dir="${ncmls}/${d}/${f}"
			find "${ncmls_dir}" -mindepth 2 -type f -name '*.ncml' | \
				python ${tdspu}/catalog.py --name "IPCC CORDEX ${d} ${f}" --location 'content/cordex' --path 'ipcc/cordex' --root "${ncmls}" --template catalog.xml.j2 > "${catalogs}/${d}/${f}/catalog.xml"
		fi
	done
done

main_catalog="catalogs/catalog.xml"
cat >${main_catalog} << EOF
<catalog xmlns="http://www.unidata.ucar.edu/namespaces/thredds/InvCatalog/v1.0"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xsi:schemaLocation="http://www.unidata.ucar.edu/namespaces/thredds/InvCatalog/v1.0 http://www.unidata.ucar.edu/schemas/thredds/InvCatalog.1.0.6.xsd"
     xmlns:xlink="http://www.w3.org/1999/xlink"
     name="IPCC CORDEX">

	<datasetRoot path="ipcc/cordex" location="content/cordex" />
EOF

for c in $(find ${main_catalog%/*} -mindepth 2 -type f -printf '%P\n'|sort)
do
	echo -e "\t<catalogRef xlink:title=\"$(echo $c|awk -F'/' '{print $3,$4}')\" xlink:href=\"${c}\" name=\"\" />" >>${main_catalog}
done

echo "</catalog>" >>${main_catalog}
