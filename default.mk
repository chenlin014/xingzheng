# 解字方案
jz-scheme?=xingyi
# 方案文件夾
scheme-dir?=jz-scheme/$(jz-scheme)
# 字根区位码
zg-code?=xingzheng
zg-code-mb=$(scheme-dir)/zg-code/$(zg-code).tsv

# 字体标准
char-standards?=ft jt jp
# 碼表
table?=$(scheme-dir)/$(jz-scheme).tsv
table-ft?=$(scheme-dir)/$(jz-scheme)-ft.tsv
table-jt?=$(scheme-dir)/$(jz-scheme)-jt.tsv
table-jp?=$(scheme-dir)/$(jz-scheme)-jp.tsv
# 常用字表
common?=char_set/common-ft
common-ft?=char_set/common-ft
common-jt?=char_set/common-jt
common-jp?=char_set/common-jp

keymap?=qwerty
keymap-file?=keymap/$(keymap).json
codemap?=zhengma
codemap-file?=codemap/$(codemap).json

rules?=rules/aabyz.tsv
jm-methods?=0:0,1,2:0,1,-1
