include default.mk
-include custom.mk

all: main-dict $(foreach std,$(char-standards),jianma-$(std))

build:
	mkdir $@

main-dict: build
	python mb-tool/zm_dict.py zg-code/$(zg-code).tsv jz-scheme/$(jz-scheme)/main.tsv -r $(rules) > build/main.tsv

jianma-%: build
	python mb-tool/zm_dict.py zg-code/$(zg-code).tsv jz-scheme/$(jz-scheme)/common-$*.tsv -r $(rules) | \
		python mb-tool/jianma-gen.py $(jm-methods) --freq-table $(char-freq-$(*)) > build/jianma-$*.tsv

clean:
	rm build/*
