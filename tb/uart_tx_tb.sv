`timescale 1ns/1ps
module uart_tx_tb;
    parameter integer TICKS = 10;
    reg clk = 0, rst = 1, start = 0;
    reg [7:0] data = 0;
    wire tx, busy, done;
    integer frames = 0;
    uart_tx #(.CLK_HZ(TICKS*100000), .BAUD(100000)) dut(.*);
    always #5 clk = ~clk;
    task tick;
        @(posedge clk); #1;
    endtask
    task check(input bit condition, input string message);
        if (!condition) $fatal(1, "%s (TICKS=%0d time=%0t)", message, TICKS, $time);
    endtask
    task send_byte(input reg [7:0] value, input bit inject_busy);
        reg [9:0] expected;
        integer bit_no, cycle;
        expected = {1'b1, value, 1'b0};
        @(negedge clk); data = value; start = 1;
        tick();
        for (bit_no = 0; bit_no < 10; bit_no = bit_no+1) begin
            for (cycle = 0; cycle < TICKS; cycle = cycle+1) begin
                check(tx === expected[bit_no], "serial bit / bit duration mismatch");
                check(busy === 1'b1 && done === 1'b0, "busy/done during frame");
                @(negedge clk);
                // Alter both inputs during the frame to verify latching and rejection.
                start = inject_busy && bit_no == 3;
                data = ~value;
                tick();
            end
        end
        check(tx === 1'b1 && busy === 1'b0 && done === 1'b1, "completion timing");
        frames = frames + 1;
        @(negedge clk); start = 0;
    endtask
    initial begin
        if ($test$plusargs("vcd")) begin
            $dumpfile("build/uart_tx.vcd"); $dumpvars(0, uart_tx_tb);
        end
        tick(); check(tx && !busy && !done, "reset idle");
        @(negedge clk); rst = 0;
        repeat (3) begin tick(); check(tx && !busy && !done, "idle"); end
        for (integer i = 0; i < 256; i = i+1) send_byte(i[7:0], 1);
        tick(); check(!done && !busy && tx, "done must be one cycle");
        // Abort an active transmission with reset, then recover.
        @(negedge clk); start = 1; data = 8'h55;
        tick(); check(busy && !tx, "abort setup");
        @(negedge clk); start = 0;
        repeat (TICKS*3) tick();
        @(negedge clk); rst = 1;
        tick(); check(tx && !busy && !done, "mid-frame reset");
        @(negedge clk); rst = 0;
        send_byte(8'ha5, 0);
        tick(); check(tx && !busy && !done, "recovery idle");
        $display("PASS: %0d complete frames, exhaustive bytes, busy rejection, immediate reacceptance, reset recovery; TICKS=%0d", frames, TICKS);
        $finish;
    end
    initial begin #10000000; $fatal(1, "watchdog timeout"); end
endmodule
