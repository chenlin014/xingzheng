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

build:
	mkdir $@

full: full-.

full-%: build zg-code
	$(eval ver = $(subst -.,,-$(*)))
	python mb-tool/column_repl.py -re -c 1 '(.) -> (\1)' $(table$(ver)) | \
		python mb-tool/column_repl.py -c 1 -f build/zg-code > build/full$(ver).tsv

dict: dict-.

dict-%: full-% jianma-%
	$(eval ver = $(subst -.,,-$(*)))
	python mb-tool/apply_mapping.py $(codemap-file) $(keymap-file) \
		build/full$(ver).tsv > build/dict$(ver).tsv
	printf "\n# $(jm-name$(ver))\n" >> build/dict$(ver).tsv
	python mb-tool/apply_mapping.py $(codemap-file) $(keymap-file) build/jianma$(ver).tsv > build/temp
	awk -F'\t' 'NR==FNR {code[$$1]=$$2; next} ($$1 in code) {print $$1"\t"$$2"\t"code[$$1]}' \
		build/dict$(ver).tsv build/temp | tee >> build/dict$(ver).tsv
	sed -E 's/^(.+)\t(.)(.)$$/\1\t\2\3\t\2\3\3/' build/dict$(ver).tsv > build/temp
	cat build/temp > build/dict$(ver).tsv
	rm build/temp

zg-code:
	python mb-tool/apply_mapping.py codemap/key_pos_num.json $(codemap-file) $(zg-code-mb) | \
		sed -E 's/^(.+)\t/(\1)\t/' > build/zg-code # 區分字根和區位碼

jianma: jianma-.

jianma-%: full-%
	$(eval ver = $(subst -.,,-$(*)))
	python mb-tool/subset.py build/full$(ver).tsv $(common$(ver)) | \
		awk -F'\t' 'length($$2) >= $(jm-gen-length) {print $$1"\t"$$2}' | \
		python mb-tool/jianma-gen.py $(jm-methods) --freq-table $(char-freq$(ver)) > build/jianma$(ver).tsv

clean:
	rm build/*
