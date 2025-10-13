`timescale 1ns/1ps

module tb_DispFSM;
    // DUT signals
    logic        Clk, Reset;
    logic [15:0] KeyVal;
    logic [3:0]  Sw1, Sw2;

    // Instantiate DUT
    DispFSM dut (
        .Clk    (Clk),
        .Reset  (Reset),
        .KeyVal (KeyVal),
        .Sw1    (Sw1),
        .Sw2    (Sw2)
    );

    // Clock generation
    initial Clk = 0;
    always #5 Clk = ~Clk;  // 100 MHz clock

    // Simple reset task
    task do_reset;
        begin
            Reset = 1;
            KeyVal = 16'h0000;
            @(posedge Clk);
            Reset = 0;
        end
    endtask

    // Task to press a key and check transition
    task press_key(input int key_idx, input logic [3:0] expected_val);
        begin
            // apply one-hot KeyVal
            KeyVal = 16'h1 << key_idx;
            @(posedge Clk); // move into sN state
            @(posedge Clk); // move into stop state
			@(posedge Clk); // allow a cycle to assign Sw2_next to Sw2

            // Check Sw2 output = expected
            if (Sw2 !== expected_val) begin
                $error("FAIL: Key %0d expected Sw2=%h, got %h", key_idx, expected_val, Sw2);
            end else begin
                $display("PASS: Key %0d produced Sw2=%h", key_idx, Sw2);
            end

            // release key
            KeyVal = 16'h0000;
            @(posedge Clk); // allow FSM to return to idle
        end
    endtask

    // Test sequence
    initial begin
        do_reset();

        // Loop through all 16 keys
        for (int i = 0; i < 16; i++) begin
            press_key(i, i[3:0]);
        end

        $display("All tests completed.");
        $stop;
    end
endmodule
