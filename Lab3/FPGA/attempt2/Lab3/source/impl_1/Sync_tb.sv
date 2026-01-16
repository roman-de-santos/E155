`timescale 1ns / 1ps

module tb_Sync();

  // Parameters
  parameter CLK_PERIOD = 10; // 10ns clock period (100MHz)

  // Testbench Signals
  logic        Clk;
  logic        Reset;
  logic [3:0]  Rows;
  logic [3:0]  dRows; // This is the output from the DUT

  // Instantiate the Device Under Test (DUT)
  // (Make sure this matches your module name)
  Sync dut (
    .Clk(Clk),
    .Reset(Reset),
    .Rows(Rows),
    .dRows(dRows)
  );

  // 1. Clock Generator
  initial begin
    Clk = 0;
    forever #(CLK_PERIOD / 2) Clk = ~Clk;
  end

  // 2. Stimulus and Checking
  initial begin
    $display("Starting Testbench...");
    
    // --- Reset Phase ---
    Reset = 1;
    Rows  = 4'h0;
    @(posedge Clk);
    @(posedge Clk);
    Reset = 0;
    $display("Time %0t: Reset de-asserted. Output dRows = %h", $time, dRows);
    
    // --- Test 1: Apply 'hA' ---
    @(posedge Clk); // Cycle 1
    Rows = 4'hA;
    $display("Time %0t: [Cycle 1] Applying Rows = %h. Output dRows = %h", $time, Rows, dRows);
    assert(dRows === 4'h0) else $error("FAIL: dRows should be 0");
    
    @(posedge Clk); // Cycle 2
    Rows = 4'hB; // Apply next value
    $display("Time %0t: [Cycle 2] Applying Rows = %h. Output dRows = %h", $time, Rows, dRows);
    assert(dRows === 4'h0) else $error("FAIL: dRows should still be 0 (latched 'hA' internally)");
    
    @(posedge Clk); // Cycle 3
    Rows = 4'hC; // Apply next value
    $display("Time %0t: [Cycle 3] Applying Rows = %h. Output dRows = %h", $time, Rows, dRows);
    // 'hA' from Cycle 1 should now appear
    assert(dRows === 4'hA) else $error("FAIL: dRows should be 'hA'");
    
    @(posedge Clk); // Cycle 4
    $display("Time %0t: [Cycle 4] Applying Rows = %h. Output dRows = %h", $time, Rows, dRows);
    // 'hB' from Cycle 2 should now appear
    assert(dRows === 4'hB) else $error("FAIL: dRows should be 'hB'");
    
    @(posedge Clk); // Cycle 5
    $display("Time %0t: [Cycle 5] Applying Rows = %h. Output dRows = %h", $time, Rows, dRows);
    // 'hC' from Cycle 3 should now appear
    assert(dRows === 4'hC) else $error("FAIL: dRows should be 'hC'");
    
    $display("Test Complete. All checks passed.");
    $finish;
  end

  // Optional: Monitor to see all signal changes
  initial begin
    $monitor("Time=%0t | Clk=%b Reset=%b | Rows=%h | dRows_out=%h",
             $time, Clk, Reset, Rows, dRows);
  end

endmodule