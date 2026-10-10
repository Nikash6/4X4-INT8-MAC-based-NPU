`timescale 1ns / 1ps

module mac_array (

    input wire clk,
    input wire rst,
    input wire clear,
    input wire enable,

    input wire [1:0] k,

    // Matrix A
    input signed [7:0] a00, a01, a02, a03,
    input signed [7:0] a10, a11, a12, a13,
    input signed [7:0] a20, a21, a22, a23,
    input signed [7:0] a30, a31, a32, a33,

    // Matrix B
    input signed [7:0] b00, b01, b02, b03,
    input signed [7:0] b10, b11, b12, b13,
    input signed [7:0] b20, b21, b22, b23,
    input signed [7:0] b30, b31, b32, b33,

    // Outputs
    output signed [31:0] c00, c01, c02, c03,
    output signed [31:0] c10, c11, c12, c13,
    output signed [31:0] c20, c21, c22, c23,
    output signed [31:0] c30, c31, c32, c33
);

    reg signed [7:0] ar0, ar1, ar2, ar3;

    reg signed [7:0] bc0, bc1, bc2, bc3;

    // ---------------------------------------------------------
    // Select current k value
    // ---------------------------------------------------------

    always @(*) begin

        case (k)

            2'd0: begin

                // A column 0
                ar0 = a00;
                ar1 = a10;
                ar2 = a20;
                ar3 = a30;

                // B row 0
                bc0 = b00;
                bc1 = b01;
                bc2 = b02;
                bc3 = b03;

            end

            2'd1: begin

                // A column 1
                ar0 = a01;
                ar1 = a11;
                ar2 = a21;
                ar3 = a31;

                // B row 1
                bc0 = b10;
                bc1 = b11;
                bc2 = b12;
                bc3 = b13;

            end

            2'd2: begin

                // A column 2
                ar0 = a02;
                ar1 = a12;
                ar2 = a22;
                ar3 = a32;

                // B row 2
                bc0 = b20;
                bc1 = b21;
                bc2 = b22;
                bc3 = b23;

            end

            2'd3: begin

                // A column 3
                ar0 = a03;
                ar1 = a13;
                ar2 = a23;
                ar3 = a33;

                // B row 3
                bc0 = b30;
                bc1 = b31;
                bc2 = b32;
                bc3 = b33;

            end

        endcase

    end


    // ---------------------------------------------------------
    // 4x4 = 16 MAC units
    // ---------------------------------------------------------

    mac_unit mac00 (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .enable(enable),
        .a(ar0),
        .b(bc0),
        .acc(c00)
    );

    mac_unit mac01 (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .enable(enable),
        .a(ar0),
        .b(bc1),
        .acc(c01)
    );

    mac_unit mac02 (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .enable(enable),
        .a(ar0),
        .b(bc2),
        .acc(c02)
    );

    mac_unit mac03 (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .enable(enable),
        .a(ar0),
        .b(bc3),
        .acc(c03)
    );


    mac_unit mac10 (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .enable(enable),
        .a(ar1),
        .b(bc0),
        .acc(c10)
    );

    mac_unit mac11 (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .enable(enable),
        .a(ar1),
        .b(bc1),
        .acc(c11)
    );

    mac_unit mac12 (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .enable(enable),
        .a(ar1),
        .b(bc2),
        .acc(c12)
    );

    mac_unit mac13 (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .enable(enable),
        .a(ar1),
        .b(bc3),
        .acc(c13)
    );


    mac_unit mac20 (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .enable(enable),
        .a(ar2),
        .b(bc0),
        .acc(c20)
    );

    mac_unit mac21 (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .enable(enable),
        .a(ar2),
        .b(bc1),
        .acc(c21)
    );

    mac_unit mac22 (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .enable(enable),
        .a(ar2),
        .b(bc2),
        .acc(c22)
    );

    mac_unit mac23 (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .enable(enable),
        .a(ar2),
        .b(bc3),
        .acc(c23)
    );


    mac_unit mac30 (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .enable(enable),
        .a(ar3),
        .b(bc0),
        .acc(c30)
    );

    mac_unit mac31 (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .enable(enable),
        .a(ar3),
        .b(bc1),
        .acc(c31)
    );

    mac_unit mac32 (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .enable(enable),
        .a(ar3),
        .b(bc2),
        .acc(c32)
    );

    mac_unit mac33 (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .enable(enable),
        .a(ar3),
        .b(bc3),
        .acc(c33)
    );

endmodule