`ifndef UART_PARAMS_V
`define UART_PARAMS_V

`define PARITY   1'b0  // no parity bit
`define BAUDRATE 115200
`define START_BIT 1'b0 // start bit is set active low
`define STOP_BIT 1'b1  // stop bit is set active high

`endif // UART_PARAMS_V