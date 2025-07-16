# simple-uart
## Overview
This repository contains a synthesizeable FPGA UART implementation as well as an example software to communicate with a separate machine.

## Hardware
The target hardware is Digilent Zybo Z7-20 + PMOD UART cabel.
Synthesize with Vivado distinguishes the following number of FPGA components utilized:
| #   | Cell | Count |
|-----|------|-------|
| 1   | BUFG | 1     |
| 2   | LUT1 | 2     |
| 3   | LUT2 | 2     |
| 4   | LUT3 | 3     |
| 5   | LUT4 | 8     |
| 6   | LUT5 | 7     |
| 7   | LUT6 | 9     |
| 8   | FDRE | 26    |
| 9   | FDSE | 2     |
| 10  | IBUF | 7     |
| 11  | OBUF | 11    |

## Build
In order to generate bitstream and netlist execute:
```
make build
```

Programming the device is done with:
```
make program_fpga
```

In order to customize this implementation please adjust project's section of Makefile:
```Makefile
# Project's details
project_name    := simple_uart
top_module	    := uart_top
language 	    := verilog
device 		    := xc7z020clg400-1 # use device specific name
```

Don't forget to provide your own ```.xdc``` file to ```src/constraints/``` directory.

## Simulation
Running simulations is also possible. All testbenches have to be stored inside ```src/sim/```.

Tesbenches can be either run all or selected.
To run all of them:
```
make sim_all
```

To run selected:
```
make sim_sel TB="uart_top_tb uart_rx_tb ..."
```

Results will be stored inside ```simulation/waveforms``` directory that will be created during the first run of make.

## Testing
Inside ```src/uart_host_pc/``` there are Python utilities to send and receive data back and forth to and from FPGA.