
build: .built
.built: Dockerfile setup.sh install.sh Makefile
	docker build -t foo --progress plain .
	touch .built
run: build
	docker run --rm -it foo

clean:
	rm .built || echo "it's fine - .built is already gone"
	docker image rm foo || echo "it's fine - foo is already gone"
	(yes | docker builder prune) || echo "it's fine - prune doesn't need to work"
