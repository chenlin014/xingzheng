include default.mk
-include custom.mk

all: main-dict $(foreach std,$(char-standards),jianma-$(std))

build:
	mkdir $@

main-dict: build
	python mb-tool/zm_dict.py $(scheme-dir)/zg-code/$(zg-code).tsv $(scheme-dir)/main.tsv -r $(rules) > build/main.tsv

jianma-%: build
	python mb-tool/zm_dict.py $(scheme-dir)/zg-code/$(zg-code).tsv $(scheme-dir)/common-$*.tsv -r $(rules) | \
		python mb-tool/jianma-gen.py $(jm-methods) --freq-table $(char-freq-$(*)) > build/jianma-$*.tsv

clean:
	rm build/*
