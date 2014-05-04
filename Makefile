GENERATED_FILES = \
	districts.json

all: $(GENERATED_FILES)

build/us-judicial-districts.shp:
	mkdir -p $(basename $@)
	tar -xvzf us-judicial-districts.zip -C $(basename $@)

us-judicial-districts.json: build/us-judicial-districts.shp
	node_modules/.bin/topojson \
		-o $@ \
		--no-pre-quantization \
		--post-quantization=1e6 \
		--simplify=7e-7 \
		-p jdcode=+JDCODE,state=State \
		--id-property=+FIPS \
		-- districts=build/us-judicial-districts/US_Judicial_Districts.shp
