ifeq ($(config),)
-include custom.mk
else
-include $(config)
endif
include default.mk

ifeq ($(char-standards),)
all: dict jianma
else
all: $(foreach std,$(char-standards),dict-$(std) jianma-$(std))
endif

build:
	mkdir $@

dict: dict-.

dict-%: build zg-code
	$(eval ver = $(subst -.,,-$(*)))
	python mb-tool/column_repl.py -re -c 1 '(.) -> (\1)' $(table$(ver)) | \
		python mb-tool/column_repl.py -c 1 -f build/zg-code > build/dict$(ver).tsv

zg-code:
	python mb-tool/apply_mapping.py codemap/key_pos_num.json $(codemap-file) $(zg-code-mb) | \
		sed -E 's/^(.+)\t/(\1)\t/' > build/zg-code # 區分字根和區位碼

jianma: jianma-.

jianma-%: dict-%
	$(eval ver = $(subst -.,,-$(*)))
	python mb-tool/subset.py build/dict$(ver).tsv $(common$(ver)) | \
		awk -F'\t' 'length($$2) >= $(jm-gen-length) {print $$1"\t"$$2}' | \
		python mb-tool/jianma-gen.py $(jm-methods) --freq-table $(char-freq$(ver)) > build/jianma$(ver).tsv

clean:
	rm build/*
