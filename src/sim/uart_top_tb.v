//////////////////////////////////////////////////////////////////////////////////
// Company: ISAE
// Engineer: Szymon Bogus
// 
// Create Date: 12/10/2025
// Design Name: 
// Module Name: uart_top_tb
// Project Name: simple-uart
// Target Devices: Zybo Z7-20
// Tool Versions: 
// Description: Testbench for UART top module.
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


module uart_top_tb (

);

    // Inputs
    // general
    reg                   clk;
    reg [1:0]             i_btn; // btn[1]=BTN3 (receiver), btn[0]=BTN2 (transmitter) 
    reg uart_rx_serial;
    // transmitter
    reg [3:0] sw;

    // Outputs
    // general 
    wire                  uart_tx_serial;
    // transmitter
    wire                  led5_r;
    wire                  led5_g;
    wire                  led5_b;

    // receiver
    wire                  led6_r;
    wire                  led6_g;
    wire                  led6_b;

    uart_top uut (
        // Inputs
        // general
        .sysclk(clk),
        .btn(i_btn),
        .uart_rx_serial(uart_rx_serial),
        // transmitter
        .sw(sw),
        // Outputs
        // general
        .uart_tx_serial(uart_tx_serial),
        // transmitter
        .led(),
        .led5_r(led5_r),
        .led5_g(led5_g),
        .led5_b(led5_b),
        // receiver
        .led6_r(led6_r),
        .led6_g(led6_g),
        .led6_b(led6_b)
    );

    task display_results;
        begin
            $display("Time=%0t | btn3=%b | btn2=%b | led5_r=%b | led5_g=%b | led5_b=%b\n | led6_r=%b | led6_g=%b | led6_b=%b\n | rx_serial=%b | tx_serial=%b",
                     $time,
                     i_btn[1],
                     i_btn[0],
                     led5_r,
                     led5_g,
                     led5_b,
                     led6_r,
                     led6_g,
                     led6_b,
                     uart_rx_serial,
                     uart_tx_serial);
        end
    endtask

    initial begin
        clk = 0;
        forever #(`CLK_PERIOD_NS/2) clk = ~clk; 
    end

    // Modes options
    parameter NONE = 2'b00;
    parameter RX   = 2'b10;
    parameter TX   = 2'b01;
    parameter BOTH = 2'b11;

    integer i;
    initial begin
        $dumpfile("uart_top_tb_waveforms.vcd"); // Add waveform dumping
        $dumpvars(0, uart_top_tb.clk, 
                     uart_top_tb.i_btn,
                     uart_top_tb.led5_r,
                     uart_top_tb.led5_g,
                     uart_top_tb.led5_b,
                     uart_top_tb.led6_r,
                     uart_top_tb.led6_g,
                     uart_top_tb.led6_b);


        // Test 1: Initial conditions- both off
        i_btn = NONE;
        sw    = 4'bx;
        #(2.1 * `CLK_PERIOD_NS);
        if ((led5_r == 1'b1 && led5_g == 1'b0 && led5_b == 1'b0)) begin 
            $display("Test 1.1: PASS transmitter off");
        end else begin
            $display("Test 1.1: FAIL- got: %b, expected 100", {led5_r, led5_g, led5_b});
        end

        if ((led6_r == 1'b1 && led6_g == 1'b0 && led6_b == 1'b0)) begin 
            $display("Test 1.2: PASS receiver off");
        end else begin
            $display("Test 1.2: FAIL- got: %b, expected 100", {led6_r, led6_g, led6_b});
        end

        // Test 2: receiver on
        i_btn = RX;
        #(2.1 * `CLK_PERIOD_NS);
        if ((led5_r == 1'b1 && led5_g == 1'b0 && led5_b == 1'b0)) begin 
            $display("Test 2.1: PASS transmitter off");
        end else begin
            $display("Test 2.1: FAIL- got: %b, expected 100", {led5_r, led5_g, led5_b});
        end

        if ((led6_r == 1'b0 && led6_g == 1'b1 && led6_b == 1'b0)) begin 
            $display("Test 2.2: PASS receiver on");
        end else begin
            $display("Test 2.2: FAIL- got: %b, expected 010", {led6_r, led6_g, led6_b});
        end

        // Test 3: transmitter on
        i_btn = TX;
        #(2.1 * `CLK_PERIOD_NS);
        if ((led5_r == 1'b0 && led5_g == 1'b1 && led5_b == 1'b0)) begin 
            $display("Test 2.1: PASS transmitter on");
        end else begin
            $display("Test 2.1: FAIL- got: %b, expected 010", {led5_r, led5_g, led5_b});
        end

        if ((led6_r == 1'b1 && led6_g == 1'b0 && led6_b == 1'b0)) begin 
            $display("Test 2.2: PASS receiver off");
        end else begin
            $display("Test 2.2: FAIL- got: %b, expected 100", {led6_r, led6_g, led6_b});
        end

        // Test 4: transmitter on, receiver on
        i_btn = BOTH;
        sw    = 4'b1011; // transmitter should send: 00001011
        #(3 * `CLK_PERIOD_NS);
        display_results();
        #(`CLKS_PER_BIT * `CLK_PERIOD_NS);
        for (i = 0; i < `DATA_WIDTH; i = i + 1) begin
            // Waiting for all bits to be transmitted
            display_results();
            #(`CLKS_PER_BIT * `CLK_PERIOD_NS);
        end

        #(5 * `CLK_PERIOD_NS);
        $finish;

    end

endmodule