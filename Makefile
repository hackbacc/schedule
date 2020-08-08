TSS=$(shell find ./ts/ -type f -name '*.ts')
BROWSERIFY=./node_modules/.bin/browserify
WATCHIFY=./node_modules/.bin/watchify
SASS=./node_modules/.bin/sass
SASS_FLAGS=--load-path=node_modules/@fortawesome/fontawesome-free/scss
SASS_BUILD_FLAGS=$(SASS_FLAGS) --no-source-map
SASS_WATCH_FLAGS=$(SASS_FLAGS) --watch
STATIC=html/index.html css/reset.css json/schedule.json

# PRODUCTION ##############################

.PHONY: all
all: docs/app.js docs/index.html docs/reset.css docs/main.css docs/schedule.json

docs/app.js: docs $(TSS)
	$(BROWSERIFY) ./ts/app.ts -p tsify -g uglifyify --outfile docs/app.js

docs/index.html: docs html/index.html
	cp html/index.html docs/

docs/reset.css: docs css/reset.css
	cp css/reset.css docs/

docs/main.css: docs scss/main.scss
	mkdir -p docs/webfonts
	cp node_modules/@fortawesome/fontawesome-free/webfonts/* docs/webfonts/
	$(SASS) $(SASS_BUILD_FLAGS) scss/main.scss docs/main.css

docs/schedule.json: docs json/schedule.json
	jq -c . json/schedule.json > docs/schedule.json

docs:
	mkdir -p docs

# DEVELOPMENT ##############################

.PHONY: watch
watch: watch-ts watch-scss watch-static http-server

.PHONY: watch-ts
watch-ts: docs $(TSS)
	$(WATCHIFY) ./ts/app.ts -v -p tsify --outfile docs/app.js --debug

.PHONY: watch-scss
watch-scss: docs scss/main.scss
	mkdir -p docs/webfonts
	cp node_modules/@fortawesome/fontawesome-free/webfonts/* docs/webfonts/
	$(SASS) $(SASS_WATCH_FLAGS) scss/main.scss docs/main.css

.PHONY: watch-static
watch-static: docs $(STATIC)
	cp $(STATIC) docs/
	while inotifywait -q -e modify,move_self $(STATIC); do \
		cp $(STATIC) docs/;                                \
	done

.PHONY: http-server
http-server: docs
	python -m SimpleHTTPServer 8080

.PHONY: clean
clean:
	rm -rfv docs/
