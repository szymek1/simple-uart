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
`timescale 1ns/1ps
`include include/uart_params.vh


module uart_rx(
    input  wire                   sysclk,
    input  wire                   i_rx,        // receive mode active signal (set high active)
    input  wire                   i_rx_serial, // serial data
    output wire                   o_rx_d,      // flag indicating that entire byte of data was received
    output wire [`DATA_WIDTH-1:0] o_rx_byte    // received data
);

    reg r_rx_d; // internal value for o_rx_d

    // Receiver FSM states
    parameter IDLE     = 3'b000;
    parameter START_RX = 3'b001;
    parameter RX_ON    = 3'b010;
    parameter STOP_RX  = 3'b100;
    parameter DATA_OK  = 3'b111;

    reg [2:0] current_state;

    reg [`DATA_WIDTH-1:0] rx_byte;      // internal storage of received data
    reg [2:0]             rx_bit_index; // used for counting received bits
    reg [11:0]            clks_cnt;     // used to count clock cycles before bit check is done

    // Double flip-flop to mitigate metastability
    reg r_i_rx_serial_r;
    reg r_i_rx_serial_dat;
    always @(posedge sysclk) begin
        r_i_rx_serial_r   <= i_rx_serial;
        r_i_rx_serial_dat <= r_i_rx_serial_r;
    end

    always @(posedge sysclk) begin
        if (i_rx) begin
            case (current_state)
                IDLE    : begin
                    rx_bit_index  <= 0;
                    clks_cnt      <= 0;
                    current_state <= (r_i_rx_serial_dat == `START_BIT) ? START_RX : IDLE;
                end
                START_RX: begin
                    if (clks_cnt == ((`CLKS_PER_BIT - 1) / 2)) begin
                        clks_cnt      <= 0;
                        current_state <= (r_i_rx_serial_dat == `START_BIT) ? RX_ON : IDLE;
                    end else begin
                        clks_cnt      <= clks_cnt + 1;
                    end
                end
                RX_ON   : begin
                    if (clks_cnt < (`CLKS_PER_BIT - 1)) begin
                        clks_cnt                  <= clks_cnt + 1;
                        current_state             <= RX_ON;
                    end else begin
                        clks_cnt                  <= 0;
                        if (rx_bit_index < `DATA_WIDTH) begin
                            rx_byte[rx_bit_index] <= r_i_rx_serial_dat;
                            rx_bit_index          <= rx_bit_index + 1;
                            current_state         <= RX_ON;
                        end else begin
                            rx_bit_index          <= 0;
                            current_state         <= STOP_RX;
                        end
                    end
                end
                STOP_RX : begin
                    if (clks_cnt < (`CLKS_PER_BIT - 1)) begin
                        clks_cnt      <= clks_cnt + 1;
                        current_state <= STOP_RX;
                    end else begin
                        clks_cnt      <= 0;
                        r_rx_d        <= (r_i_rx_serial_dat == `STOP_BIT) ? 1'b1 : 1'b0;
                        current_state <= (r_i_rx_serial_dat == `STOP_BIT) ? DATA_OK : IDLE;
                    end
                end
                DATA_OK : begin
                    current_state <= IDLE;
                    r_rx_d        <= 1'b0;
                end
                default : current_state <= IDLE;
            endcase

        end else begin
            // waiting for receiver mode to be activated, even if valid data is being streamed
            current_state     <= IDLE;
            rx_byte           <= {DATA_WIDTH{1'b0}};
            rx_bit_index      <= 0;
            clks_cnt          <= 0;
            r_i_rx_serial_r   <= 1'b1;
            r_i_rx_serial_dat <= 1'b1;
            r_rx_d            <= 1'b0;
        end
    end

    assign o_rx_d    = r_rx_d;
    assign o_rx_byte = rx_byte;

endmodule