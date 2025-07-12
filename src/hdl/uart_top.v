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
    input wire        sysclk,
    input wire [3:2]  btn,    // BTN3: receiver on/off, BTN2: transmitter on/off
    // transmitter
    input wire [3:0]  sw,     // toggle switches to speicfy message (4 lowest bits)

    // Outputs:
    // transmitter
    output reg [3:0]  led,    // when a switch is toggled led lights up
    output wire       led5_r, // transmitter off
    output wire       led5_g, // transmitter on
    output wire       led5_b, // transmitter done
    // receiver
    output wire       led6_r, // receiver off
    output wire       led6_g, // receiver on
    output wire       led6_b  // receiver done
);

    parameter i_TX_BTN = 2;
    parameter i_RX_BTN = 3;

    // Receiver
    // keeps output of BTN3 in a flip-flop
    reg       r_btn3     = 1'b0; 
    reg       r_rx_press = 1'b0;
    reg       rx_on      = 1'b0;  // controlled by btn2

    // Transmitter
    // keeps output of BTN3 in a flip-flop
    reg       r_btn2     = 1'b0; 
    reg       r_tx_press = 1'b0;
    reg       tx_on      = 1'b0;  // controlled by btn3

    always @(posedge sysclk) begin
        // Checking for receiver button click
        r_btn3 <= btn[i_RX_BTN];
        r_rx_press <= r_btn3;
        rx_on <= (r_rx_press == 1'b1) ? ~rx_on : rx_on;

        // Checking for transmitter button click
        r_btn2 <= btn[i_TX_BTN];
        r_tx_press <= r_btn2;
        tx_on <= (r_tx_press == 1'b1) ? ~tx_on : tx_on;
    end
    
    // Transmitter indicators
    assign led5_g = (tx_on == 1'b1) ? 1'b1 : 1'b0; // transmission on
    assign led5_r = (tx_on == 1'b0) ? 1'b1 : 1'b0; // transmission off
    assign led5_b = 1'b0; // data transmitted

    // Receiver indicators
    assign led6_g = (rx_on == 1'b1) ? 1'b1 : 1'b0; // receiver on
    assign led6_r = (rx_on == 1'b0) ? 1'b1 : 1'b0; // receiver off
    assign led6_b = 1'b0; // data received
endmodule