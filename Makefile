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
	python mb-tool/apply_mapping.py $(codemap-file) $(keymap-file) build/jianma$(ver).tsv | \
		sed 's/|/\t/' >> build/dict$(ver).tsv
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
		awk -F'\t' 'length($$2) >= $(jm-gen-len-1) {print $$1"\t"$$2}' | \
		python mb-tool/jianma-gen.py "0" --freq-table $(char-freq$(ver)) \
			--format "{text}	{jm}|{code}" > build/jianma$(ver).tsv
	python mb-tool/subset.py build/full$(ver).tsv $(common$(ver)) | \
		awk -F'\t' 'length($$2) >= $(jm-gen-len-3) {print $$1"\t"$$2}' | \
		python mb-tool/jianma-gen.py $(jm-methods) --freq-table $(char-freq$(ver)) \
			--format "{text}	{jm}|{code}" >> build/jianma$(ver).tsv

ifeq ($(char-standards),)
zg-freq: zg-freq-.
else
zg-freq: $(foreach std,$(char-standards),zg-freq-$(std))
endif

zg-freq-%:
	$(eval ver = $(subst -.,,-$(*)))
	python mb-tool/code_freq.py $(table$(ver)) --freq-table $(char-freq$(ver)) > zg-freq/$(zg-scheme)$(ver).tsv

check-zg-code:
ifeq ($(char-standards),)
	awk -F "\t" -f mb-tool/code_set.awk $(table) | \
		python mb-tool/subset.py --sym-diff $(zg-code-mb)
else
	awk -F "\t" -f mb-tool/code_set.awk $(foreach std,$(char-standards),$(table-$(std))) | \
		python mb-tool/subset.py --sym-diff $(zg-code-mb)
endif
	python mb-tool/find_duplicate.py $(zg-code-mb)

clean:
	rm build/*
