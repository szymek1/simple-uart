//////////////////////////////////////////////////////////////////////////////////
// Company: ISAE
// Engineer: Szymon Bogus
// 
// Create Date: 07/10/2025
// Design Name: 
// Module Name: uart_rx_tb
// Project Name: simple-uart
// Target Devices: Zybo Z7-20
// Tool Versions: 
// Description: Testbench for UART receiver module.
// 
// Dependencies: uart_params.vh
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
`include include/uart_params.vh


module uart_rx_tb (

);

    // UART receiver inputs
    reg                    sysclk;
    reg                    i_rx;
    reg                    i_rx_serial;

    // UART receiver outputs
    wire                   o_rx_d;
    wire [`DATA_WIDTH-1:0] o_rx_byte;



endmodule