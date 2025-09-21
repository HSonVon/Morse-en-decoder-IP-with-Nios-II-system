`timescale 1ns/1ps

module Morse_IP_tb();
    // Parameters
    localparam DOT_TIME = 2;  // Changed from 25_000_000
    localparam WAIT_TIME = 5; // Changed from 50_000_000

    // Signals
    reg clk;
    reg reset_n;
    reg write;
    reg read;
    reg [1:0] address;
    reg [31:0] writedata;
    wire [31:0] readdata;
    reg [7:0] inital;
    reg MODE;
    wire [7:0] ascii_out;
    wire dot_t;
    wire wait_t;

    // Instantiate the Morse_IP module
    Morse_IP #(
        .DOT_TIME(DOT_TIME),
        .WAIT_TIME(WAIT_TIME)
    ) dut (
        .clk(clk),
        .reset_n(reset_n),
        .write(write),
        .read(read),
        .address(address),
        .writedata(writedata),
        .readdata(readdata),
        .inital(inital),
        .MODE(MODE),
        .ascii_out(ascii_out),
        .dot_t(dot_t),
        .wait_t(wait_t)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    // Test scenarios
    initial begin
        // Initialize signals
        clk = 0;
        reset_n = 1;
        write = 0;
        read = 0;
        address = 0;
        writedata = 0;
        inital = 0;
        MODE = 0;

        // Reset sequence
        #10 reset_n = 0;
        #10 reset_n = 1;

        // Test Case 1: MODE = 0 (Direct input)
        $display("Test Case 1: MODE = 0");
        MODE = 0;
        
        // Test 1.1: Morse code = 0 (dot), length = 1 (should output 'E')
        inital = 8'b001_00000; // length = 1, morse = 0
        #20;
        $display("Test 1.1: ASCII Output = %h (%c)", ascii_out, ascii_out);

        // Test 1.2: Morse code = 011, length = 3 (should output 'W')
        inital = 8'b011_00011; // length = 3, morse = 011
        #20;
        $display("Test 1.2: ASCII Output = %h (%c)", ascii_out, ascii_out);

        // Test 1.3: Morse code = 101, length = 3 (should output 'K')
        inital = 8'b011_00101; // length = 3, morse = 101
        #20;
        $display("Test 1.3: ASCII Output = %h (%c)", ascii_out, ascii_out);

        // Test Case 2: MODE = 1 (Input through signal)
        $display("\nTest Case 2: MODE = 1");
        MODE = 1;
        
        // Write signal value for testing
        write = 1;
        address = 2'd0;
        
        // Test 2.1: Generate morse code = 0, length = 1
        writedata = 2'b10; // Reset signal
        #20;
        writedata = 2'b00; // Start input
        #(DOT_TIME);
        writedata = 2'b01; // End input
        #(WAIT_TIME * 2);
        $display("Test 2.1: ASCII Output = %h (%c)", ascii_out, ascii_out);

        // Test 2.2: Generate morse code = 011, length = 3
        writedata = 2'b10; // Reset signal
        #20;
        // First bit (0)
        writedata = 2'b00;
        #(DOT_TIME*2);
        writedata = 2'b01;
        #(WAIT_TIME*2);
        // Second bit (1)
        writedata = 2'b00;
        #(DOT_TIME * 2);
        writedata = 2'b01;
        #(WAIT_TIME*2);
        // Third bit (1)
        writedata = 2'b00;
        #(DOT_TIME * 2);
        writedata = 2'b01;
        #(WAIT_TIME * 2);
        $display("Test 2.2: ASCII Output = %h (%c)", ascii_out, ascii_out);

        // End simulation
        #100;
        $finish;
    end

    // Optional: Monitor changes
    initial begin
        $monitor("Time=%0t MODE=%b morse_out=%b length=%b ascii_out=%h (%c)", 
                 $time, MODE, dut.morse_code, dut.length, ascii_out, ascii_out);
    end

endmodule