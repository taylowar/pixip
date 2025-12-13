
main: prepare_build_directory src/main.c
	$(CC) -Wall -Wextra -o ./build/main src/main.c

.PHONY:
prepare_build_directory:
	@if [ ! ! -d "./build" ]; then \
		mkdir ./build; \
	fi 
