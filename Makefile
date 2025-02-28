
all: build

build: .built
.built: Dockerfile Makefile
	docker build -t foo --progress plain .
	touch .built
run: build
	docker run --rm -it foo
root: build
	docker run --rm -it --user root foo

clean:
	docker image rm foo || echo "it's fine - foo is already gone"
	(yes | docker builder prune) || echo "it's fine - builder prune doesn't need to work"
	(yes | docker image   prune) || echo "it's fine - image   prune doesn't need to work"
	rm .built || echo "it's fine - .built is already gone"
