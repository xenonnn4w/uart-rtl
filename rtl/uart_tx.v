`timescale 1ns/1ps
// Synchronous active-high reset. Requests while busy are ignored.
// CLK_HZ / BAUD must be an integer >= 2; no fractional baud generator.
module uart_tx #(
    parameter integer CLK_HZ = 1000000,
    parameter integer BAUD = 100000
)(
    input wire clk, rst, start,
    input wire [7:0] data,
    output reg tx = 1'b1,
    output reg busy = 1'b0,
    output reg done = 1'b0
);
    localparam integer TICKS = CLK_HZ / BAUD;
    localparam integer CW = (TICKS > 1) ? $clog2(TICKS) : 1;
    reg [CW-1:0] count = 0;
    reg [9:0] frame = 10'h3ff;
    reg [3:0] bit_index = 0;
    always @(posedge clk) begin
        if (rst) begin
            tx <= 1'b1;
            busy <= 1'b0;
            done <= 1'b0;
            count <= 0;
            bit_index <= 0;
            frame <= 10'h3ff;
        end else begin
            done <= 1'b0;
            if (!busy) begin
                tx <= 1'b1;
                if (start) begin
                    frame <= {1'b1, data, 1'b0};
                    tx <= 1'b0;
                    busy <= 1'b1;
                    count <= 0;
                    bit_index <= 0;
                end
            end else if (count == TICKS-1) begin
                count <= 0;
                if (bit_index == 9) begin
                    tx <= 1'b1;
                    busy <= 1'b0;
                    done <= 1'b1;
                end else begin
                    bit_index <= bit_index + 1'b1;
                    frame <= {1'b1, frame[9:1]};
                    tx <= frame[1];
                end
            end else begin
                count <= count + 1'b1;
            end
        end
    end
endmodule
