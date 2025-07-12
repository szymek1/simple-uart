//////////////////////////////////////////////////////////////////////////////////
// Company: ISAE
// Engineer: Szymon Bogus
// 
// Create Date: 12/10/2025
// Design Name: 
// Module Name: uart_top
// Project Name: simple-uart
// Target Devices: Zybo Z7-20
// Tool Versions: 
// Description: UART top module. It integrates both receiver and transmitter.
//              It is reponsible for managing physical buttons and switches of
//              an FPGA to control reception and transmission. 
//              Receiver mode:
//              - BTN3: press to switch on/off
//              - When on LD6 is green, when off LD6 is red
//              - When package is received LD6 is blue
//              Transmitter mode:
//              - BTN2: press to switch on/off
//              - When on LD5 is green, when off LD5 is red
//              - Use switches: 0,1,2,3 to specify 4 bits to transmitt (the rest
//               will be 0 because there isn't enough) :(
//              - When package is transmitted LD5 is blue
//
//              Only one mode can work. If transmission is needed first specify
//              message, then activate trnamistter mode.
// 
// Dependencies: uart_params.vh
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
`include "../include/uart_params.vh"


module uart_top(
    // Inputs:
    // general
    input wire       sysclk,
    input wire [3:2] btn,    // BTN3: receiver on/off, BTN2: transmitter on/off
    // transmitter
    input wire [3:0] sw,     // toggle switches to speicfy message (4 lowest bits)

    // Outputs:
    // transmitter
    output reg [3:0] led,    // when a switch is toggled led lights up
    output reg       led5_r, // transmitter off
    output reg       led5_g, // transmitter on
    output reg       led5_b, // transmitter done
    // receiver
    output reg       led6_r, // receiver off
    output reg       led6_g, // receiver on
    output reg       led6_b, // receiver done
);
endmodule