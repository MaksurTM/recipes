#!/usr/bin/make -f
MD_FILES=$(wildcard src/*.md)
TEMPLATES=$(wildcard templates/*.html)
RECIP=$(wildcard recipes/*.html)
RECIPE=$(notdir $(RECIP))
RECIPES=$(basename $(RECIPE))
TAG_FILES = $(patsubst src/%.md,tags/%,$(MD_FILES))
TAGS=$(shell cat $(TAG_FILES) | sort)

.PHONY: variables
variables:
	@echo MD_FILES: $(MD_FILES)
	@echo TEMPLATES: $(TEMPLATES)
	@echo RECIPES: $(RECIPES)
	@echo TAG_FILES: $(TAG_FILES)
	@echo TAGS: $(TAGS)

build: index.html tagged.html about.html $(patsubst src/%.md,recipes/%.html,$(MD_FILES))

about.html: data/about.md
	envsubst < templates/_headerindex.html >> $@; \
        pandoc -f markdown -t html "$<" | envsubst >> $@; \
	envsubst < templates/_footerindex.html >> $@; \

tagged.html: $(patsubst src/%.md,tags/%,$(MD_FILES)) $(TAG_FILES) $(patsubst %,tagpages/%.html,$(TAGS))
	envsubst < templates/_headerindex.html > $@; \
	printf "<h1> Tags </h1>\n" >> $@; \
	printf "<h2> All Tags </h2>\n" >> $@; \
	printf "<ul>\n" >> $@; \
        for t in $(shell cat $(TAG_FILES) | sort -u); do \
		printf '%s \n' "<li> <a href=tagpages/$$t.html>$$t</a> </li>" ; \
        done >> $@; \
	printf "</ul>\n" >> $@; \
	envsubst < templates/_footerindex.html >> $@; \

tagpages/%.html:
	envsubst < templates/_header.html > $@; \
	printf "<h1> tags/$* </h1>\n" >> $@; \
	printf "<h2> $* </h2>\n" >> $@; \
	printf "<ul>\n" >> $@; \
	for f in $(shell grep -l "^;;.*tags.*:.*$*.*" src/* | sed 's/src\///g' | sed 's/.md//'); do \
                printf '%s \n' "<li><a href=../recipes/$$f.html>$$f</a></li>"; \
        done >> $@; \
	printf "</ul>\n" >> $@; \
        envsubst < templates/_footer.html >> $@; \

tags/%: src/%.md
	mkdir -p tags; \
	grep -i '^;; *tags:' "$<" | cut -d: -f2- | sed 's/  */\n/g' | sed '/^$$/d' | sort -u > $@

index.html:
	envsubst < templates/_headerindex.html > $@; \
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
	rm recipes/*.html tags/* tagpages/* index.html tagged.html about.html
