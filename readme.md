## For the Uart subsystem, Check the project: https://github.com/Hearthwell/uartVHDL

## The hardware folder contains all the vhdl code used for FPGA synthesis
## The view folder contains the C code used to receive the map data from serial COM and redering with SDL2
## Connexion between Host and FPGA is done through UART with a SERIAL TO USB Adapter

### To Run the simulation with ghdl run:
```
cd hardware
make processor_sim
gtkwave out/output.ghw
```

### To Run the View part:
```
cd view
make
./view
```