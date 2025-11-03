module top_tb();
    logic           clk;       // system clock
    logic           reset;     // active high reset
    tri     [3:0]   rows;      // 4-bit row input
    tri     [3:0]   cols;      // 4-bit column output
	logic			en1, en2;  //display enable logic
	logic           debug;

    // matrix of key presses: keys[row][col]
    logic [3:0][3:0] keys;

    // dut
    top dut( reset, rows, cols, seg, en1, en2, debug);

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

    // apply stimuli and check outputs
    initial begin
        reset = 0;
		#5

        // no key pressed
        keys = '{default:0};

        #22 reset = 1; //active high

        // press key at row=1, col=2
        keys[1][2] = 1;
		#50000

        // release button
        keys[1][2] = 0;
		#50000
		
		// press key at row=1, col=2
        keys[2][1] = 1;
		#50000
		
		// release button
        keys[1][2] = 0;
		#50000


        #100 $stop;
    end


endmodule