-include custom.mk
include default.mk

ifeq ($(char-standards),)
all: dict jianma
else
all: $(foreach std,$(char-standards),dict-$(std))
endif

build:
	mkdir $@

dict: build jianma
	python mb-tool/zm_dict.py $(zg-code-mb) $(table) -r $(rules) > build/dict.tsv

dict-%: build jianma-%
	python mb-tool/zm_dict.py $(zg-code-mb) $(table-$(*)) -r $(rules) > build/dict-$*.tsv

jianma: build
	python mb-tool/subset.py $(table) $(common) | \
		python mb-tool/zm_dict.py $(zg-code-mb) -r $(rules) | \
		python mb-tool/jianma-gen.py $(jm-methods) --freq-table $(char-freq) > build/jianma.tsv

jianma-%: build
	python mb-tool/subset.py $(table-$(*)) $(common-$(*)) | \
		python mb-tool/zm_dict.py $(zg-code-mb) -r $(rules) | \
		python mb-tool/jianma-gen.py $(jm-methods) --freq-table $(char-freq-$(*)) > build/jianma-$*.tsv

test:

clean:
	rm build/*
