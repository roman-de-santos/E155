`timescale 1 ns/1 ns

module keypad_tb();
    logic           clk;    // system clock
    logic           reset;  // active high reset
    tri     [3:0]   rows;   // 4-bit row input
    tri     [3:0]   cols;   // 4-bit column output
    logic   [15:0]  KeyVal;

    // matrix of key presses: keys[row][col]
    logic [3:0][3:0] keys;

    // dut
    Keypad dut(clk, reset, rows, cols, KeyVal);

    // ensures rows = 4'b1111 when no key is pressed
    pullup(rows[0]);
    pullup(rows[1]);
    pullup(rows[2]);
    pullup(rows[3]);

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
    task check_key(input [15:0] exp_val, string msg);
        #3100000; //debouncer delay
        assert (KeyVal == exp_val)
            $display("PASSED!: %s -- got KeyVal=%h expected expVal=%h at time %0t.", msg, KeyVal, exp_val, $time);
        else
            $error("FAILED!: %s -- got KeyVal=%h expected expVal=%h at time %0t.", msg, KeyVal, exp_val, $time);
        #50;
    endtask

    // apply stimuli and check outputs
    initial begin
        reset = 1;

        // no key pressed
        keys = '{default:0};

        #22 reset = 0;

        // press key at row=1, col=2
        #50 keys[1][2] = 1; 
        check_key(16'h0000, "First key press");

        // release button
        keys[1][2] = 0;

        // press another key at row=0, col=0
        keys[2][3] = 1;
        check_key(16'h0000, "Second key press");

        // release buttons
        #100 keys = '{default:0};

        #100 $stop;
    end


endmodule