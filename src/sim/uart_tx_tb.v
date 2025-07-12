//////////////////////////////////////////////////////////////////////////////////
// Company: ISAE
// Engineer: Szymon Bogus
// 
// Create Date: 12/10/2025
// Design Name: 
// Module Name: uart_tx_tb
// Project Name: simple-uart
// Target Devices: Zybo Z7-20
// Tool Versions: 
// Description: Testbench for UART transmitter module.
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


module uart_tx_tb (

);

    // UART receiver inputs
    reg                    clk;
    reg                    i_tx;
    reg [`DATA_WIDTH-1:0]  i_tx_byte;

    // UART receiver outputs
    wire                   o_tx_d;
    wire                   o_tx_serial;

    uart_tx uut (
        .sysclk(clk),
        .i_tx(i_tx),
        .i_tx_byte(i_tx_byte),
        .o_tx_serial(o_tx_serial),
        .o_tx_d(o_tx_d)
    );

    task display_results;
        begin
            $display("Time=%0t | i_tx=%b | i_tx_byte=%b | o_tx_d=%b | o_tx_serial=%b",
                     $time,
                     i_tx,
                     i_tx_byte,
                     o_tx_d,
                     o_tx_serial);
        end
    endtask

    initial begin
        clk = 0;
        forever #(`CLK_PERIOD_NS/2) clk = ~clk; 
    end


    reg [`DATA_WIDTH-1:0] test_data = 8'b11001011;

    integer i;
    initial begin
        $dumpfile("uart_tx_tb_waveforms.vcd"); // Add waveform dumping
        $dumpvars(0, uart_tx_tb);
        // Initial conditions- i_tx disabled, transmitter mode off
        i_tx = 1'b0;
        i_tx_byte = test_data;
        #(10 * `CLK_PERIOD_NS); // wait 10 cycles with receiver off
        
        // Test 1: receiver diabled
        if (o_tx_d == 1'b0) begin
            $display("Test 1.1: PASS");
        end else begin
            $display("Test 1.1: FAIL- o_tx_d=%b, expected 0", o_tx_d);
        end
        if (o_tx_serial == `STOP_BIT) begin
            $display("Test 1.2: PASS");
        end else begin
            $display("Test 1.2: FAIL- o_tx_serial=%b, expected 1", o_tx_serial);
        end

        // Test 2: serializing valid data
        i_tx = 1'b1;
        // #(10 * `CLK_PERIOD_NS);
        #(3 * `CLK_PERIOD_NS); // transmitter issues start bit
        if (o_tx_serial == `START_BIT) begin
            $display("Test 2.1: PASS");
        end else begin
            $display("Test 2.2: FAIL- o_tx_serial=%b, expected %b", o_tx_serial, `START_BIT);
        end
        #(`CLKS_PER_BIT * `CLK_PERIOD_NS);
        for (i = 0; i < `DATA_WIDTH; i = i + 1) begin
            // Waiting for all bits to be transmitted
            display_results();
            #(`CLKS_PER_BIT * `CLK_PERIOD_NS);
        end
        // #(`CLKS_PER_BIT * `CLK_PERIOD_NS);
        display_results();
        if (o_tx_d == 1'b1) begin
            $display("Test 2.2: PASS");
        end else begin
            $display("Test 2.2: FAIL- o_tx_d=%b, expected 1", o_tx_d);
        end
        if (o_tx_serial == `STOP_BIT) begin
            $display("Test 2.3: PASS");
        end else begin
            $display("Test 2.3: FAIL- o_tx_serial=%b, expected %b", o_tx_serial, `STOP_BIT);
        end

        #(10 * `CLK_PERIOD_NS);
        $finish;

    end


endmodule