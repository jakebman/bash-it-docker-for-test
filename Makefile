
build: .built
.built: Dockerfile setup.sh install.sh Makefile
	docker build -t foo --progress plain .
	touch .built
run: build
	docker run --rm -it foo

clean:
	rm .built
