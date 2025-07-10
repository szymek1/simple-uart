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
//              Testbench uses 125 MHz clock signal => 8ns clock cycle.
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


module uart_rx_tb (

);

    // UART receiver inputs
    reg                    clk;
    reg                    i_rx;
    reg                    i_rx_serial;

    // UART receiver outputs
    wire                   o_rx_d;
    wire [`DATA_WIDTH-1:0] o_rx_byte;

    uart_rx uut (
        .sysclk(clk),
        .i_rx(i_rx),
        .i_rx_serial(i_rx_serial),
        .o_rx_d(o_rx_d),
        .o_rx_byte(o_rx_byte)
    );

    task display_results;
        begin
            $display("Time=%0t | i_rx=%b | i_rx_serial=%b | o_rx_d=%b | o_rx_byte=%b",
                     $time,
                     i_rx,
                     i_rx_serial,
                     o_rx_d,
                     o_rx_byte);
        end
    endtask

    initial begin
        clk = 0;
        forever #(`CLK_PERIOD_NS/2) clk = ~clk; 
    end


    reg [`DATA_WIDTH-1:0] test_data = 8'b11001011;

    integer i;
    initial begin
        $dumpfile("uart_rx_tb_waveforms.vcd"); // Add waveform dumping
        $dumpvars(0, uart_rx_tb);
        // Initial conditions- i_rx disabled, receiver mode off
        i_rx = 1'b0;
        i_rx_serial = `STOP_BIT;
        #(10 * `CLK_PERIOD_NS); // wait 10 cycles with receiver off
        
        // Test 1: receiver diabled
        if (o_rx_d == 1'b0) begin
            $display("Test 1.1: PASS");
        end else begin
            $display("Test 1.1: FAIL- o_rx_d=%b, expected 0", o_rx_d);
        end
        if (o_rx_byte == 7'h0) begin
            $display("Test 1.2: PASS");
        end else begin
            $display("Test 1.2: FAIL- o_rx_byte=%h, expected 0", o_rx_byte);
        end

        // Test 2: serializing valid data
        i_rx = 1'b1;
        #(10 * `CLK_PERIOD_NS);

        i_rx_serial = `START_BIT;
        #(`CLKS_PER_BIT * `CLK_PERIOD_NS);
        for (i = 0; i < `DATA_WIDTH; i = i + 1) begin
            i_rx_serial = test_data[i];
            #(`CLKS_PER_BIT * `CLK_PERIOD_NS);
        end
        i_rx_serial = `STOP_BIT;
        #(`CLKS_PER_BIT * `CLK_PERIOD_NS);
        display_results();
        if (o_rx_d == 1'b1) begin
            $display("Test 2.1: PASS");
        end else begin
            $display("Test 2.1: FAIL- o_rx_d=%b, expected 1", o_rx_d);
        end
        if (o_rx_byte == test_data) begin
            $display("Test 2.2: PASS");
        end else begin
            $display("Test 2.2: FAIL- o_rx_byte=%b, expected %b", o_rx_byte, test_data);
        end

        #(10 * `CLK_PERIOD_NS);
        $finish;

    end


endmodule