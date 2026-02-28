# 解字方案
zg-scheme?=xingyi
# 方案文件夾
scheme-dir?=zg-scheme/$(zg-scheme)
# 字根区位码
zg-code?=xingzheng
zg-code-mb=$(scheme-dir)/zg-code/$(zg-code).tsv

# 字体标准
char-standards?=ft jt jp
# 碼表
table?=$(scheme-dir)/$(zg-scheme).tsv
table-ft?=$(scheme-dir)/$(zg-scheme)-ft.tsv
table-jt?=$(scheme-dir)/$(zg-scheme)-jt.tsv
table-jp?=$(scheme-dir)/$(zg-scheme)-jp.tsv
# 常用字表
common?=char_set/common-ft
common-ft?=char_set/common-ft
common-jt?=char_set/common-jt
common-jp?=char_set/common-jp

keymap?=qwerty
keymap-file?=keymap/$(keymap).json
codemap?=zhengma
codemap-file?=codemap/$(codemap).json

# 簡碼取碼法
A=0
ABC=0,2,4
ABZ=0,2,-2
AYZ=0,-4,-2
AaB=0,1,2
AaZ=0,1,-2
ABb=0,2,3
AZz=0,-2,-1
jm-methods?=$(A):$(ABC):$(ABZ):$(AYZ):$(AaB):$(AaZ):$(ABb):$(AZz)
# 給多長的編碼生成簡碼
jm-gen-length?=4
