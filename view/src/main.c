#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdbool.h>
#include <termios.h>
#include <sys/ioctl.h>
#include <errno.h>

#include <SDL2/SDL.h>

#define DISPLAY_SIZE   720
#define SERIAL_PORT "/dev/ttyUSB0"
/* TODO, MAKE FPGA SEND THE MAP SIZE AS THE FIRST 4 BYTES LETS SAY */
#define GOL_MAP_SIZE 32
#define UART_BAUDRATE 9600

static int init(SDL_Window **window){
    /* initialize SDL */
    if( SDL_Init(SDL_INIT_VIDEO) < 0 ){
        printf( "SDL could not initialize! SDL_Error: %s\n", SDL_GetError() );
        return 1;
    }
    *window = SDL_CreateWindow("Basic", 0, 0, DISPLAY_SIZE, DISPLAY_SIZE, SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN);
    if(*window == NULL){
        printf( "Window could not be created! SDL_Error: %s\n", SDL_GetError() );
        return 1;
    }
    return 0;
}

static void gol_display_world(SDL_Surface *surface, const uint8_t *map){
    const float width = (float)DISPLAY_SIZE / GOL_MAP_SIZE;
    const unsigned int STRIDE = GOL_MAP_SIZE / 8;
    for(unsigned int i = 0; i < GOL_MAP_SIZE; i++){
        for(unsigned int j = 0; j < GOL_MAP_SIZE; j++){
            const unsigned int index = j / 8;
            SDL_Rect rect = {.x = (int)(j * width), .y = (int)(i * width), .w = (int)width, .h = (int)width};
            uint32_t color = (map[i * STRIDE + index] & (1 << (7 - (j % 8)))) ? 0xFFFFFFFF : 0x00000000;
            SDL_FillRect(surface, &rect, color);
        }
    }
}

static void print_map(uint8_t *buffer){
    const unsigned int map_size = GOL_MAP_SIZE * GOL_MAP_SIZE / 8;
    for(unsigned int i = 0; i < map_size; i++){
        printf("%2.2x, ", buffer[i]);
        if(i % (GOL_MAP_SIZE / 8) == 0) printf("\n");
    }
    printf("\n#############################\n");
}

int main(){
    printf("HOLLA VIEW FOR FPGA GOL\n");

    SDL_Window *window;
    if(init(&window)) return 1;
    SDL_Surface *surface = SDL_GetWindowSurface(window);

    int fd = open(SERIAL_PORT, O_RDONLY);
    if(fd < 0){
        printf("ERROR: COULD NOT OPEN FILE: %s, %s\n", SERIAL_PORT, strerror(errno));
        return 1;
    }
    struct termios tty_settings;
    tcgetattr(fd, &tty_settings);
    tty_settings.c_lflag &= ~ICANON;
    cfsetospeed(&tty_settings, UART_BAUDRATE);
    tcsetattr(fd, TCSANOW, &tty_settings);
    const unsigned int map_size = GOL_MAP_SIZE * GOL_MAP_SIZE / 8;
    uint8_t buffer[map_size];

    /* EMPTY BUFFER BEFORE NEXT EXECUTION */
    unsigned int bytes = 0;
    ioctl(fd, FIONREAD, &bytes);
    char c;
    for(unsigned int i = 0; i < bytes; i++) read(fd, &c, 1);
    printf("EMPTIED %u bytes\n", bytes);

    bool running = true;
    while(running){
        SDL_Event e;
        while(SDL_PollEvent( &e ) != 0){
            if( e.type == SDL_QUIT || e.key.keysym.sym == SDLK_ESCAPE) running = false;
        }

        unsigned int bytes = 0;
        do {ioctl(fd, FIONREAD, &bytes);} while (bytes < map_size);
        read(fd, buffer, map_size);

        print_map(buffer);

        gol_display_world(surface, buffer);
        SDL_UpdateWindowSurface(window);
    }

    return 0;
}