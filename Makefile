# 有一些外部路径和不便公开的变量可在.env中设定
# .env不是必要的
#
# == 字频文件路径 ==
# 名称：char_freq_(用字标准)
# 支持.tsv和.csv
-include .env

# 用字标准
# zt: 正體（繁體）
# jt: 简体
# jp: 日文
char-stds=zt jt jp

# 输入引擎
programs=rime plover

# == 码表路径 ==
# 初始码表。可在.env中设定。可设为外部文件。
# 只读不改
init-mb ?= table/jiezi.tsv
# 输入码表。生成自初始码表。
shuru-mb=table/shuru.tsv

mb-xformer=python mb-tool/mb_algebra.py --regex
xform-dir=mb-algebra

dm-tag=abyz
dai-mb=table/shuru-$(dm-tag).tsv
dm-maker=$(mb-xformer) $(xform-dir)/dm-$(dm-tag).yaml

steno-dict-gen=python mb-tool/steno_dict.py
chordmap=steno/chordmap.tsv

system-zt=steno/system/abc.json
system-jt=steno/system/abc.json
system-jp=steno/system/yayakana.json

jianma-gen=python mb-tool/jianma-gen.py

jm-name-zt=簡碼
jm-name-jt=简码
jm-name-jp=略コード

az=0,-1
ab=0,1
yz=-2,-1
za=-1,0
ba=1,0
zy=-1,-2
jianma-methods=$(az):$(ab):$(yz):$(za):$(ba):$(zy)

serial-jm-methods=0:0,1,2:0,1,-1
serial-bicode=serial/bicode/zm_bc.tsv
serial-rules=serial/rules.tsv

.PHONY: all clean

all: $(foreach program,$(programs),$(program)_all)

build:
	mkdir $@

shuruma:
	cat $(init-mb) | $(mb-xformer) $(xform-dir)/varied.yaml | \
		$(mb-xformer) $(xform-dir)/unvaried.yaml > $(shuru-mb)

daima: shuruma
	$(dm-maker) $(shuru-mb) > $(dai-mb)

steno-%: daima steno-jm-% build
	cat $(dai-mb) | \
		python mb-tool/apply_priority.py steno/char_priority/$(dm-tag)-$*.tsv -u ',重,能,能重' | \
		perl steno/preprocess.pl | \
		$(steno-dict-gen) $(system-$(*)) $(chordmap) > build/steno-$(dm-tag)-$*.tsv
	cat steno/steno-jm-$*.tsv | sed -E 's/$$/简/' | perl steno/preprocess.pl | \
		$(steno-dict-gen) $(system-$(*)) $(chordmap) > build/steno-jm-$*.tsv

steno-jm-%: common-% build
	$(eval char_freq_$(*) ?= table/empty.tsv)
	./mb-tool/code_match.sh '.{3,}' table/common-$*.tsv | \
		$(jianma-gen) 0:0,0,0:$(jianma-methods) --char-freq $(char_freq_$(*)) | \
		sed -E 's/\t(.)..$$/\t空\1/' > steno/steno-jm-$*.tsv

serial-dict: daima
	python mb-tool/transform.py $(serial-bicode) $(dai-mb) -r $(serial-rules) | \
		awk '!seen[$$0]++' > serial/serial-dict.tsv

serial-jm-%: serial-dict common-%
	$(eval char_freq_$(*) ?= table/empty.tsv)
	./mb-tool/code_match.sh '^.{3,}$$' table/common-$*.tsv | \
		python mb-tool/transform.py $(serial-bicode) -r $(serial-rules) | \
		$(jianma-gen) $(serial-jm-methods) --char-freq $(char_freq_$(*)) > serial/serial-jm-$*.tsv

common-%:
	python mb-tool/subset.py table/jiezi.tsv char_set/common-$* | \
		$(mb-xformer) $(xform-dir)/standard-$*.yaml | \
		$(mb-xformer) $(xform-dir)/unvaried.yaml > table/common-$*.tsv

rime_all: $(foreach std,$(char-stds),rime-$(std)) rime_zigen serial-dict

rime-%: rime-steno-% serial-jm-%
	:

rime-steno-%: steno-%
	cat build/steno-$(dm-tag)-$*.tsv | mb-tool/format.sh rime > build/rime-steno-$*.tsv
	printf "\n# $(jm-name-$(*))\n" >> build/rime-steno-$*.tsv
	cat build/steno-jm-$*.tsv | mb-tool/format.sh rime >> build/rime-steno-$*.tsv

rime_punc: build
	cat table/punctuation.tsv | perl steno/preprocess.pl | \
		$(steno-dict-gen) $(system-zt) $(chordmap) | \
		mb-tool/format.sh algebra | sed -E 's/\|(.+)\|\|\|/\/\1\/|\//' > build/rime-punct

rime_zigen: build_zigen
	cat build/zigen.tsv | mb-tool/format.sh rime > build/rime-zigen.tsv

plover_all: $(foreach std,$(char-stds),plover-$(std))

plover-%: steno-%
	cat build/steno-$(dm-tag)-$*.tsv | mb-tool/format.sh plover > build/plover-$*.json
	cat build/steno-jm-$*.tsv | mb-tool/format.sh plover > build/plover-jm-$*.json

build_zigen: build
	cat $(chordmap) | sed 's/\t""$$/\t,a/' | \
		awk '{print $$1"\t{"$$2"}"} $$1 !~ /[重能成简空]/ {print $$1"\t{,"$$2"}"}' | \
		$(steno-dict-gen) $(system-jt) $(chordmap) > build/zigen.tsv

po_patch:
	python mb-tool/combine_dict.py steno/char_priority/$(dm-tag)-zt.tsv steno/char_priority/$(dm-tag)-jp-patch.tsv > steno/char_priority/$(dm-tag)-jp.tsv
	python mb-tool/combine_dict.py steno/char_priority/$(dm-tag)-zt.tsv steno/char_priority/$(dm-tag)-vi-patch.tsv > steno/char_priority/$(dm-tag)-vi.tsv

code_freq: $(foreach std,$(char-stds),code-freq-$(std))

code-freq-%: daima steno-jm-% build
	$(eval char_freq_$(*) ?=)
	python mb-tool/code_freq.py table/common-$*.tsv $(char_freq_$(*)) > stat/code_freq/$*
	$(dm-maker) table/common-$*.tsv > build/tmp
	python mb-tool/code_freq.py build/tmp $(char_freq_$(*)) > stat/code_freq/$(dm-tag)-$*
	awk -F'\t' 'length($$2) > 2 {next} 1' table/common-$*.tsv > build/tmp
	cat steno/steno-jm-$*.tsv >> build/tmp
	python mb-tool/code_freq.py build/tmp $(char_freq_$(*)) > stat/code_freq/jm-$*
	rm build/tmp

clean:
	rm build/*
