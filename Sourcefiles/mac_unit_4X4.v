`timescale 1ns / 1ps

module mac_unit (
    input  wire clk,
    input  wire rst,
    input  wire clear,
    input  wire enable,

    input  signed [7:0] a,
    input  signed [7:0] b,

    output reg signed [31:0] acc
);

    wire signed [15:0] product;

    assign product = a * b;

    always @(posedge clk) begin

        if (rst) begin
            acc <= 32'sd0;
        end

        else if (clear) begin
            acc <= 32'sd0;
        end

        else if (enable) begin
            acc <= acc + product;
        end

    end

endmodule