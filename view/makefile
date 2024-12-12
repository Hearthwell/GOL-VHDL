C_LINK := $(shell pkg-config --libs sdl2)
view: src/main.c
	gcc -Wall -Wextra $< -o view $(C_LINK)