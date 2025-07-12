//////////////////////////////////////////////////////////////////////////////////
// Company: ISAE
// Engineer: Szymon Bogus
// 
// Create Date: 12/10/2025
// Design Name: 
// Module Name: uart_tx
// Project Name: simple-uart
// Target Devices: Zybo Z7-20
// Tool Versions: 
// Description: UART transmitter module. I sends byte of data in a serialized manner,
//              start and stop bit. Trnasmitter module is on when button 2 (btn[2])
//              was pressed once. Pressing button 3 for the second time deactivates 
//              the mode.
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


module uart_tx(
    input wire                   sysclk,
    input wire                   i_tx,        // transmitter signal active (set high active)
    input wire [`DATA_WIDTH-1:0] i_tx_byte,   // byte to transmitt
    output wire                  o_tx_serial, // serialized transmitted bit
    output wire                  o_tx_d       // flag indicating that an entire byte of data has been sent
);

    // Transmitter FSM states
    parameter IDLE     = 3'b000;
    parameter START_TX = 3'b001;
    parameter TX_ON    = 3'b010;
    parameter STOP_TX  = 3'b100;
    parameter DATA_OK  = 3'b111;

    reg [2:0] current_state;

    reg                   tx_bit;
    reg [`DATA_WIDTH-1:0] r_tx_byte;
    reg [2:0]             tx_bit_index; // used to count how many bits have been already sent
    reg                   r_tx_d;
    reg [11:0]            clks_cnt;     // used to count clock cycles before bit transmission is done

    always @(posedge sysclk) begin
        if (i_tx) begin
            case (current_state) 
                IDLE    : begin
                    r_tx_byte     <= i_tx_byte;
                    clks_cnt      <= 0;
                    tx_bit_index  <= 0;
                    r_tx_d        <= 1'b0;
                    tx_bit        <= `STOP_BIT;
                    current_state <= START_TX;
                end
                START_TX: begin
                    tx_bit            <= `START_BIT;
                    if (clks_cnt < (`CLKS_PER_BIT - 1)) begin
                        current_state <= START_TX;
                        clks_cnt      <= clks_cnt + 1;
                    end else begin
                        clks_cnt      <= 0;
                        current_state <= TX_ON;
                    end
                end
                TX_ON   : begin
                    tx_bit               <= r_tx_byte[tx_bit_index];
                    if (tx_bit_index < (`DATA_WIDTH - 1)) begin
                        if (clks_cnt < (`CLKS_PER_BIT - 1)) begin
                            clks_cnt     <= clks_cnt + 1;
                        end else begin
                            tx_bit_index <= tx_bit_index + 1;
                            clks_cnt     <= 0;
                        end
                        current_state    <= TX_ON;
                    end else begin
                        clks_cnt      <= 0;
                        tx_bit_index  <= 0;
                        current_state <= STOP_TX;
                    end
                end
                STOP_TX : begin
                    tx_bit            <= `STOP_BIT;
                    if (clks_cnt < (`CLKS_PER_BIT - 1)) begin      
                        clks_cnt      <= clks_cnt + 1;
                        current_state <= STOP_TX;
                    end else begin
                        clks_cnt      <= 0;
                        r_tx_d        <= 1'b1; // TODO: this still doesn't fire
                        current_state <= DATA_OK;
                    end
                end
                DATA_OK : begin
                    r_tx_d        <= 1'b0;
                    current_state <= IDLE;
                end
                default : current_state <= IDLE;
            endcase
        end else begin
            // waiting for transmitter mode to be activated, even if a valid data to transmit
            // is availabele
            current_state <= IDLE;
            tx_bit        <= `STOP_BIT;
            tx_bit_index  <= 0;
            r_tx_d        <= 1'b0;
            clks_cnt      <= 0;
        end
    end

    assign o_tx_d      = r_tx_d;
    assign o_tx_serial = tx_bit;

endmodule