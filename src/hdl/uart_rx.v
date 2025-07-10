//////////////////////////////////////////////////////////////////////////////////
// Company: ISAE
// Engineer: Szymon Bogus
// 
// Create Date: 07/10/2025
// Design Name: 
// Module Name: uart_rx
// Project Name: simple-uart
// Target Devices: Zybo Z7-20
// Tool Versions: 
// Description: UART receiver module. I receives 8 bits of serial data, start and
//              stop bit. When receiver is done it issues o_rx_d for one cycle.
//              Receiver module is one, when button 3 (btn[3]) was pressed once.
//              Pressing button 3 for the second time deactivates the mode.
// 
// Dependencies: uart_params.vh
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include include/uart_params.vh


module (
    input  wire                  sysclk,
    input  wire                  i_rx,        // receive mode active signal (set high active)
    input  wire                  i_rx_serial, // serial data
    output reg                   o_rx_d,      // flag indicating that entire byte of data was received
    output reg [`DATA_WIDTH-1:0] o_rx_byte    // received data
);

    // Receiver FSM states
    parameter IDLE     = 2'b00;
    parameter START_RX = 2'b01;
    parameter RX_ON    = 2'b10;
    parameter STOP_RX  = 2'b11;

endmodule