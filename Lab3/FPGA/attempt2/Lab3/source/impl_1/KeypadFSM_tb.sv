`timescale 1 ns/1 ns

module KeypadFSM_tb();
    logic           clk;    // system clock
    logic           reset;  // active high reset
    tri     [3:0]   rows;   // 4-bit row input
    tri     [3:0]   cols;   // 4-bit column output
    logic   [3:0]   sw1;     // old key
    logic   [3:0]   sw2;     // new key

    // matrix of key presses: keys[row][col]
    logic [3:0][3:0] keys;

    // dut
    KeypadFSM dut(clk, reset, rows, cols, sw1, sw2);

    // ensures rows = 4'b1111 when no key is pressed
    pulldown(rows[0]);
    pulldown(rows[1]);
    pulldown(rows[2]);
    pulldown(rows[3]);

    // keypad model using tranif
    genvar r, c;
    generate
        for (r = 0; r < 4; r++) begin : row_loop
            for (c = 0; c < 4; c++) begin : col_loop
                // when keys[r][c] == 1, connect cols[c] <-> rows[r]
                tranif1 key_switch(rows[r], cols[c], keys[r][c]);
            end
        end
    endgenerate

    // generate clock
    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    // task to check expected values of d0 and d1
    task check_key(input [3:0] exp_sw1, exp_sw2, string msg);
        #100;
        assert (sw1 == exp_sw1 && sw2 == exp_sw2)
            $display("PASSED!: %s -- got sw1=%h sw2=%h expected sw1=%h Sw2=%h at time %0t.", msg, sw1, sw2, exp_sw1, exp_sw2, $time);
        else
            $error("FAILED!: %s -- got sw1=%h sw2=%h expected sw1=%h sw2=%h at time %0t.", msg, sw1, sw2, exp_sw1, exp_sw2, $time);
        #50;
    endtask

    // apply stimuli and check outputs
    initial begin
        reset = 5;

        // no key pressed
        keys = '{default:0};

        #22 reset = 0;

        // press key at row=1, col=2
        keys[1][2] = 1;
		#50000
        check_key(4'h0, 4'h6, "First key press");

        // release button
        keys[1][2] = 0;
		#50000
		
		// press key at row=1, col=2
        keys[2][1] = 1;
		#50000
        check_key(4'h6, 4'h8, "Second key press");
		
		// release button
        keys[1][2] = 0;
		#50000


        #100 $stop;
    end

    // add a timeout
    initial begin
        #260000; // wait 130 us
        $error("Simulation did not complete in time.");
        $stop;
    end
endmodule