.PHONY: all vital test themis lint clean ancient aspell circleci

PLUGIN_NAME = iced
VITAL_MODULES = Data.Dict \
		Data.List \
		Data.String \
		Locale.Message \
		Vim.Buffer \
		Vim.BufferManager \
		Vim.Message \
		Web.HTTP

all: vital test

vital:
	vim -c "Vitalize . --name=$(PLUGIN_NAME) $(VITAL_MODULES)" -c q

test: themis lint

.vim-themis:
	git clone https://github.com/thinca/vim-themis .vim-themis

themis: .vim-themis
	./.vim-themis/bin/themis

lint:
	find . -name "*.vim" | grep -v vital | grep -v .vim-themis | xargs vint

clean:
	/bin/rm -rf autoload/vital*

ancient:
	clojure -A:ancient

aspell:
	aspell -d en -W 3 -p ./.aspell.en.pws check README.md
	aspell -d en -W 3 -p ./.aspell.en.pws check doc/vim-iced.txt

circleci: _circleci-lint _circleci-test
_circleci-lint:
	circleci build --job lint
_circleci-test:
	circleci build --job test
