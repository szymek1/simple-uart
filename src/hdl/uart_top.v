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
    input wire [3:2]  btn,             // BTN3: receiver on/off, BTN2: transmitter on/off
    input wire        uart_rx_serial,  // serial input
    // transmitter
    input wire [3:0]  sw,              // toggle switches to speicfy message (4 lowest bits)

    // Outputs:
    // general
    output wire        uart_tx_serial, // serial output
    // transmitter
    output wire [3:0] led,            // when a switch is toggled led lights up
    output wire       led5_r,         // transmitter off
    output wire       led5_g,         // transmitter on
    output wire       led5_b,         // transmitter done
    // receiver
    output wire       led6_r,         // receiver off
    output wire       led6_g,         // receiver on
    output wire       led6_b          // receiver done
);

    parameter              i_TX_BTN = 2;
    parameter              i_RX_BTN = 3;

    // Receiver
    reg  [1:0]             btn3_sync  = 2'b00;                         // 2-FF synchornizer
    wire                   btn3_rise =  btn3_sync[0] & ~btn3_sync[1];  // 1-clk pulse on 0->1
    reg                    rx_on      = 1'b0;                          // controlled by btn2
    reg                    r_rx_d     = 1'b0;

    // Transmitter
    reg  [1:0]             btn2_sync  = 2'b00;                         // 2-FF synchornizer
    wire                   btn2_rise =  btn2_sync[0] & ~btn2_sync[1];  // 1-clk pulse on 0->1
    reg                    tx_on      = 1'b0;                         // controlled by btn3
    reg                    r_tx_d     = 1'b0;
    wire [`DATA_WIDTH-1:0] i_tx_byte  = {4'b0, sw[3], sw[2], sw[1], sw[0]};

    // UART Transmitter module
    uart_tx uut (
        .sysclk(sysclk),
        .i_tx(tx_on),
        .i_tx_byte(i_tx_byte),
        .o_tx_serial(uart_tx_serial), // goes straight to JE-1
        .o_tx_d()
    );

    // UART Receiver module
    uart_rx u_rx (
    .sysclk      (sysclk),
    .i_rx        (rx_on),
    .i_rx_serial (uart_rx_serial),    // comes from JE-2
    .o_rx_d      (),
    .o_rx_byte   (rx_byte)
    );

    always @(posedge sysclk) begin
        // Checking for receiver button click
        btn3_sync <= {btn3_sync[0], btn[i_RX_BTN]};
        if (btn3_rise) begin
            rx_on <= ~rx_on;
        end else begin
            rx_on <= rx_on;
        end

        // Checking for transmitter button click
        btn2_sync <= {btn2_sync[0], btn[i_TX_BTN]};
        if (btn2_rise) begin
            tx_on <= ~tx_on;
        end else begin
            tx_on <= tx_on;
        end
    end
    
    // Transmitter indicators
    assign led5_g = (tx_on  == 1'b1) ? 1'b1 : 1'b0; // transmission on
    assign led5_r = (tx_on  == 1'b0) ? 1'b1 : 1'b0; // transmission off
    assign led5_b = (r_tx_d == 1'b1);               // data transmitted

    // Transmitter input indicators
    assign led[0] = sw[0];
    assign led[1] = sw[1];
    assign led[2] = sw[2];
    assign led[3] = sw[3];

    // Receiver indicators
    assign led6_g = (rx_on  == 1'b1) ? 1'b1 : 1'b0; // receiver on
    assign led6_r = (rx_on  == 1'b0) ? 1'b1 : 1'b0; // receiver off
    assign led6_b = (r_rx_d == 1'b1);               // data received

endmodule