
build: .built
.built: Dockerfile setup.sh install.sh
	docker build -t foo --progress tty .
	touch .built
run: build
	docker run --rm --env BASH_IT_THEME=nwinkler -it foo

clean:
	rm .built
