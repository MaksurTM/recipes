#!/usr/bin/make -f
MD_FILES=$(wildcard src/*.md)
TEMPLATES=$(wildcard templates/*.html)
RECIP=$(wildcard recipes/*.html)
RECIPE=$(notdir $(RECIP))
RECIPES=$(basename $(RECIPE))

.PHONY: variables
variables:
	@echo MD_FILES: $(MD_FILES)
	@echo TEMPLATES: $(TEMPLATES)
	@echo RECIPES: $(RECIPES)

build: index.html about.html $(patsubst src/%.md,recipes/%.html,$(MD_FILES))

about.html: data/about.md
	envsubst < templates/_headerindex.html >> $@; \
        pandoc -f markdown -t html "$<" | envsubst >> $@; \
	envsubst < templates/_footerindex.html >> $@; \

index.html:
	envsubst < templates/_headerindex.html >> $@; \
	printf "<h1> Recipe Index </h1>" >> $@; \
	printf "<h2> All Recipes </h2>" >> $@; \
	printf "<ul>" >> $@; \
	for f in $(shell echo $(RECIPES) | sort) ; do \
		printf '%s \n' "<li>" "<a href=recipes/$$f.html>$$f</a>" "</li>" ; \
	done >> $@; \
	printf "</ul>" >> $@; \
	envsubst < templates/_footerindex.html >> $@; \

recipes/%.html: src/%.md
	envsubst < templates/_header.html > $@; \
        pandoc -f markdown -t html "$<" | envsubst >> $@; \
        envsubst < templates/_footer.html >> $@; \

clean:
	rm recipes/*.html
