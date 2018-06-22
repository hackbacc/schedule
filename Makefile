BROWSERIFY=./node_modules/.bin/browserify
WATCHIFY=./node_modules/.bin/watchify

all: dist/app.js dist/index.html

watch: dist/index.html
	$(WATCHIFY) -v ./src/app.ts -p tsify --outfile dist/app.js

$(BROWSERIFY): package.json
	npm install

$(WATCHIFY): package.json
	npm install

dist/app.js: dist $(BROWSERIFY)
	$(BROWSERIFY) ./src/app.ts -p tsify -g uglifyify --outfile dist/app.js

dist/index.html: dist html/index.html
	cp html/index.html dist/

dist:
	mkdir -p dist

.PHONY: all clean watch

clean:
	rm -rfv dist/
