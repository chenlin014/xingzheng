ifeq ($(config),)
-include custom.mk
else
-include $(config)
endif
include default.mk

ifeq ($(char-standards),)
all: dict
else
all: $(foreach std,$(char-standards),dict-$(std))
endif
	rm build/zg-code

build:
	mkdir $@

dict: dict-.

dict-%: build jianma-% zg-code
	$(eval ver = $(subst -.,,-$(*)))
	python mb-tool/zm_dict.py build/zg-code $(table$(ver)) -r $(rules) > build/dict$(ver).tsv

zg-code:
	python mb-tool/apply_mapping.py codemap/key_pos_num.json $(codemap-file) $(zg-code-mb) > build/zg-code

jianma: jianma-.

jianma-%: build zg-code
	$(eval ver = $(subst -.,,-$(*)))
	python mb-tool/subset.py $(table$(ver)) $(common$(ver)) | \
		awk -F'\t' '$$2 ~ /.../ {print $$1"\t"$$2}' | \
		python mb-tool/zm_dict.py build/zg-code -r $(rules) | \
		python mb-tool/jianma-gen.py $(jm-methods) --freq-table $(char-freq$(ver)) > build/jianma$(ver).tsv

clean:
	rm build/*
