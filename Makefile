GENERATED_FILES = \
	districts.json

all: $(GENERATED_FILES)

build/judicial-districts.shp:
	rm -rf $(basename $@)
	mkdir -p $(basename $@)
	tar -xzm -C build -f ./build/judicial-districts.tar.gz
	for file in $(basename $@)/*; do chmod 644 $$file; mv $$file $(basename $@).$${file##*.}; done
	rmdir $(basename $@)

# build/us-judicial-districts.shp:
# 	mkdir -p $(basename $@)
# 	tar -xvzf us-judicial-districts.zip -C $(basename $@)

build/counties-ungrouped.json: build/judicial-districts.shp
	node_modules/.bin/topojson \
		-o $@ \
		--no-pre-quantization \
		--post-quantization=1e6 \
		--simplify=7e-7 \
		-p jdcode=+JDCODE,state=State \
		--id-property=+FIPS \
		-- counties=build/judicial-districts.shp

# group polygons into multipolygons
build/counties.json: build/counties-ungrouped.json
	node_modules/.bin/topojson-group \
		-o $@ \
		-- build/counties-ungrouped.json

build/districts.json: build/counties.json
	node_modules/.bin/topojson-merge \
		-o $@ \
		--in-object=counties \
		--out-object=districts \
		--key='d.jscode' \
		-- build/counties.json

us.json: build/districts.json
	node_modules/.bin/topojson-merge \
		-o $@ \
		--in-object=districts \
		--out-object=nation \
		--no-key \
		-- build/districts.json
